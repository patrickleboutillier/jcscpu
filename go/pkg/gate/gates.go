package gate

/*
NAND
*/
type nand struct {
	a, b, c *wire
}

func NewNAND(wa *wire, wb *wire, wc *wire) *nand {
	this := &nand{wa, wb, wc}
	wa.Connect(this)
	wb.Connect(this)
	wc.Connect(this)
	this.Signal()
	return this
}

// No getters/setters here, this will be called a lot!
func (this *nand) Signal() {
	c := (!(this.a.power && this.b.power))

	if (this.c.power != c) || this.c.soft {
		this.c.SetPower(c)
	}
}

/*
NOT
*/
type not struct {
	a, b *wire
}

func NewNOT(wa *wire, wb *wire) *not {
	this := &not{wa, wb}
	NewNAND(wa, wa, wb)
	return this
}

/*
CONN
*/
type conn struct {
	a, b *wire
}

func NewCONN(wa *wire, wb *wire) *conn {
	this := &conn{wa, wb}
	NewAND(wa, wa, wb)
	return this
}

/*
AND
*/
type and struct {
	a, b, c *wire
}

func NewAND(wa *wire, wb *wire, wc *wire) *and {
	this := &and{wa, wb, wc}
	w := NewWire()
	NewNAND(wa, wb, w)
	NewNOT(w, wc)
	return this
}

/*
OR
*/
type or struct {
	a, b, c *wire
}

func NewOR(wa *wire, wb *wire, wc *wire) *or {
	this := &or{wa, wb, wc}
	wic := NewWire()
	wid := NewWire()
	NewNOT(wa, wic)
	NewNOT(wb, wid)
	NewNAND(wic, wid, wc)
	return this
}

/*
XOR
*/
type xor struct {
	a, b, c *wire
}

func NewXOR(wa *wire, wb *wire, wc *wire) *xor {
	this := &xor{wa, wb, wc}
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


package ANDn ;
use strict ;


sub new {
    my $class = shift ;
    my $n = shift ;
    my $bis = shift ;
    my $wo = shift ;
    my $name = shift ;

    die ("Invalid ANDn number of inputs $n") unless ($n >= 2) ;
    # Todo: make sure bis->n() == $n
    my $last = new AND($bis->wire(0), $bis->wire(1), (($n == 2) ? $wo : new WIRE()), "$name/AND[0]") ;
    for (my $j = 0 ; $j < ($n-2) ; $j++){
            my $next = new AND($last->{c}, $bis->wire($j+2), (($n == ($j+3)) ? $wo : new WIRE()), "$name/AND[" . ($j+1) . "]") ;
            $last = $next ;
    }

    my $this = {
        is => $bis,
        o => $wo,
        n => $n,
    } ;
    bless $this, $class ;

    return $this ;
}


sub i {
    my $this = shift ;
    my $n = shift ;
    die ("Invalid input index $n") unless (($n >= 0)&&($n < $this->{n})) ;
    return $this->{is}->wire($n) ;
}


sub n {
    my $this = shift ;
    return $this->{n} ;
}


package ORn ;
use strict ;


sub new {
    my $class = shift ;
    my $n = shift ;
    my $bis = shift ;
    my $wo = shift ;
    my $name = shift ;

    die ("Invalid ORn number of inputs $n") unless ($n >= 2) ;
    my $last = new OR($bis->wire(0), $bis->wire(1), (($n == 2) ? $wo : new WIRE()), "$name/OR[0]") ;
    for (my $j = 0 ; $j < ($n-2) ; $j++){
            my $next = new OR($last->c(), $bis->wire($j+2), (($n == ($j+3)) ? $wo : new WIRE()), "$name/OR[" . ($j+1) . "]") ;
            $last = $next ;
    }

    my $this = {
        is => $bis,
        o => $wo,
        n => $n,
    } ;
    bless $this, $class ;

    return $this ;
}


sub i {
    my $this = shift ;
    my $n = shift ;
    die ("Invalid input index $n") unless (($n >= 0)&&($n < $this->{n})) ;
    return $this->{is}->wire($n) ;
}


sub n {
    my $this = shift ;
    return $this->{n} ;
}


package ORe ;
use strict ;
use Carp ;


sub new {
    my $class = shift ;
    my $wo = shift ;
    my $name = shift ;

    my $this = {
        orn => new ORn(6, BUS->wrap(map { new WIRE(0) } (0..5)), $wo),
        n => 0,
    } ;
    bless $this, $class ;

    return $this ;
}


sub add {
    my $this = shift ;
    my $wi = shift ;

    croak("Elastic OR has reached maximum capacity of 6") if $this->{n} >= 6 ;
    new CONN($wi, $this->{orn}->i($this->{n})) ;
    $this->{n}++ ;
}


package ADD ;
use strict ;


sub new {
    my $class = shift ;
    my $wa = shift ;
    my $wb = shift ;
    my $wci = shift ;
    my $wsum = shift ;
    my $wco = shift ;
    my $name = shift ;

    my $wi = new WIRE() ;
    my $wcoa = new WIRE() ;
    my $wcob = new WIRE() ;
    new XOR($wa, $wb, $wi, "$name/XOR[1]") ;
    new XOR($wi, $wci, $wsum, "$name/XOR[2]") ;
    new AND($wci, $wi, $wcoa, "$name/AND[1]") ;
    new AND($wa, $wb, $wcob, "$name/AND[2]") ;
    new OR($wcoa, $wcob, $wco, "$name/OR[]") ;

    my $this = {
        a => $wa,
        b => $wb,
        carry_in => $wci,
        sum => $wsum,
        carry_out => $wco,
        name => $name,
    } ;
    bless $this, $class ;

    return $this ;
}


 1 ;


__DATA__
package ANDe ;
use strict ;


sub new {
    my $class = shift ;
    my $wo = shift ;
    my $name = shift ;

    my $this = {
        orn => new ANDn(6, BUS->wrap(map { new WIRE(1) } (0..5)), $wo),
        n => 0,
    } ;
    bless $this, $class ;

    return $this ;
}


sub add {
    my $this = shift ;
    my $wi = shift ;

    croak("Elastic AND has reached maximum capacity of 6") if $this->{n} >= 6 ;
    new CONN($wi, $this->{orn}->i($this->{n})) ;
    $this->{n}++ ;
}

*/
