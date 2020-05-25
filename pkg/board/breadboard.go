package board

// The BREADBOARD comes loaded with the following components:
// - ALU, RAM and BUS
// - All registers (except IAR and IR registers)

import (
	"fmt"
	"io"
	"log"
	"os"
	"strings"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
	p "github.com/patrickleboutillier/jcscpu/pkg/parts"
)

var instHandlers = make(map[string]func(*Breadboard))
var iodevHandlers = make(map[string]func(*Breadboard))

// Default logger
var logger = log.New(os.Stderr, "DEBUG: ", 0)

// Defaut log function
var logWith = func(msg string) {
	logger.Output(1, msg)
}

/*
BREADBOARD
*/
type Breadboard struct {
	wires     map[string]*g.Wire
	buses     map[string]*g.Bus
	regs      map[string]*p.Register
	ores      map[string]*g.ORe
	RAM       *p.RAM
	ALU       *p.ALU
	BUS1      *p.Bus1
	CLK       *p.Clock
	STP       *p.Stepper
	Ctmp      *p.Memory
	IOAdapter *IOAdapter

	debug int
	CU    bool

	TTYWriter io.Writer
	RNGLast   int
}

func NewInstProcBreadboard() *Breadboard {
	this := NewVanillaBreadboard()
	InstProc(this)
	return this
}

func NewInstImplBreadboard() *Breadboard {
	this := NewInstProcBreadboard()
	InstImpl(this)
	this.CU = true
	return this
}

func NewInstBreadboard(inst string) *Breadboard {
	this := NewInstImplBreadboard()
	instHandlers[inst](this)
	return this
}

func NewBreadboard() *Breadboard {
	this := NewInstImplBreadboard()
	for _, f := range instHandlers {
		f(this)
	}
	for _, f := range iodevHandlers {
		f(this)
	}
	return this
}

