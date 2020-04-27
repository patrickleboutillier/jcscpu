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

    return $this ;
}


sub a {
    my $this = shift ;
    return $this->{a} ;
}


sub b {
    my $this = shift ;
    return $this->{b} ;
}


sub c {
    my $this = shift ;
    return $this->{c} ;
}


sub eval {
    my $this = shift ;
    my $wire = shift ;

    # Do nothing if our output is not connected
    my $wc = $this->{c} ;
    return unless $wc ;

    my $wa = $this->{a} ;
    my $a = ($wa ? $wa->power() : 0) ;
    my $wb = $this->{b} ;
    my $b = ($wb ? $wb->power() : 0) ;

    # This code could be replaced by a truth table. No need to actually the language operators to perform
    # the boolean and and the not.
    my $c = ! ($a && $b) ;
    my $wc = $this->{c} ;
    $wc->power($c) ;
    if ($GATES::DEBUG){
        my $srca = ($wire eq $this->{a} ? '*' : '') ;
        my $srcb = ($wire eq $this->{b} ? '*' : '') ;
        my $srcc = ($wire eq $this->{c} ? '*' : '') ;
        $c = ($c ? 1 : 0) ;
        warn "$this->{name} : (${srca}a:$a, ${srcb}b:$b) -> ${srcc}c:$c\n" ;
    }
}


sub connect {
    my $this = shift ;
    my $wire = shift ;

    $this->eval($wire) if ($wire eq $this->{c}) ;
}


sub signal {
    my $this = shift ;
    my $wire = shift ;

    # Do nothing if our output is not connected
    my $wc = $this->{c} ;
    return unless $wc ;
 
    # Ignore signals from our output pin, unless it is a new connection
    return if ($wire eq $wc) ;

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


sub a {
    my $this = shift ;
    return $this->{a} ;
}


sub b {
    my $this = shift ;
    return $this->{b} ;
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


sub a {
    my $this = shift ;
    return $this->{a} ;
}


sub b {
    my $this = shift ;
    return $this->{b} ;
}


sub c {
    my $this = shift ;
    return $this->{c} ;
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


sub a {
    my $this = shift ;
    return $this->{a} ;
}


sub b {
    my $this = shift ;
    return $this->{b} ;
}


sub c {
    my $this = shift ;
    return $this->{c} ;
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


sub a {
    my $this = shift ;
    return $this->{a} ;
}


sub b {
    my $this = shift ;
    return $this->{b} ;
}


sub c {
    my $this = shift ;
    return $this->{c} ;
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


sub a {
    my $this = shift ;
    return $this->{a} ;
}


sub b {
    my $this = shift ;
    return $this->{b} ;
}


sub c {
    my $this = shift ;
    return $this->{c} ;
}


# 'a' larger in
sub ali {
    my $this = shift ;
    return $this->{ali} ;
}


# 'a' larger out
sub alo {
    my $this = shift ;
    return $this->{alo} ;
}

# 'equal so far' in
sub eqi {
    my $this = shift ;
    return $this->{eqi} ;
}


# 'equal so far' out
sub eqo {
    my $this = shift ;
    return $this->{eqo} ;
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


sub is {
    my $this = shift ;
    return @{$this->{is}} ;
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


sub o {
    my $this = shift ;
    return $this->{o} ;
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

    #my $last = new OR("$name/OR[0]") ;
    #my @is = (PASS->in(new WIRE($last->a()), "$name/OR[0]/PASS[a]"), PASS->in(new WIRE($last->b()), "$name/OR[0]/PASS[b]")) ;
    #for (my $j = 0 ; $j < ($n-2) ; $j++){
    #        my $next = new OR("$name/OR[" . ($j+1) . "]") ;
    #        my $w = new WIRE($last->c(), $next->a()) ;
    #        push @is, PASS->in(new WIRE($next->b()), "$name/OR[" . ($j+1) . "]/PASS[b]") ;
    #        $last = $next ;
    #}

    my $this = {
        is => $bis,
        o => $wo,
        n => $n,
    } ;

    bless $this, $class ;
    return $this ;
}


sub is {
    my $this = shift ;
    return @{$this->{is}} ;
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


sub o {
    my $this = shift ;
    return $this->{o} ;
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


sub a {
    my $this = shift ;
    return $this->{a} ;
}


sub b {
    my $this = shift ;
    return $this->{b} ;
}


sub carry_in {
    my $this = shift ;
    return $this->{carry_in} ;
}


sub sum {
    my $this = shift ;
    return $this->{sum} ;
}


sub carry_out {
    my $this = shift ;
    return $this->{carry_out} ;
}


package PASS ; 
use strict ;

# Hack to connect 2 wires together, using 2 NOT gates...
sub new {
    my $class = shift ;
    my $wa = shift ;
    my $wb = shift ;

    my $wi = new WIRE() ;
    new NOT($wa, $wi) ;
    new NOT($wi, $wb) ;

    my $this = {
        a => $wa,
        b => $wb,
    } ;
    bless $this, $class ;

    return $this ;
}


return 1 ;