package parts

import (
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
ADDER
*/
type Adder struct {
	as, bs, cs *g.Bus
	ci, co     *g.Wire
}

func NewAdder(bas *g.Bus, bbs *g.Bus, wci *g.Wire, bcs *g.Bus, wco *g.Wire) *Adder {
	// Build the ADDer circuit
	twci := g.NewWire()
	twco := wco
	for j := 0; j < bas.GetSize(); j++ {
		tw := twci
		if j == (bas.GetSize() - 1) {
			tw = wci
		}
		g.NewADD(bas.GetWire(j), bbs.GetWire(j), tw, bcs.GetWire(j), twco)
		twco = twci
		twci = g.NewWire()
	}
	return &Adder{bas, bbs, bcs, wci, wco}
}

/*
SHIFTR
*/
type ShiftRight struct {
	is, os *g.Bus
	ci, co *g.Wire
}

func NewShiftRight(bis *g.Bus, wci *g.Wire, bos *g.Bus, wco *g.Wire) *ShiftRight {
	this := &ShiftRight{bis, bos, wci, wco}
	g.NewCONN(wci, bos.GetWire(0))
	for j := 1; j < bis.GetSize(); j++ {
		g.NewCONN(bis.GetWire(j-1), bos.GetWire(j))
	}
	g.NewCONN(bis.GetWire(bis.GetSize()-1), wco)
	return this
}

/*
SHIFTL
*/
type ShiftLeft struct {
	is, os *g.Bus
	ci, co *g.Wire
}

func NewShiftLeft(bis *g.Bus, wci *g.Wire, bos *g.Bus, wco *g.Wire) *ShiftRight {
	this := &ShiftRight{bis, bos, wci, wco}
	g.NewCONN(bis.GetWire(0), wco)
	for j := 1; j < bis.GetSize(); j++ {
		g.NewCONN(bis.GetWire(j), bos.GetWire(j-1))
	}
	g.NewCONN(wci, bos.GetWire(bos.GetSize()-1))
	return this
}

/*
NOTTER
*/
type Notter struct {
	is, os *g.Bus
}

func NewNotter(bis *g.Bus, bos *g.Bus) *Notter {
	this := &Notter{bis, bos}
	for j := 0; j < bis.GetSize(); j++ {
		g.NewNOT(bis.GetWire(j), bos.GetWire(j))
	}
	return this
}

/*
ANDDER
*/
type Andder struct {
	as, bs, cs *g.Bus
}

func NewAndder(bas *g.Bus, bbs *g.Bus, bcs *g.Bus) *Andder {
	this := &Andder{bas, bbs, bcs}
	for j := 0; j < bas.GetSize(); j++ {
		g.NewAND(bas.GetWire(j), bbs.GetWire(j), bcs.GetWire(j))
	}
	return this
}

/*
ORRER
*/
type Orrer struct {
	as, bs, cs *g.Bus
}

func NewOrrer(bas *g.Bus, bbs *g.Bus, bcs *g.Bus) *Orrer {
	this := &Orrer{bas, bbs, bcs}
	for j := 0; j < bas.GetSize(); j++ {
		g.NewOR(bas.GetWire(j), bbs.GetWire(j), bcs.GetWire(j))
	}
	return this
}

/*
package parts

/*
package ADDER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bas = shift ;
    my $bbs = shift ;
    my $wci = shift ;
    my $bsums = shift ;
    my $wco = shift ;

    # Build the ADDer circuit
    my $twci = new WIRE() ;
    my $twco = $wco ;
    for (my $j = 0 ; $j < 8 ; $j++){
        new ADD($bas->wire($j), $bbs->wire($j), ($j < 7 ? $twci : $wci), $bsums->wire($j), $twco) ;
        $twco = $twci ;
        $twci = new WIRE() ;
    }

    my $this = {
        as => $bas,
        bs => $bbs,
        carry_in => $wci,
        sums => $bsums,
        carry_out => $wco,
    } ;
    bless $this, $class ;

    return $this ;
}


sub as {
    my $this = shift ;
    return $this->{as} ;
}


sub bs {
    my $this = shift ;
    return $this->{bs} ;
}


sub carry_in {
    my $this = shift ;
    return $this->{carry_in} ;
}


sub sums {
    my $this = shift ;
    return $this->{sums} ;
}


sub carry_out {
    my $this = shift ;
    return $this->{carry_out} ;
}



package ANDDER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bas = shift ;
    my $bbs = shift ;
    my $bcs = shift ;

    # Build the ANDder circuit
    map { new AND($bas->wire($_), $bbs->wire($_), $bcs->wire($_)) } (0..7) ;

    my $this = {
        as => $bas,
        bs => $bbs,
        cs => $bcs,
    } ;
    bless $this, $class ;

    return $this ;
}


package BUS1 ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $wbit1 = shift ;
    my $bos = shift ;

    # Build the BUS1 circuit
    my $wnbit1 = new WIRE() ;
    new NOT($wbit1, $wnbit1) ;
    # Foreach AND circuit, connect to the wires.
    for (my $j = 0 ; $j < 8 ; $j++){
        if ($j < 7){
            new AND($bis->wire($j), $wnbit1, $bos->wire($j)) ;
        }
        else {
            new OR($bis->wire($j), $wbit1, $bos->wire($j)) ;
        }
    }

    my $this = {
        is => $bis,
        os => $bos,
        bit1 => $wbit1,
    } ;
    bless $this, $class ;

    return $this ;
}



package NOTTER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $bos = shift ;

    # Build the register circuit
    map { new NOT($bis->wire($_), $bos->wire($_)) } (0..7) ;

    my $this = {
        as => $bis,
        bs => $bos,
    } ;
    bless $this, $class ;

    return $this ;
}



package ORER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bas = shift ;
    my $bbs = shift ;
    my $bcs = shift ;

    # Build the ANDder circuit
    map { new OR($bas->wire($_), $bbs->wire($_), $bcs->wire($_)) } (0..7) ;

    my $this = {
        as => $bas,
        bs => $bbs,
        cs => $bcs,
    } ;
    bless $this, $class ;

    return $this ;
}


package XORER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bas = shift ;
    my $bbs = shift ;
    my $bcs = shift ;
    my $weqo = shift ;
    my $walo = shift ;

    # Build the XORer circuit
    my $weqi = new WIRE(1, 1) ;
    my $wali = new WIRE(0, 1) ;
    for (my $j = 0 ; $j < 8 ; $j++){
        my $teqo = new WIRE() ;
        my $talo = new WIRE() ;
        new CMP($bas->wire($j), $bbs->wire($j), $weqi, $wali, $bcs->wire($j), ($j < 7 ? $teqo : $weqo), ($j < 7 ? $talo : $walo)) ;
        $weqi = $teqo ;
        $wali = $talo ;
    }

    my $this = {
        as => $bas,
        bs => $bbs,
        cs => $bcs,
        eqo => $weqo,
        alo => $walo,
    } ;
    bless $this, $class ;

    return $this ;
}


package ZERO ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $wz = shift ;

    # Build the ZERO circuit
    my $wi = new WIRE() ;
    new ORn(8, $bis, $wi) ;
    new NOT($wi, $wz) ;

    my $this = {
        is => $bis,
        z => $wz,
    } ;
    bless $this, $class ;

    return $this ;
}


1 ;
*/