func NewVanillaBreadboard() *Breadboard {
	wires := make(map[string]*g.Wire)
	buses := make(map[string]*g.Bus)
	regs := make(map[string]*p.Register)
	ores := make(map[string]*g.ORe)

	this := &Breadboard{wires: wires, buses: buses, regs: regs, ores: ores}

	// RAM
	this.putBus("DATA.bus", g.NewBus())
	this.putWire("RAM.MAR.s", g.NewWire())
	this.putWire("RAM.s", g.NewWire())
	this.putWire("RAM.e", g.NewWire())
	this.RAM = p.NewRAM(
		this.GetBus("DATA.bus"),
		this.GetWire("RAM.MAR.s"),
		this.GetBus("DATA.bus"),
		this.GetWire("RAM.s"),
		this.GetWire("RAM.e"),
	)
	this.putReg("RAM.MAR", this.RAM.GetMAR())

	// REGISTERS
	this.putWire("R0.s", g.NewWire())
	this.putWire("R0.e", g.NewWire())
	this.putWire("R1.s", g.NewWire())
	this.putWire("R1.e", g.NewWire())
	this.putWire("R2.s", g.NewWire())
	this.putWire("R2.e", g.NewWire())
	this.putWire("R3.s", g.NewWire())
	this.putWire("R3.e", g.NewWire())
	this.putWire("TMP.s", g.NewWire())
	this.putWire("TMP.e", g.WireOn()) // TMP.e is always on
	this.putBus("TMP.bus", g.NewBus())
	this.putWire("BUS1.bit1", g.NewWire())
	this.putBus("BUS1.bus", g.NewBus())

	this.putReg("R0", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("R0.s"), this.GetWire("R0.e"), this.GetBus("DATA.bus"), "R0"))
	this.putReg("R1", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("R1.s"), this.GetWire("R1.e"), this.GetBus("DATA.bus"), "R1"))
	this.putReg("R2", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("R2.s"), this.GetWire("R2.e"), this.GetBus("DATA.bus"), "R2"))
	this.putReg("R3", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("R3.s"), this.GetWire("R3.e"), this.GetBus("DATA.bus"), "R3"))
	this.putReg("TMP", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("TMP.s"), this.GetWire("TMP.e"), this.GetBus("TMP.bus"), "TMP"))
	this.BUS1 = p.NewBus1(this.GetBus("TMP.bus"), this.GetWire("BUS1.bit1"), this.GetBus("BUS1.bus"))

	// ALU
	this.putWire("ACC.s", g.NewWire())
	this.putWire("ACC.e", g.NewWire())
	this.putBus("ALU.bus", g.NewBus())
	this.putWire("ALU.ci", g.NewWire())
	this.putBus("ALU.op", g.NewBusN(3))
	this.putWire("ALU.co", g.NewWire())
	this.putWire("ALU.eqo", g.NewWire())
	this.putWire("ALU.alo", g.NewWire())
	this.putWire("ALU.z", g.NewWire())
	this.putWire("FLAGS.e", g.WireOn()) // FLAGS.e is always on
	this.putWire("FLAGS.s", g.NewWire())

	this.putReg("ACC", p.NewRegister(this.GetBus("ALU.bus"), this.GetWire("ACC.s"), this.GetWire("ACC.e"), this.GetBus("DATA.bus"), "ACC"))
	this.ALU = p.NewALU(
		this.GetBus("DATA.bus"),
		this.GetBus("BUS1.bus"),
		this.GetWire("ALU.ci"),
		this.GetBus("ALU.op"),
		this.GetBus("ALU.bus"),
		this.GetWire("ALU.co"),
		this.GetWire("ALU.eqo"),
		this.GetWire("ALU.alo"),
		this.GetWire("ALU.z"),
	)
	this.putBus("FLAGS.in", g.WrapBusV(this.GetWire("ALU.co"), this.GetWire("ALU.alo"), this.GetWire("ALU.eqo"), this.GetWire("ALU.z"),
		g.WireOff(), g.WireOff(), g.WireOff(), g.WireOff()))
	this.putBus("FLAGS.bus", g.WrapBusV(g.NewWire(), g.NewWire(), g.NewWire(), g.NewWire(),
		g.WireOff(), g.WireOff(), g.WireOff(), g.WireOff()))
	this.putReg("FLAGS",
		p.NewRegister(
			this.GetBus("FLAGS.in"),
			this.GetWire("FLAGS.s"),
			this.GetWire("FLAGS.e"),
			// We DO NOT hook up the ALU carry in just yet, we will do that when we setup ALU instructions processing
			this.GetBus("FLAGS.bus"),
			"FLAGS",
		),
	)

	// CLOCK & STEPPER
	this.putWire("CLK.clk", g.NewWire())
	this.putWire("CLK.clke", g.NewWire())
	this.putWire("CLK.clks", g.NewWire())
	this.putBus("STP.bus", g.NewBusN(7))
	this.CLK = p.NewClock(this.GetWire("CLK.clk"), this.GetWire("CLK.clke"), this.GetWire("CLK.clks"))
	this.putWire("CLK.clkd", this.CLK.Clkd())
	this.STP = p.NewStepper(this.GetWire("CLK.clk"), this.GetBus("STP.bus"))

	// I/O
	this.putWire("IO.clks", g.NewWire())
	this.putWire("IO.clke", g.NewWire())
	this.putWire("IO.da", g.NewWire())
	this.putWire("IO.io", g.NewWire())

	this.putBus("IO.bus", g.WrapBusV(this.GetWire("IO.clks"), this.GetWire("IO.clke"), this.GetWire("IO.da"), this.GetWire("IO.io")))
	this.IOAdapter = NewIOAdapter(this.GetBus("DATA.bus"), this.GetBus("IO.bus"))

	// Hook up the FLAGS Register co output to the ALU ci, adding the AND gate described in the Errata #2
	// Errata stuff: http://www.buthowdoitknow.com/errata.html
	// Naively: new CONN($this.get("FLAGS").os().wire(0), $this.get("ALU").ci())
	weor := g.NewWire()
	wco := g.NewWire()
	this.Ctmp = p.NewNamedMemory(this.GetBus("FLAGS.bus").GetWire(0), this.GetWire("TMP.s"), wco, "Ctmp")
	g.NewAND(wco, weor, this.GetWire("ALU.ci"))
	this.putORe("ALU.ci.ena.eor", g.NewORe(weor))

	// Debug handlers:
	this.GetWire("CLK.clk").AddEarlyhook(func(v bool) {
		if (this.debug == 1 && v && (this.CLK.GetQTicks()%24) == 0) ||
			(this.debug == 2 && v && (this.CLK.GetQTicks()%4) == 0) ||
			(this.debug == 3) {
			this.Debug()
		}
	})
	this.GetWire("CLK.clkd").AddEarlyhook(func(v bool) {
		if this.debug == 3 {
			this.Debug()
		}
	})

	return this
}

