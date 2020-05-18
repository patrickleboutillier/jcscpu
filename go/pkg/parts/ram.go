package parts

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
RAM
*/
type RAM struct {
	as, io   *g.Bus
	sa, s, e *g.Wire
	mar      *Register
	cells    []*Register
}

func NewRAM(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire) *RAM {
	//Build the RAM circuit
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

	this := &RAM{bas, bio, wsa, ws, we, mar, cells}

	return this
}

func (this *RAM) GetMAR() *Register {
	return this.mar
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
