package gates

import "fmt"

var NbNANDs int

/*
NAND
*/
type NAND struct {
	a, b, c *Wire
}

func NewNAND(wa *Wire, wb *Wire, wc *Wire) *NAND {
	NbNANDs++
	this := &NAND{wa, wb, wc}
	wa.Connect(this)
	wb.Connect(this)
	wc.Connect(this)
	this.Signal()
	return this
}

// No getters/setters here, this will be called a lot!
func (this *NAND) Signal() {
	c := (!(this.a.power && this.b.power))

	if (this.c.power != c) || this.c.soft {
		this.c.SetPower(c)
	}
}

/*
NOT
*/
type NOT struct {
	a, b *Wire
}

func NewNOT(wa *Wire, wb *Wire) *NOT {
	this := &NOT{wa, wb}
	NewNAND(wa, wa, wb)
	return this
}

/*
CONN
*/
type CONN struct {
	a, b *Wire
}

func NewCONN(wa *Wire, wb *Wire) *CONN {
	this := &CONN{wa, wb}
	NewAND(wa, wa, wb)
	return this
}

/*
AND
*/
type AND struct {
	a, b, c *Wire
}

func NewAND(wa *Wire, wb *Wire, wc *Wire) *AND {
	this := &AND{wa, wb, wc}
	w := NewWire()
	NewNAND(wa, wb, w)
	NewNOT(w, wc)
	return this
}

func (this *AND) String() string {
	return fmt.Sprintf("AND[%s/%s/%s]", this.a.String(), this.b.String(), this.c.String())
}

/*
OR
*/
type OR struct {
	a, b, c *Wire
}

func NewOR(wa *Wire, wb *Wire, wc *Wire) *OR {
	this := &OR{wa, wb, wc}
	wic := NewWire()
	wid := NewWire()
	NewNOT(wa, wic)
	NewNOT(wb, wid)
	NewNAND(wic, wid, wc)
	return this
}

func (this *OR) String() string {
	return fmt.Sprintf(" OR[%s/%s/%s]", this.a.String(), this.b.String(), this.c.String())
}

/*
XOR
*/
type XOR struct {
	a, b, c *Wire
}

func NewXOR(wa *Wire, wb *Wire, wc *Wire) *XOR {
	this := &XOR{wa, wb, wc}
	wic := NewWire()
	wid := NewWire()
	wie := NewWire()
	wif := NewWire()
	NewNOT(wa, wic)
	NewNOT(wb, wid)
	NewNAND(wic, wb, wie)
	NewNAND(wa, wid, wif)
	NewNAND(wie, wif, wc)
	return this
}

/*
ANDn
*/
type ANDn struct {
	n  int
	is *Bus
	o  *Wire
}

func NewANDn(bis *Bus, wo *Wire) *ANDn {
	n := bis.GetSize()
	this := &ANDn{n, bis, wo}

	if n < 2 {
		panic(fmt.Errorf("Invalid ANDn number of inputs %d", n))
	}

	var o *Wire
	if n == 2 {
		o = wo
	} else {
		o = NewWire()
	}
	last := NewAND(bis.GetWire(0), bis.GetWire(1), o)
	for j := 0; j < (n - 2); j++ {
		var o *Wire
		if n == (j + 3) {
			o = wo
		} else {
			o = NewWire()
		}
		next := NewAND(last.c, bis.GetWire(j+2), o)
		last = next
	}

	return this
}

/*
ORn
*/
type ORn struct {
	n  int
	is *Bus
	o  *Wire
}

func NewORn(bis *Bus, wo *Wire) *ORn {
	n := bis.GetSize()
	this := &ORn{n, bis, wo}

	if n < 2 {
		panic(fmt.Errorf("Invalid ORn number of inputs %d", n))
	}

	var o *Wire
	if n == 2 {
		o = wo
	} else {
		o = NewWire()
	}
	last := NewOR(bis.GetWire(0), bis.GetWire(1), o)
	for j := 0; j < (n - 2); j++ {
		if n == (j + 3) {
			o = wo
		} else {
			o = NewWire()
		}
		next := NewOR(last.c, bis.GetWire(j+2), o)
		last = next
	}

	return this
}

/*
ORe
*/
type ORe struct {
	orn *ORn
	o   *Wire
	n   int
}

func NewORe(wo *Wire) *ORe {
	return &ORe{NewORn(NewBusN(6), wo), wo, 0}
}

func (this *ORe) AddWire(w *Wire) {
	if this.n >= 6 {
		panic(fmt.Errorf("Elastic OR has reached maximum capacity of 6"))
	}
	NewCONN(w, this.orn.is.GetWire(this.n))
	this.n++
}

/*
ADD
*/
type ADD struct {
	a, b, c, ci, co *Wire
}

func NewADD(wa *Wire, wb *Wire, wci *Wire, wc *Wire, wco *Wire) *ADD {
	wi := NewWire()
	wcoa := NewWire()
	wcob := NewWire()
	NewXOR(wa, wb, wi)
	NewXOR(wi, wci, wc)
	NewAND(wci, wi, wcoa)
	NewAND(wa, wb, wcob)
	NewOR(wcoa, wcob, wco)
	return &ADD{wa, wb, wc, wci, wco}
}

/*
CMP
*/
type CMP struct {
	a, b, c, eqi, ali, eqo, alo *Wire
}

func NewCMP(wa *Wire, wb *Wire, weqi *Wire, wali *Wire, wc *Wire, weqo *Wire, walo *Wire) *CMP {
	w23 := NewWire()
	w45 := NewWire()
	NewXOR(wa, wb, wc)
	NewNOT(wc, w23)
	NewAND(weqi, w23, weqo)
	NewANDn(WrapBusV(weqi, wa, wc), w45)
	NewOR(wali, w45, walo)
	return &CMP{wa, wb, wc, weqi, wali, weqo, walo}
}

/*

package CMP ;
use strict ;


sub new {
    my $class = shift ;
    my $wa = shift ;
    my $wb = shift ;
    my $weqi = shift ;
    my $wali = shift ;
    my $wc = shift ;
    my $weqo = shift ;
    my $walo = shift ;
    my $name = shift ;

    my $w23 = new WIRE() ;
    my $w45 = new WIRE() ;
    new XOR($wa, $wb, $wc, "$name/XOR[1]") ;
    new NOT($wc, $w23, "$name/NOT[2]") ;
    new AND($weqi, $w23, $weqo, "$name/AND[3]") ;
    new ANDn(3, BUS->wrap($weqi, $wa, $wc), $w45, "$name/AND3[4]") ;
    new OR($wali, $w45, $walo, "$name/NAND[g3]") ;

    my $this = {
        a => $wa,
        b => $wb,
        c => $wc,
        eqi => $weqi,
        ali => $wali,
        eqo => $weqo,
        alo => $walo,
        name => $name,
    } ;
    bless $this, $class ;

    return $this ;
}


*/
