package parts

import (
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

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


sub show {
    my $this = shift ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;
    my $ci = $this->{carry_in}->power() ;
    my $co = $this->{carry_out}->power() ;    
    my $sum = $this->{sums}->power() ;

    return "ADDER: a:$a, b:$b, ci:$ci, co:$co, sum:$sum\n" ;
}


1 ;
*/
package parts

/*
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


sub show {
    my $this = shift ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;
    my $c = $this->{cs}->power() ;

    return "ANDDER: a:$a, b:$b, c:$c\n" ;
}


1 ;
*/
package parts

/*
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


sub show {
    my $this = shift ;

    my $i = $this->{is}->power() ;
    my $o = $this->{os}->power() ;

    return "BUS1:$i/$o" ;
}


1 ;
*/
package parts

/*
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


sub show {
    my $this = shift ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;

    return "NOTTER: a:$a, b:$b\n" ;
}


1 ;
*/
package parts

/*
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


sub show {
    my $this = shift ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;
    my $c = $this->{cs}->power() ;

    return "ORER: a:$a, b:$b, c:$c\n" ;
}


1 ;
*/
package parts

/*
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


sub show {
    my $this = shift ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;
    my $c = $this->{cs}->power() ;
    my $alo = $this->{alo}->power() ;
    my $eqo = $this->{eqo}->power() ;

    return "XORER: a:$a, b:$b, c:$c, eqo:$eqo, alo:$alo\n" ;
}


1 ;
*/
package parts

/*
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


sub show {
    my $this = shift ;

    my $i = $this->{is}->power() ;
    my $z = $this->{z}->power() ;

    return "ZERO: i:$i, z:$z\n" ;
}


1 ;
*/
