package parts

// The BREADBOARD comes loaded with the following components:
// - ALU, RAM and BUS
// - All registers (except IAR and IR registers)
//
// Using the options hash, you can specify more componnents be added:
//  instproc: Add IAR, IR and elactic ORs to create the Enables and Sets sides of the board for everything

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
BREADBOARD
*/
type Breadboard struct {
	wires map[string]*g.Wire
	buses map[string]*g.Bus
	regs  map[string]*Register
	RAM   *RAM
	ALU   *ALU
	BUS1  *Bus1
	CLK   *Clock
	STP   *Stepper
}

func NewInstProcBreadboard() *Breadboard {
	return NewVanillaBreadboard()
}

func NewInstImplBreadboard() *Breadboard {
	return NewInstProcBreadboard()
}

func NewInstBreadboard(inst string) *Breadboard {
	return NewInstImplBreadboard()
}

//func NewBreadboard() *Breadboard {
//	return NewInstImplBreadboard()
//}

func NewVanillaBreadboard() *Breadboard {
	wires := make(map[string]*g.Wire)
	buses := make(map[string]*g.Bus)
	regs := make(map[string]*Register)

	this := &Breadboard{wires: wires, buses: buses, regs: regs}

	// RAM
	this.putBus("DATA.bus", g.NewBus())
	this.putWire("RAM.MAR.s", g.NewWire())
	this.putWire("RAM.s", g.NewWire())
	this.putWire("RAM.e", g.NewWire())
	this.RAM = NewRAM(
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

	this.putReg("R0", NewRegister(this.GetBus("DATA.bus"), this.GetWire("R0.s"), this.GetWire("R0.e"), this.GetBus("DATA.bus"), "R0"))
	this.putReg("R1", NewRegister(this.GetBus("DATA.bus"), this.GetWire("R1.s"), this.GetWire("R1.e"), this.GetBus("DATA.bus"), "R1"))
	this.putReg("R2", NewRegister(this.GetBus("DATA.bus"), this.GetWire("R2.s"), this.GetWire("R2.e"), this.GetBus("DATA.bus"), "R2"))
	this.putReg("R3", NewRegister(this.GetBus("DATA.bus"), this.GetWire("R3.s"), this.GetWire("R3.e"), this.GetBus("DATA.bus"), "R3"))
	this.putReg("TMP", NewRegister(this.GetBus("DATA.bus"), this.GetWire("TMP.s"), this.GetWire("TMP.e"), this.GetBus("TMP.bus"), "TMP"))
	this.BUS1 = NewBus1(this.GetBus("TMP.bus"), this.GetWire("BUS1.bit1"), this.GetBus("BUS1.bus"))

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

	this.putReg("ACC", NewRegister(this.GetBus("ALU.bus"), this.GetWire("ACC.s"), this.GetWire("ACC.e"), this.GetBus("DATA.bus"), "ACC"))
	this.ALU = NewALU(
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

	this.putReg("FLAGS",
		NewRegister(
			g.WrapBusV(this.ALU.co, this.ALU.alo, this.ALU.eqo, this.ALU.z,
				g.WireOff(), g.WireOff(), g.WireOff(), g.WireOff(),
			),
			this.GetWire("FLAGS.s"),
			this.GetWire("FLAGS.e"),
			// We DO NOT hook up the ALU carry in just yet, we will do that when we setup ALU instructions processing
			g.WrapBusV(g.NewWire(), g.NewWire(), g.NewWire(), g.NewWire(),
				g.WireOff(), g.WireOff(), g.WireOff(), g.WireOff(),
			),
			"FLAGS",
		),
	)

	// CLOCK & STEPPER
	this.putWire("CLK.clk", g.NewWire())
	this.putWire("CLK.clke", g.NewWire())
	this.putWire("CLK.clks", g.NewWire())
	this.putBus("STP.bus", g.NewBusN(7))
	this.CLK = NewClock(this.GetWire("CLK.clk"), this.GetWire("CLK.clke"), this.GetWire("CLK.clks"))
	this.STP = NewStepper(this.GetWire("CLK.clk"), this.GetBus("STP.bus"))

	// I/O
	this.putWire("IO.clks", g.NewWire())
	this.putWire("IO.clke", g.NewWire())
	this.putWire("IO.da", g.NewWire())
	this.putWire("IO.io", g.NewWire())

	this.putBus("IO.bus", g.WrapBusV(this.GetWire("IO.clks"), this.GetWire("IO.clke"), this.GetWire("IO.da"), this.GetWire("IO.io")))
	// this.IOAdapter = NewIOAdapter(this.GetBus("DATA.bus"), this.GetBus("IO.bus"))

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

func (this *Breadboard) putReg(name string, r *Register) {
	if _, ok := this.regs[name]; ok {
		panic(fmt.Errorf("Register '%s' already registered with Breadboard", name))
	}
	this.regs[name] = r
}

func (this *Breadboard) GetReg(name string) *Register {
	if _, ok := this.regs[name]; !ok {
		panic(fmt.Errorf("Register '%s' not registered with Breadboard", name))
	}
	return this.regs[name]
}

func (this *Breadboard) Tick() {
	this.CLK.Tick()
}

func (this *Breadboard) Ticks(n int) {
	if n <= 0 {
		panic(fmt.Errorf("Number of ticks must be >= 1, not %d", n))
	}
	for j := 0; j < n; j++ {
		this.CLK.Tick()
	}
}

/*


sub new {
    my $class = shift ;
    my %opts = @_ ;

    my $this = {
        opts, \%opts,
        halt, undef,
    } ;
    bless $this, $class ;

    # RAM
    $this->put(
        "DATA.bus", new BUS(),
        "RAM.MAR.s", NewWire())
        "RAM.s", NewWire())
        "RAM.e", NewWire())    ) ;
    $this->put(
        "RAM", new RAM($this->get(qw/DATA.bus RAM.MAR.s DATA.bus RAM.s RAM.e/)),
    ) ;
    $this->put("RAM.MAR", $this->get("RAM")->MAR()) ;

    # RegisterS
    $this->put(
        "R0.s", NewWire())
        "R0.e", NewWire())
        "R1.s", NewWire())
        "R1.e", NewWire())
        "R2.s", NewWire())
        "R2.e", NewWire())
        "R3.s", NewWire())
        "R3.e", NewWire())
        "TMP.s", NewWire())
        "TMP.e", WIRE->on(), # TMP.e is always on
        "TMP.bus", new BUS(),
        "BUS1.bit1", NewWire())
        "BUS1.bus", new BUS(),
    ) ;
    $this->put(
        'R0', new Register($this->get(qw/DATA.bus R0.s R0.e DATA.bus/), "R0"),
        'R1', new Register($this->get(qw/DATA.bus R1.s R1.e DATA.bus/), "R1"),
        'R2', new Register($this->get(qw/DATA.bus R2.s R2.e DATA.bus/), "R2"),
        'R3', new Register($this->get(qw/DATA.bus R3.s R3.e DATA.bus/), "R3"),
        'TMP', new Register($this->get(qw/DATA.bus TMP.s TMP.e TMP.bus/), "TMP"),
        'BUS1', new BUS1($this->get(qw/TMP.bus BUS1.bit1 BUS1.bus/)),
    ) ;

    # ALU
    $this->put(
        "ACC.s", NewWire())
        "ACC.e", NewWire())
        "ALU.bus", new BUS(),
        "ALU.ci" , NewWire())
        "ALU.op", new BUS(3),
        "ALU.co", NewWire())
        "ALU.eqo", NewWire())
        "ALU.alo", NewWire())
        "ALU.z", NewWire())
        "FLAGS.e", WIRE->on(), # FLAGS.e is always on
        "FLAGS.s", NewWire())
    ) ;
    $this->put(
        "ACC", new Register($this->get(qw/ALU.bus ACC.s ACC.e DATA.bus/), "ACC"),
        "ALU", new ALU($this->get(qw/DATA.bus BUS1.bus ALU.ci ALU.op ALU.bus ALU.co ALU.eqo ALU.alo ALU.z/)),
    ) ;
    $this->put(
        "FLAGS", new Register(
            BUS->wrap(
                $this->get("ALU")->co(), $this->get("ALU")->alo(), $this->get("ALU")->eqo(), $this->get("ALU")->z(),
                map { WIRE->off() } (0..3)
            ),
            $this->get(qw/FLAGS.s FLAGS.e/),
            # We DO NOT hook up the ALU carry in just yet, we will do that when we setup ALU instructions processing
            BUS->wrap(
                map { NewWire())} (0..3),
                map { WIRE->off() } (0..3),
            ), "FLAGS"),
    ) ;

    # CLOCK & STEPPER
    $this->put(
        "CLK.clk", NewWire())
        "CLK.clke", NewWire())
        "CLK.clks", NewWire())
        "STP.bus", new BUS(7),
    ) ;
    $this->put(
        "CLK" , new CLOCK($this->get(qw/CLK.clk CLK.clke CLK.clks/)),
        "STP" , new STEPPER($this->get(qw/CLK.clk STP.bus/)),
    ) ;

    # I/O
    $this->put(
        "IO.clks", NewWire())
        "IO.clke", NewWire())
        "IO.da", NewWire())
        "IO.io", NewWire())
    ) ;
    $this->put(
        "IO.bus", BUS->wrap($this->get(qw/IO.clks IO.clke IO.da IO.io/)),
    ) ;
    $this->put(
        "IO.adapter", new IOADAPTER($this->get(qw/DATA.bus IO.bus/)),
    ) ;


    # Hook up the FLAGS Register co output to the ALU ci, adding the AND gate describes in the Errata #2
    # Errata stuff: http://www.buthowdoitknow.com/errata.html
    # Naively: new CONN($this->get("FLAGS")->os()->wire(0), $this->get("ALU")->ci()) ;
    my $weor = NewWire());
    my $wco = NewWire());
    new MEMORY($this->get("FLAGS")->os()->wire(0), $this->get("TMP")->s(), $wco) ;
    new AND($wco, $weor, $this->get("ALU")->ci()) ;
    $this->put("ALU.ci.ena.eor", new ORe($weor)) ;

    if ($opts{'instproc'}){
        $this->instproc() ;
    }
    if ($opts{'instimpl'}){
        $this->instimpl() ;
    }
    if ($opts{'insts'}){
        require Instructions ;
        my $insts = $opts{'insts'} ;
        my @insts = ($insts =~ /^all$/i ? sort keys %INSTRUCTIONS::INSTS : @{$opts{'insts'}}) ;
        foreach my $i (@insts){
            $INSTRUCTIONS::INSTS{$i}->($this) ;
        }
    }
    if ($opts{'devs'}){
        require Devices ;
        my $devs = $opts{'devs'} ;
        my @devs = ($devs =~ /^all$/i ? sort keys %DEVICES::DEVS : @{$opts{'devs'}}) ;
        foreach my $d (@devs){
            $DEVICES::DEVS{$d}->($this) ;
        }
    }

    return $this ;
}


sub instproc {
    my $this = shift ;

    # Add instruction related registers
    $this->put(
        "IAR.s", NewWire())
        "IAR.e", NewWire())
        "IR.s", NewWire())
        "IR.e", WIRE->on(), # IR.e is always on
        "IR.bus", new BUS(),
    ) ;
    $this->put(
        "IAR", new Register($this->get(qw/DATA.bus IAR.s IAR.e DATA.bus/), "IAR"),
        "IR", new Register($this->get(qw/DATA.bus IR.s IR.e IR.bus/), "IR"),
    ) ;

    # DEBUG hook
    $this->get("IAR.s")->prehook(sub {
        if ($_[0]){
            my $n = oct('0b' . $this->get("IAR")->power()) ;
            my $code = $BREADBOARD::DEBUG[$n] ;
            if ($code){
                my $BB = $this ;
                eval $code ;
                if ($@){
                    warn "DEBUG code for instruction $n failed to compile:" ;
                    warn "$@\n" ;
                }
            }
        }
    }) ;

    # ALL ENABLES
    for my $e (qw/IAR RAM ACC/){
        my $w = NewWire());
        new AND($this->get("CLK.clke"), $w, $this->get("$e.e")) ;
        $this->put("$e.ena.eor", new ORe($w)) ;
    }
    $this->put("BUS1.bit1.eor", new ORe($this->get("BUS1.bit1"))) ;

    # ALL SETS
    for my $s (qw/IR RAM.MAR IAR ACC RAM TMP FLAGS/){
        my $w = NewWire());
        new AND($this->get("CLK.clks"), $w, $this->get("$s.s")) ;
        $this->put("$s.set.eor", new ORe($w)) ;
    }

    # Hook up the circuit used to process the first 3 steps of each cycle (see page 108 in book), i.e
    # - Load IAR to MAR and increment IAR in AC
    # - Load the instruction from RAM into IR
    # - Increment the IAR from ACC
    $this->get("BUS1.bit1.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("IAR.ena.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("RAM.MAR.set.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("ACC.set.eor")->add($this->get("STP.bus")->wire(0)) ;

    $this->get("RAM.ena.eor")->add($this->get("STP.bus")->wire(1)) ;
    $this->get("IR.set.eor")->add($this->get("STP.bus")->wire(1)) ;

    $this->get("ACC.ena.eor")->add($this->get("STP.bus")->wire(2)) ;
    $this->get("IAR.set.eor")->add($this->get("STP.bus")->wire(2)) ;
}


sub instimpl {
    my $this = shift ;

    # Then, we set up the parts that are required to actually implement instructions, i.e.
    # - Connect the decoders for the enable and set operations on R0-R3
    $this->put(
        "REGA.e", NewWire())
        "REGB.e", NewWire())
        "REGB.s", NewWire())
    ) ;
    $this->put(
        "REGA.ena.eor", new ORe($this->get("REGA.e")),
        "REGB.ena.eor", new ORe($this->get("REGB.e")),
        "REGB.set.eor", new ORe($this->get("REGB.s")),
    ) ;

    # s side
    my @sdeco = () ;
    for my $s (qw/R0 R1 R2 R3/){
        my $w = NewWire());
        new ANDn(3, BUS->wrap($this->get("CLK.clks"), $this->get("REGB.s"), $w), $this->get("$s.s")) ;
        push @sdeco, $w ;
    }
    $this->put("REGB.s.dec", new DECODER(2, BUS->wrap($this->get("IR")->os()->wire(6), $this->get("IR")->os()->wire(7)), BUS->wrap(@sdeco))) ;

    # e side
    my @edecoa = () ;
    my @edecob = () ;
    for my $s (qw/R0 R1 R2 R3/){
        my $wora = NewWire());
        my $worb = NewWire());
        new OR($wora, $worb, $this->get("$s.e")) ;

        my $wa = NewWire());
        new ANDn(3, BUS->wrap($this->get("CLK.clke"), $this->get("REGA.e"), $wa), $wora) ;
        push @edecoa, $wa ;
        my $wb = NewWire());
        new ANDn(3, BUS->wrap($this->get("CLK.clke"), $this->get("REGB.e"), $wb), $worb) ;
        push @edecob, $wb ;
    }
    $this->put("REGA.e.dec", new DECODER(2, BUS->wrap($this->get("IR")->os()->wire(4), $this->get("IR")->os()->wire(5)), BUS->wrap(@edecoa))) ;
    $this->put("REGB.e.dec", new DECODER(2, BUS->wrap($this->get("IR")->os()->wire(6), $this->get("IR")->os()->wire(7)), BUS->wrap(@edecob))) ;

    # Finally, install the instruction decoder
    $this->put('INST.bus', new BUS()) ;
    my $notalu = NewWire());
    new NOT($this->get("IR")->os()->wire(0), $notalu) ;
    my $idec = new DECODER(3, BUS->wrap(map { $this->get("IR")->os()->wire($_) } (1,2,3)), new BUS()) ;
    for (my $j = 0 ; $j < 8 ; $j++){
        new AND($notalu, $idec->os()->wire($j), $this->get("INST.bus")->wire($j)) ;
    }
    # Not required to store it.
    # $this->put('INST.dec', $idec) ;

    # Now, setting up instruction circuits involves:
    # - Hook up to the proper wire of INST.bus
    # - Wire up the logical circuit and attach it to proper step wires
    # - Use the "elastic" OR gates (xxx.eor) to enable and set
}



sub show {
    my $this = shift ;

    my $str = "" ;
    $str .= $this->get("CLK")->show() ;
    $str .= $this->get("STP")->show() ;
    $str .= "BUS:" . $this->get("DATA.bus")->show() . "  " ;
    $str .= join("  ", map { $this->get($_)->show() } qw/TMP BUS1 ACC FLAGS R0 R1 R2 R3/) . "\n" ;
    $str .= $this->get("ALU")->show(oct('0b' . $this->get("ALU.op")->power())) ;
    $str .= $this->get("RAM")->show() ;
    if ($this->{opts}->{instproc}){
        $str .= "CU:\n" ;
        $str .= "  " . $this->get("IAR")->show() . "  " .  $this->get("IR")->show() ;
        $str .= "  INST.bus:" . $this->get("INST.bus")->power() ;
        $str .= "  REGA.e:" . $this->get("REGA.e")->power() . '/' . $this->get("REGA.e.dec")->os()->power() ;
        $str .= "  REGB.e:" . $this->get("REGB.e")->power() . '/' . $this->get("REGB.e.dec")->os()->power() ;
        $str .= "  REGB.s:" . $this->get("REGB.s")->power() . '/' . $this->get("REGB.s.dec")->os()->power() ;
        $str .= "\nIO:\n" ;
        $str .= "  IO.clks:" . $this->get("IO.clks")->power() ;
        $str .= "  IO.clke:" . $this->get("IO.clke")->power() ;
        $str .= "  IO.da:" . $this->get("IO.da")->power() ;
        $str .= "  IO.io:" . $this->get("IO.io")->power() . "\n" ;
        $str .= $this->get("IO.adapter")->show() ;
    }
    $str .= "\n" ;

    return $str ;
}


#
# Convenience methods
#


sub setRAM {
    my $this = shift ;
    my $addr = shift ;
    my $data = shift ;

    $this->get("DATA.bus")->power($addr) ;
    $this->get("RAM.MAR.s")->power(1) ;
    $this->get("RAM.MAR.s")->power(0) ;
    $this->get("DATA.bus")->power($data) ;
    $this->get("RAM.s")->power(1) ;
    $this->get("RAM.s")->power(0) ;
}


sub setREG {
    my $this = shift ;
    my $reg = shift ;
    my $data = shift ;

    $this->get("DATA.bus")->power($data) ;
    $this->get("$reg.s")->power(1) ;
    $this->get("$reg.s")->power(0) ;
}


# Initialize RAM contents from a file.
# This file should be the output of a jcsasm program
sub initRAM {
    my $this = shift ;
    my $file = shift ;

    open(RAMF, "<$file") or croak("Can't open RAM init file '$file': $!") ;
    return $this->initRAMh(\*RAMF) ;
}


# Initialize RAM contents from a file.
# This file should be the output of a jcsasm program
sub initRAMh {
    my $this = shift ;
    my $handle = shift ;

    return $this->initRAMl($this->readINSTS($handle)) ;
}


sub initRAMl {
    my $this = shift ;
    my $lines = shift ;

    my $addr = 0 ;
    foreach my $inst (@{$this->readINSTSl($lines)}){
        $this->setRAM(sprintf("%08b", $addr++), $inst) ;
    }

    # Important to reset the DATA.bus after loading RAM as it will leave data there
    # that will mess up the rest of the instruction loading.
    $this->get("DATA.bus")->power("00000000") ;
}


# This file should be the output of a jcsasm program
sub readINSTS {
    my $this = shift ;
    my $handle = shift ;

    my @lines = (<$handle>) ;
    return $this->readINSTSl(\@lines) ;
}


sub readINSTSl {
    my $this = shift ;
    my $lines = shift ;

    my @insts = () ;
    foreach my $line (@{$lines}){
        chomp($line) ;
        $line =~ s/[^[:print:]]//g ;
        if ($line =~ s/^#DEBUG//){
            $BREADBOARD::DEBUG[scalar(@insts)] = $line ;
        }
        next unless $line =~ /^([01]{8})\b/ ;
        my $inst = $1 ;
        push @insts, $inst ;
    }

    return \@insts ;
}


sub qtick {
    my $this = shift ;
    my $nb = shift || 1 ;

    map { $this->get("CLK")->qtick() } (1..$nb) ;
}


sub on_halt {
    my $this = shift ;
    my $sub = shift ;

    if (defined($sub)){
        $this->{halt} = $sub ;
    }

    return $this->{halt} ;
}


sub tick {
    my $this = shift ;

    return $this->get("CLK")->tick(@_) ;
}


sub step {
    my $this = shift ;

    return $this->tick(@_) ;
}


sub inst {
    my $this = shift ;
    my $n = shift || 1 ;

    my $cur = $this->get("STP")->step() ;
    croak("Can't step mid-instruction (step: $cur)!") unless (($cur == 0)||($cur == 6)) ;
    map {
        map { $this->get("CLK")->tick() } (0..5) ;
    } (1..$n) ;
}


sub start {
    my $this = shift ;

    $this->get("CLK")->start(@_) ;
}


*/
