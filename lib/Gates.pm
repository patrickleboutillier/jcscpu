use Wire ;


package NAND ; 
use strict ;


sub new {
    my $class = shift ;
    my $wa = shift ;
    my $wb = shift ;
    my $wc = shift ;
    my $name = shift ;

    my $this = {
        name => $name,
    } ;
    bless $this, $class ;
    
    $this->{a} = $wa ;
    $wa->connect($this) ;
    $this->{b} = $wb ;
    $wb->connect($this) ;
    $this->{c} = $wc ;
    $wc->connect($this) ;

    $GATES::NB_NAND++ ;

    return $this ;
}


END {
    # warn "$GATES::NB_NAND NAND gates created!" ;
}


sub eval {
    my $this = shift ;
    my $wire = shift ;

    my $a = $this->{a}->power() ;
    my $b = $this->{b}->power() ;

    # This code could be replaced by a truth table. No need to actually the language operators to perform
    # the boolean and and the not.
    $this->{c}->power(! ($a && $b)) ;
}


sub connect {
    my $this = shift ;
    my $wire = shift ;

    $this->eval($wire) if ($wire eq $this->{c}) ;
}


sub signal {
    my $this = shift ;
    my $wire = shift ;
 
    # Ignore signals from our output pin.
    return if ($wire eq $this->{c}) ;

    $this->eval($wire) ;
}


package NOT ; 
use strict ;


sub new {
    my $class = shift ;
    my $wa = shift ;
    my $wb = shift ;
    my $name = shift ;

    new NAND($wa, $wa, $wb, "$name/NAND") ;

    my $this = {
        a => $wa,
        b => $wb,
        name => $name,
    } ;

    bless $this, $class ;
    return $this ;
}


package AND ; 
use strict ;


sub new {
    my $class = shift ;
    my $wa = shift ;
    my $wb = shift ;
    my $wc = shift ;
    my $name = shift ;

    my $win = new WIRE() ;
    new NAND($wa, $wb, $win, "$name/NAND") ;
    new NOT($win, $wc, "$name/NOT") ;
 
    my $this = {
        a => $wa,
        b => $wb,
        c => $wc,
        name => $name,
    } ;

    bless $this, $class ;
    return $this ;
}


sub c {
    my $this = shift ;
    return $this->{c} ;
}


sub show {
    my $this = shift ;

    return "AND[" . $this->{a}->power() . "/" . $this->{b}->power() . "/" . $this->{c}->power() . "]" ;
}


package OR ;
use strict ;


sub new {
    my $class = shift ;
    my $wa = shift ;
    my $wb = shift ;
    my $wc = shift ;
    my $name = shift ;

    my $wic = new WIRE() ;
    my $wid = new WIRE() ;
    new NOT($wa, $wic, "$name/NOT[a]") ;
    new NOT($wb, $wid, "$name/NOT[b]") ;
    new NAND($wic, $wid, $wc, "$name/NAND") ;

    my $this = {
        a => $wa,
        b => $wb,
        c => $wc,
        name => $name,
    } ;

    bless $this, $class ;
    return $this ;
}


sub c {
    my $this = shift ;
    return $this->{c} ;
}


sub show {
    my $this = shift ;

    return " OR[" . $this->{a}->power() . "/" . $this->{b}->power() . "/" . $this->{c}->power() . "]" ;
}


package XOR ;
use strict ;


sub new {
    my $class = shift ;
    my $wa = shift ;
    my $wb = shift ;
    my $wc = shift ;
    my $name = shift ;
 
    my $wic = new WIRE() ;
    my $wid = new WIRE() ;
    my $wie = new WIRE() ;
    my $wif = new WIRE() ;
    new NOT($wa, $wic, "$name/NOT[a]") ;
    new NOT($wb, $wid, "$name/NOT[b]") ;
    new NAND($wic, $wb, $wie, "$name/NAND[g1]") ;
    new NAND($wa, $wid, $wif, "$name/NAND[g2]") ;
    new NAND($wie, $wif, $wc, "$name/NAND[g3]") ;

    my $this = {
        a => $wa,
        b => $wb,
        c => $wc,
        name => $name,
    } ;
    bless $this, $class ;

    return $this ;
}


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
            my $next = new AND($last->c(), $bis->wire($j+2), (($n == ($j+3)) ? $wo : new WIRE()), "$name/AND[" . ($j+1) . "]") ;
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


package CONN ; 
use strict ;

# Hack to connect 2 wires together, using an AND gates...
sub new {
    my $class = shift ;
    my $wa = shift ;
    my $wb = shift ;

    new AND($wa, $wa, $wb) ;

    my $this = {
        a => $wa,
        b => $wb,
    } ;
    bless $this, $class ;

    return $this ;
}


return 1 ;