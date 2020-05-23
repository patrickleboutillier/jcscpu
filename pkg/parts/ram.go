package parts

import (
	"fmt"

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

	fast bool // Fast mode using prehooks and disconnected buses
	cur  int  // For fast mode
}

func NewRAM(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire) *RAM {
	this := newRAM(bas, g.NewWire(), bio, g.NewWire(), g.NewWire(), true)

	// Hooks that implement 'fast' mode
	wsa.AddPrehook(func(v bool) {
		if v {
			// Record the address on as.
			this.cur = this.as.GetPower()
		}
		this.sa.SetPower(v)
	})
	ws.AddPrehook(func(v bool) {
		// Copy bus value and relay to the cell's s wire
		r := this.cells[this.cur]
		if v {
			r.is.SetPower(this.io.GetPower())
		}
		r.s.SetPower(v)
	})
	we.AddPrehook(func(v bool) {
		// Relay to the cell's e wire and copy to the bus
		r := this.cells[this.cur]
		r.e.SetPower(v)
		if v {
			this.io.SetPower(r.os.GetPower())
		} else {
			this.io.SetPower(0)
		}
	})

	return this
}

func NewRAMSlow(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire) *RAM {
	return newRAM(bas, wsa, bio, ws, we, false)
}

func newRAM(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire, fast bool) *RAM {
	// Build the RAM circuit
	on := g.WireOn()
	busd := g.NewBusN(bas.GetSize())
	bus := busd
	if fast {
		bus = g.NewBus()
	}
	mar := NewRegister(bas, wsa, on, bus, "MAR")

	n := bas.GetSize() / 2
	n2 := 1 << n
	wxs := g.NewBusN(n2)
	wys := g.NewBusN(n2)
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

			bus := bio
			if fast {
				bus = g.NewBus()
			}
			cells[idx] = NewRegister(bus, wso, weo, bus, fmt.Sprintf("RAM[%d]", idx))
		}
	}

	this := &RAM{bas, bio, wsa, ws, we, mar, cells, n2 * n2, fast, -1}

	return this
}

func (this *RAM) GetMAR() *Register {
	return this.mar
}

func (this *RAM) GetCell(n int) *Register {
	if (n < 0) || (n >= this.n) {
		panic(fmt.Errorf("Invalid cell index %d", n))
	}
	return this.cells[n]
}

func (this *RAM) String() string {
	str := fmt.Sprintf("RAM:\n  %s  %s\n", this.mar.String(), this.cells[this.mar.GetPower()].String())
	//foreach my $a (@addrs){
	//   $str .= "  " . $this->{GRID}->{$a}->show() ;
	// }
	return str
}

/*


sub peek {
    my $this = shift ;
    my $addr = shift ;

    return $this->{GRID}->{$addr}->power() ;
}


sub dump {
    my $this = shift ;
    my $max = shift ;

    my $n = 0 ;
    foreach my $addr (sort keys %{$this->{GRID}}){
        my $n = oct("0b$addr") ;
        printf("$addr (%3d): %s\n", $n, $this->{GRID}->{$addr}->power()) ;
        last if (($max > 0)&&($n++ >= $max)) ;
    }
}

*/
