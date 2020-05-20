package parts

import (
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
STEPPER
*/
type Stepper struct {
	clk, rst *g.Wire
	os       *g.Bus
	s1       *g.OR
	s26      []*g.AND
	s7       *g.Wire
	ms       []*Memory
}

func NewStepper(wclk *g.Wire, bos *g.Bus) *Stepper {
	wrst := g.NewWire()
	wnrm1 := g.NewWire()
	g.NewNOT(wrst, wnrm1)
	wnco1 := g.NewWire()
	g.NewNOT(wclk, wnco1)
	wmsn := g.NewWire()
	g.NewOR(wrst, wnco1, wmsn)
	wmsnn := g.NewWire()
	g.NewOR(wrst, wclk, wmsnn)

	// M1
	wn12b := g.NewWire()
	s1 := g.NewOR(wrst, wn12b, bos.GetWire(0))
	wm112 := g.NewWire()
	m1 := NewNamedMemory(wnrm1, wmsn, wm112, " 1")

	// M12
	wn12a := g.NewWire()
	g.NewNOT(wn12a, wn12b)
	m12 := NewNamedMemory(wm112, wmsnn, wn12a, "12")

	// M2
	wn23b := g.NewWire()
	s2 := g.NewAND(wn12a, wn23b, bos.GetWire(1))
	wm223 := g.NewWire()
	m2 := NewNamedMemory(wn12a, wmsn, wm223, " 2")

	// M23
	wn23a := g.NewWire()
	g.NewNOT(wn23a, wn23b)
	m23 := NewNamedMemory(wm223, wmsnn, wn23a, "23")

	// M3
	wn34b := g.NewWire()
	s3 := g.NewAND(wn23a, wn34b, bos.GetWire(2))
	wm334 := g.NewWire()
	m3 := NewNamedMemory(wn23a, wmsn, wm334, " 3")

	// M34
	wn34a := g.NewWire()
	g.NewNOT(wn34a, wn34b)
	m34 := NewNamedMemory(wm334, wmsnn, wn34a, "34")

	// M4
	wn45b := g.NewWire()
	s4 := g.NewAND(wn34a, wn45b, bos.GetWire(3))
	wm445 := g.NewWire()
	m4 := NewNamedMemory(wn34a, wmsn, wm445, " 4")

	// M45
	wn45a := g.NewWire()
	g.NewNOT(wn45a, wn45b)
	m45 := NewNamedMemory(wm445, wmsnn, wn45a, "45")

	// M5
	wn56b := g.NewWire()
	s5 := g.NewAND(wn45a, wn56b, bos.GetWire(4))
	wm556 := g.NewWire()
	m5 := NewNamedMemory(wn45a, wmsn, wm556, " 5")

	// M56
	wn56a := g.NewWire()
	g.NewNOT(wn56a, wn56b)
	m56 := NewNamedMemory(wm556, wmsnn, wn56a, "56")

	// M6
	wn67b := g.NewWire()
	s6 := g.NewAND(wn56a, wn67b, bos.GetWire(5))
	wm667 := g.NewWire()
	m6 := NewNamedMemory(wn56a, wmsn, wm667, " 6")

	// M67
	g.NewNOT(bos.GetWire(6), wn67b)
	m67 := NewNamedMemory(wm667, wmsnn, bos.GetWire(6), "67")
	s7 := bos.GetWire(6)

	/*
	   this = {
	       clk => wclk,
	       rst => wrst,
	       os => bos,
	       Ss => [s1, s2, s3, s4, s5, s6, bos.GetWire(6)],
	       Ms => [m1, m12, m2, m23, m3, m34, m4, m45, m5, m56, m6, m67],
	   } ;
	   bless this, class ;

	   // Hook to forward signals to the s inputs to ensure they arrive before the i inputs.
	   wclk->prehook(sub {
	       v = shift ;
	       wmsn->power(! v, 1) ;
	       wmsnn->power(v, 1) ;
	   }) ;

	   wrst->prehook(sub {
	       v = shift ;
	       if (v){
	           wmsn->power(v, 1) ;
	           wmsnn->power(v, 1) ;
	       }
	       else {
	           wmsn->power(! wclk->power(), 1) ;
	           wmsnn->power(wclk->power(), 1) ;
	       }
	   }) ;

	   // In it's current design. the stepper goes to setup 1 as soon as it's powered on.
	   // We don't want that. We want the stepper to be in a state where the first clock tick
	   // will *bring it* to step 1.
	   // To do this, we fake 6 ticks, and turn off (softly) the power on step 7.
	   // But we have to simulate the ticks without touching wclk, which make the clock tick!
	   // We need to signal the wmsn and wmsnn Wire directly.
	   map {
	       wmsn->power(0) ;
	       wmsnn->power(1) ;
	       wmsn->power(1) ;
	       wmsnn->power(0) ;
	   } (0..5) ;
	   bos.GetWire(6)->power(0, 1) ;

	   // Finally, loop step 7 to the reset Wire.
	   NewCONN(bos.GetWire(6), wrst) ;

	*/

	g.NewCONN(bos.GetWire(6), wrst)

	s26 := []*g.AND{s2, s3, s4, s5, s6}
	ms := []*Memory{m1, m12, m2, m23, m3, m34, m4, m45, m5, m56, m6, m67}

	return &Stepper{wclk, wrst, bos, s1, s26, s7, ms}
}

/*
// Steps starting at 1, like in the book.
sub step {
    this = shift ;

    for (j = 0 ; j < 7 ; j++){
        return (j + 1) if this->{os}.GetWire(j)->power() ;
    }

    // When stepper has Not yet been through a tick.
    return 0 ;
}


sub show {
    this = shift ;

    clk = this->{clk}->power() ;
    rst = this->{rst}->power() ;
    steps = this->{os}->power() ;
    my @Ss = @{this->{Ss}} ;
    my @Ms = @{this->{Ms}} ;

    str = "STEPPER(" . this->step() . "): rst:rst, clk:clk, steps:steps\n  " ;
    foreach S (@Ss){
        str .= "  " . S->show() . "                " ;
    }
    str .= "\n  " ;
    foreach M (@Ms){
        str .= M->show() . "  " ;
    }
    str .= "\n" ;

    return str ;
}


1 ;
*/
