package parts

import (
	"fmt"
	"os"
	"strings"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

/*
RAM
*/
type RAM struct {
	as, io   *g.Bus
	sa, s, e *g.Wire
	mar      *Register
	cells    []*Register
	n        int

	fast   bool
	cur    int // For fast mode
	powers []int
}

// Always fast mode, except if classic mode requested by an env var.
func NewRAM(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire) *RAM {
	env := os.Getenv("RAM_MODE")
	if (strings.ToUpper(env) == "CLASSIC") && (bas.GetSize() == 8) {
		return NewRAMClassic(bas, wsa, bio, ws, we)
	}
	return NewRAMFast(bas, wsa, bio, ws, we)
}

func NewRAMFast(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire) *RAM {
	// Build the RAM circuit
	on := g.WireOn()
	busd := g.NewBus(bas.GetSize())
	mar := NewRegister(bas, wsa, on, busd, "MAR")

	// Now we create the circuit
	n := 1 << bas.GetSize()
	powers := make([]int, n, n)
	this := &RAM{bas, bio, g.NewWire(), g.NewWire(), g.NewWire(), mar, nil, n, true, -1, powers}

	// Hooks that implement 'fast' mode
	wsa.AddPrehook(func(v bool) {
		if v {
			this.cur = this.as.GetPower()
		}
	})
	ws.AddPrehook(func(v bool) {
		if v {
			this.powers[this.cur] = this.io.GetPower()
		}
	})
	we.AddPrehook(func(v bool) {
		if v {
			this.io.SetPower(this.powers[this.cur])
		} else {
			this.io.SetPower(0)
		}
	})

	return this
}

func NewRAMClassic(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire) *RAM {
	// Build the RAM circuit
	on := g.WireOn()
	busd := g.NewBus(bas.GetSize())
	mar := NewRegister(bas, wsa, on, busd, "MAR")

	n := bas.GetSize() / 2
	n2 := 1 << n
	wxs := g.NewBus(n2)
	wys := g.NewBus(n2)
	NewDecoder(g.WrapBus(busd.GetWires()[0:n]), wxs)
	NewDecoder(g.WrapBus(busd.GetWires()[n:busd.GetSize()]), wys)

	// Now we create the circuit
	cells := make([]*Register, n2*n2, n2*n2)
	for x := 0; x < n2; x++ {
		for y := 0; y < n2; y++ {
			// Create the subcircuit to be used at each location
			wxo := g.NewWire()
			wso := g.NewWire()
			weo := g.NewWire()
			g.NewAND(wxs.GetWire(x), wys.GetWire(y), wxo)
			g.NewAND(wxo, ws, wso)
			g.NewAND(wxo, we, weo)
			idx := (x * n2) + y

			cells[idx] = NewRegister(bio, wso, weo, bio, fmt.Sprintf("RAM[%d]", idx))
		}
	}

	this := &RAM{bas, bio, wsa, ws, we, mar, cells, n2 * n2, false, -1, nil}

	return this
}

func (this *RAM) GetMAR() *Register {
	return this.mar
}

func (this *RAM) GetCellPower(n int) int {
	if this.fast {
		return this.powers[n]
	}
	return this.cells[n].GetPower()
}

func (this *RAM) String() string {
	str := fmt.Sprintf("RAM: %s  ", this.mar.String())

	f := fmt.Sprintf("%%0%db", this.as.GetSize())
	idx := this.mar.GetPower()
	addr := fmt.Sprintf(f, idx)
	cell := fmt.Sprintf(f, this.GetCellPower(idx))
	str += fmt.Sprintf("RAM[%s]:%s\n", addr, cell)

	//foreach my $a (@addrs){
	//   $str .= "  " . $this->{GRID}->{$a}->show() ;
	// }

	return str
}
