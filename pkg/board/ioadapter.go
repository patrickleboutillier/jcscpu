package board

import (
	"fmt"
	"log"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
	p "github.com/patrickleboutillier/jcscpu/pkg/parts"
)

/*
IOADAPTER
*/
type IOAdapter struct {
	n                                int
	cpu                              *g.Bus
	indata, inaddr, outdata, outaddr *g.Wire
	bdev                             *g.Bus
	devices                          []*IODevice
}

/*
IODEVICE
*/
type IODevice struct {
	id   int
	name string
	mem  *p.Memory
}

func NewIOAdapter(cpu *g.Bus, io *g.Bus) *IOAdapter {
	n := 16
	this := &IOAdapter{n: n, cpu: cpu, devices: make([]*IODevice, n, n)}

	// TODO: make sure n <= cpu.GetSize()

	// This decoder decodes the operation on the IO bus. There are only 4 wires that we are interested in:
	bop := g.NewBus(16)
	p.NewDecoder(io, bop)
	this.indata = bop.GetWire(0b0100)
	this.inaddr = bop.GetWire(0b0110)
	this.outdata = bop.GetWire(0b1001)
	this.outaddr = bop.GetWire(0b1011)

	// Now we create the decoder that will dispatch to the proper device.
	// We use the last 4 wires of CPU bus, which will give us support for 16 IO devices
	this.bdev = g.NewBus(this.n)
	cpuws := cpu.GetWires()
	p.NewDecoder(g.WrapBus(cpuws[len(cpuws)-4:]), this.bdev)

	e := io.GetWire(1)
	e.AddPrehook(func(v bool) {
		// This wire acts like an enabler, and when it looses power it must reset the bus.
		if !v {
			cpu.SetPower(0)
		}
	})

	return this
}

func (this *IOAdapter) IsActive(n int) bool {
	return this.devices[n].mem.GetM()
}

func (this *IOAdapter) IsRegistered(n int) bool {
	if this.devices[n] != nil {
		return true
	}
	return false
}

// Register a new device
func (this *IOAdapter) Register(BB *Breadboard, id int, name string, in func(), out func()) {
	if (id < 0) || (id >= this.n) {
		log.Panicf("Invalid device number %d", id)
	}
	if this.devices[id] != nil {
		log.Panicf("Device %s already registered at address %d", this.devices[id].name, id)
	}

	wmem := g.NewWire()
	mem := p.NewMemory(this.bdev.GetWire(id), this.outaddr, wmem)
	dev := &IODevice{id, name, mem}
	if in != nil {
		inhook := g.NewWire()
		g.NewAND(wmem, this.indata, inhook)
		inhook.AddPrehook(func(v bool) {
			if v && ((BB.CLK.GetTicks() % 6) == 4) {
				in()
			}
		})
	}
	if out != nil {
		outhook := g.NewWire()
		g.NewAND(wmem, this.outdata, outhook)
		outhook.AddPrehook(func(v bool) {
			if v && ((BB.CLK.GetTicks() % 6) == 3) {
				out()
			}
		})
	}

	this.devices[id] = dev
}

func (this *IOAdapter) String() string {
	str := ""
	for j := 0; j < this.n; j++ {
		if this.devices[j] != nil {
			str += fmt.Sprintf("  DEV(%s, %d): %s", this.devices[j].name, this.devices[j].id, this.devices[j].mem)
		}
	}

	return str
}