func (this *Breadboard) putWire(name string, w *g.Wire) {
	if _, ok := this.wires[name]; ok {
		panic(fmt.Errorf("Wire '%s' already registered with Breadboard", name))
	}
	this.wires[name] = w
}

func (this *Breadboard) GetWire(name string) *g.Wire {
	if _, ok := this.wires[name]; !ok {
		panic(fmt.Errorf("Wire '%s' not registered with Breadboard", name))
	}
	return this.wires[name]
}

func (this *Breadboard) putBus(name string, b *g.Bus) {
	if _, ok := this.buses[name]; ok {
		panic(fmt.Errorf("Bus '%s' already registered with Breadboard", name))
	}
	this.buses[name] = b
}

func (this *Breadboard) GetBus(name string) *g.Bus {
	if _, ok := this.buses[name]; !ok {
		panic(fmt.Errorf("Bus '%s' not registered with Breadboard", name))
	}
	return this.buses[name]
}

func (this *Breadboard) putReg(name string, r *p.Register) {
	if _, ok := this.regs[name]; ok {
		panic(fmt.Errorf("Register '%s' already registered with Breadboard", name))
	}
	this.regs[name] = r
}

func (this *Breadboard) GetReg(name string) *p.Register {
	if _, ok := this.regs[name]; !ok {
		panic(fmt.Errorf("Register '%s' not registered with Breadboard", name))
	}
	return this.regs[name]
}

func (this *Breadboard) putORe(name string, o *g.ORe) {
	if _, ok := this.ores[name]; ok {
		panic(fmt.Errorf("ORe '%s' already registered with Breadboard", name))
	}
	this.ores[name] = o
}

func (this *Breadboard) GetORe(name string) *g.ORe {
	if _, ok := this.ores[name]; !ok {
		panic(fmt.Errorf("ORe '%s' not registered with Breadboard", name))
	}
	return this.ores[name]
}

func (this *Breadboard) Tick() {
	this.CLK.Tick()
}

func (this *Breadboard) Ticks(n int) {
	if n <= 0 {
		panic(fmt.Errorf("Number of ticks must be >= 1, not %d", n))
	}
	for j := 0; j < n; j++ {
		this.Tick()
	}
}

func (this *Breadboard) Step() {
	this.Tick()
}

func (this *Breadboard) Steps(n int) {
	this.Ticks(n)
}

func (this *Breadboard) Inst() {
	cur := this.STP.GetStep()
	if (cur != 0) && (cur != 6) {
		panic(fmt.Errorf("Can't Inst mid-instruction (step: %d)", cur))
	}

	this.Ticks(6)
}

func (this *Breadboard) Insts(n int) {
	if n <= 0 {
		panic(fmt.Errorf("Number of insts must be >= 1, not %d", n))
	}

	for j := 0; j < n; j++ {
		this.Inst()
	}
}

func (this *Breadboard) Start() {
	this.CLK.Start()
}

func (this *Breadboard) Stop() {
	this.CLK.Stop()
}

// Replace logger with a new function
func LogWith(f func(msg string)) {
	logWith = f
}

func (this *Breadboard) Debug() {
	this.Log(this.String())
}

func (this *Breadboard) DebugInst() {
	this.debug = 1
}

func (this *Breadboard) DebugTick() {
	this.debug = 2
}

func (this *Breadboard) DebugQTick() {
	this.debug = 3
}

func (this *Breadboard) DebugOff() {
	// Final state.
	this.Debug()
	this.debug = 0
}

// Send a debug something to the debug writer
func (this *Breadboard) Log(l interface{}) {
	logWith(fmt.Sprintf("%+v", l))
}

