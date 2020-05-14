package gates

/*
NAND
*/
type NAND struct {
	a, b, c *Wire
}

func NewNAND(wa *Wire, wb *Wire, wc *Wire) *NAND {
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
    my $last = new AND($bis->Wire(0), $bis->Wire(1), (($n == 2) ? $wo : new WIRE()), "$name/AND[0]") ;
    fOR (my $j = 0 ; $j < ($n-2) ; $j++){
            my $next = new AND($last->{c}, $bis->Wire($j+2), (($n == ($j+3)) ? $wo : new WIRE()), "$name/AND[" . ($j+1) . "]") ;
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
    return $this->{is}->Wire($n) ;
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
    my $last = new OR($bis->Wire(0), $bis->Wire(1), (($n == 2) ? $wo : new WIRE()), "$name/OR[0]") ;
    fOR (my $j = 0 ; $j < ($n-2) ; $j++){
            my $next = new OR($last->c(), $bis->Wire($j+2), (($n == ($j+3)) ? $wo : new WIRE()), "$name/OR[" . ($j+1) . "]") ;
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
    return $this->{is}->Wire($n) ;
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
        ORn => new ORn(6, BUS->wrap(map { new WIRE(0) } (0..5)), $wo),
        n => 0,
    } ;
    bless $this, $class ;

    return $this ;
}


sub add {
    my $this = shift ;
    my $wi = shift ;

    croak("Elastic OR has reached maximum capacity of 6") if $this->{n} >= 6 ;
    new CONN($wi, $this->{ORn}->i($this->{n})) ;
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
        ORn => new ANDn(6, BUS->wrap(map { new WIRE(1) } (0..5)), $wo),
        n => 0,
    } ;
    bless $this, $class ;

    return $this ;
}


sub add {
    my $this = shift ;
    my $wi = shift ;

    croak("Elastic AND has reached maximum capacity of 6") if $this->{n} >= 6 ;
    new CONN($wi, $this->{ORn}->i($this->{n})) ;
    $this->{n}++ ;
}

*/
