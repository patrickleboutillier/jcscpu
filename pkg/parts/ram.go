package parts

import (
	"fmt"

	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
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
	cur    int  // For fast mode
	powers []int
}

func NewRAM(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire) *RAM {
	// Use classic RAM circuit if we are using an 8 bit architecture
	if (a.GetArchBits() > 8){
		return NewRAMFast(bas, wsa, bio, ws, we)
	}
	return NewRAMClassic(bas, wsa, bio, ws, we)
}

func NewRAMFast(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire) *RAM {
	// Build the RAM circuit
	on := g.WireOn()
	busd := g.NewBusN(bas.GetSize())
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
	busd := g.NewBusN(bas.GetSize())
	mar := NewRegister(bas, wsa, on, busd, "MAR")

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
	if (n < 0) || (n >= this.n) {
		panic(fmt.Errorf("Invalid cell index %d", n))
	}
	if this.fast {
		return this.powers[n]
	} 
	return this.cells[n].GetPower()
}

func (this *RAM) String() string {
	str := fmt.Sprintf("RAM:\n  %s  ", this.mar.String())

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