func (this *Breadboard) SetReg(reg string, data int) {
	this.GetBus("DATA.bus").SetPower(data)
	f := fmt.Sprintf("%s.s", reg)
	this.GetWire(f).SetPower(true)
	this.GetWire(f).SetPower(false)
}

func (this *Breadboard) SetRAM(addr int, data int) {
	this.GetBus("DATA.bus").SetPower(addr)
	this.GetWire("RAM.MAR.s").SetPower(true)
	this.GetWire("RAM.MAR.s").SetPower(false)
	this.GetBus("DATA.bus").SetPower(data)
	this.GetWire("RAM.s").SetPower(true)
	this.GetWire("RAM.s").SetPower(false)
}

func (this *Breadboard) String() string {
	str := "\n"
	str += this.CLK.String() + "  " + this.STP.String() + "\n"
	str += "BUS:" + this.GetBus("DATA.bus").String() + "  "
	str += strings.Join([]string{this.GetReg("TMP").String(), this.BUS1.String(), this.GetReg("ACC").String(), this.GetReg("FLAGS").String(),
		this.GetReg("R0").String(), this.GetReg("R1").String(), this.GetReg("R2").String(), this.GetReg("R3").String()}, "  ") + "\n"
	var ctmp string
	if this.Ctmp.GetM() {
		ctmp = "1"
	} else {
		ctmp = "0"
	}
	str += this.ALU.String() + "  ctmp:" + ctmp + "\n"
	str += this.RAM.String()

	str += "CU: " + this.GetReg("IAR").String() + "  " + this.GetReg("IR").String()
	if this.CU {
		str += "  INST.bus:" + this.GetBus("INST.bus").String()
		str += "  REGA.e:" + this.GetWire("REGA.e").String() + "/" + this.GetBus("REGA.e.dec.bus").String()
		str += "  REGB.e:" + this.GetWire("REGB.e").String() + "/" + this.GetBus("REGB.e.dec.bus").String()
		str += "  REGB.s:" + this.GetWire("REGB.s").String() + "/" + this.GetBus("REGB.s.dec.bus").String()
		//    $str .= "\nIO:\n"
		//    $str .= "  IO.clks:" . $this.get("IO.clks").power()
		//    $str .= "  IO.clke:" . $this.get("IO.clke").power()
		//    $str .= "  IO.da:" . $this.get("IO.da").power()
		//    $str .= "  IO.io:" . $this.get("IO.io").power() . "\n"
		//    $str .= $this.get("IO.adapter").show()
	}
	str += "\n"

	return str
}

/*
#
# Convenience methods
#

# Initialize RAM contents from a file.
# This file should be the output of a jcsasm program
sub initRAM {
    my $this = shift
    my $file = shift

    open(RAMF, "<$file") or croak("Can't open RAM init file '$file': $!")
    return $this.initRAMh(\*RAMF)
}


# Initialize RAM contents from a file.
# This file should be the output of a jcsasm program
sub initRAMh {
    my $this = shift
    my $handle = shift

    return $this.initRAMl($this.readINSTS($handle))
}


sub initRAMl {
    my $this = shift
    my $lines = shift

    my $addr = 0
    foreach my $inst (@{$this.readINSTSl($lines)}){
        $this.setRAM(sprintf("%08b", $addr++), $inst)
    }

    # Important to reset the DATA.bus after loading RAM as it will leave data there
    # that will mess up the rest of the instruction loading.
    $this.get("DATA.bus").power("00000000")
}


# This file should be the output of a jcsasm program
sub readINSTS {
    my $this = shift
    my $handle = shift

    my @lines = (<$handle>)
    return $this.readINSTSl(\@lines)
}


sub readINSTSl {
    my $this = shift
    my $lines = shift

    my @insts = ()
    foreach my $line (@{$lines}){
        chomp($line)
        $line =~ s/[^[:print:]]//g
        if ($line =~ s/^#DEBUG//){
            $BREADBOARD::DEBUG[scalar(@insts)] = $line
        }
        next unless $line =~ /^([01]{8})\b/
        my $inst = $1
        push @insts, $inst
    }

    return \@insts
}



*/
