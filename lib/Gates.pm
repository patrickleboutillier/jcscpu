use Wire ;

package PIN ;
use strict ;

# Using an arrayrey here to see if it's faster.
my $GATE = 0 ;
my $WIRE = 1 ;
my $PREP = 2 ;

sub new {
    my $class = shift ;
    my $gate = shift ;

    my $this = [$gate, undef, undef] ;

    bless $this, $class ;
    return $this ;
}


sub wire {
    my $this = shift ;
    return $this->[$WIRE] ;   
}


sub connect {
    my $this = shift ;
    my $wire = shift ;

    # New wire attached
    die "Pin already has wire attached! " if ($this->[$WIRE]) ;
    $this->[$WIRE] = $wire ;

    return $wire ;   
}


sub gate {
    my $this = shift ;
    return $this->[$GATE] ;
}


sub prepare {
    my $this = shift ;
    my $sub = shift ;
    my $v = shift ;

    if ($sub){
        $this->[$PREP] = $sub ;
    }
    if ($this->[$PREP]){
        $this->[$PREP]->($v) ;
    }
}


package PASS ; 
use strict ;

# A PASS gate is just a dummy gate used to expose wires from internal circuits
# via pins in the enclosing circuit. 

sub new {
    my $class = shift ;
    my $io = shift ;
    my $name = "PASS[" . shift . "]" ;

    my $this = {
        name => $name,
        io => $io,
    } ;
    $this->{a} = new PIN($this) ;
    $this->{b} = new PIN($this) ;
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


sub eval {
    my $this = shift ;
    my $pin = shift ;

    # Do nothing unless both sides are connected
    my $wa = $this->{a}->wire() ;
    return unless $wa ;
    my $wb = $this->{b}->wire() ;
    return unless $wb ;

    # warn "PASS $pin $this->{a} $this->{b} $this->{io} $reset\n" ;

    if (! $this->{io}){
            $wb->power($wa->power()) ;
    }
    else {
        if ($pin eq $this->{a}){
            $wb->power($wa->power()) ;
        }
        else {
            $wa->power($wb->power()) ;
        }
    }
    if ($GATES::DEBUG){
        my $srca = ($pin eq $this->{a} ? '*' : '') ;
        my $srcb = ($pin eq $this->{b} ? '*' : '') ;
        my $a = $wa->power() ;
        my $b = $wb->power() ;
        warn "$this->{name}: ${srca}a:$a <-> ${srcb}b:$b\n" ;
    }
}


sub connect {
    my $this = shift ;
    my $pin = shift ;

    $this->eval() ;
}


sub signal {
    my $this = shift ;
    my $pin = shift ;
    my $reset = shift ;
    my $newconn = shift ;

    if (! $this->{io}){
        # Ignore signals from our output pin (always b), unless it is a reset
        return if ($pin eq $this->{b}) ;
    }

    $this->eval($pin) ;
}


sub in {
    my $class = shift ;
    my $wire = shift ;
    my $name = shift ;
    
    my $p = new PASS(0, $name) ;
    $wire->connect($p->b()) ;
    return $p->a() ;
}


sub out {
    my $class = shift ;
    my $wire = shift ;
    my $name = shift ;
    
    my $p = new PASS(0, $name) ;
    $wire->connect($p->a()) ;
    return $p->b() ;
}

sub thru {
    my $class = shift ;
    my $wire = shift ;
    my $name = shift ;
    
    my $p = new PASS(1, $name) ;
    $wire->connect($p->b()) ;
    return $p->a() ;
}


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
    my $reset = shift ;
    my $newconn = shift ;

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
    my $name = "XOR[" . shift . "]" ;
 
    my $na = new NOT("$name/NOT[a]") ;
    my $nb = new NOT("$name/NOT[b]") ;
    my $g1 = new NAND("$name/NAND[g1]") ;
    my $g2 = new NAND("$name/NAND[g2]") ;
    my $g3 = new NAND("$name/NAND[g3]") ;
    my $wa = new WIRE($na->a(), $g2->a()) ;
    my $wb = new WIRE($nb->a(), $g1->b()) ;
    new WIRE($na->b(), $g1->a()) ;
    new WIRE($nb->b(), $g2->b()) ;
    new WIRE($g1->c(), $g3->a()) ;
    new WIRE($g2->c(), $g3->b()) ;
    my $this = {
        a => PASS->in($wa),
        b => PASS->in($wb),
        c => $g3->c(),
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
    my $name = "CMP[" . shift . "]" ;
 
    my $x1 = new XOR("$name/XOR[1]") ;
    my $n2 = new NOT("$name/NOT[2]") ;
    my $a3 = new AND("$name/AND[3]") ;
    my $a34 = new ANDn(3, "$name/AND3[4]") ;
    my $o5 = new OR("$name/NAND[g3]") ;
    my $wa = new WIRE($x1->a(), $a34->i(1)) ;
    my $wc = new WIRE($x1->c(), $n2->a(), $a34->i(2)) ;
    new WIRE($a34->o(), $o5->b()) ;
    new WIRE($n2->b(), $a3->b()) ;
    my $weqi = new WIRE($a34->i(0), $a3->a()) ;

    my $this = {
        a => PASS->in($wa),
        b => $x1->b(),
        c => PASS->out($wc),
        eqi => PASS->in($weqi),
        ali => $o5->a(),
        eqo => $a3->c(),
        alo => $o5->c(),
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
    my $name = "AND${n}[" . shift . "]" ;

    die ("Invalid ANDn number of inputs $n") unless ($n >= 2) ;
    my $last = new AND("$name/AND[0]") ;
    my @is = (PASS->in(new WIRE($last->a()), "$name/AND[0]/PASS[a]"), PASS->in(new WIRE($last->b()), "$name/AND[0]/PASS[b]")) ;
    for (my $j = 0 ; $j < ($n-2) ; $j++){
            my $next = new AND("$name/AND[" . ($j+1) . "]") ;
            my $w = new WIRE($last->c(), $next->a()) ;
            push @is, PASS->in(new WIRE($next->b()), "$name/AND[" . ($j+1) . "]/PASS[b]") ;
            $last = $next ;
    }

    my $this = {
        is => \@is,
        o => PASS->out(new WIRE($last->c()), "$name/PASS[c]"),
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
    return $this->{is}->[$n] ;
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
    my $name = "OR${n}[" . shift . "]" ;

    die ("Invalid ORn number of inputs $n") unless ($n >= 2) ;
    my $last = new OR("$name/OR[0]") ;
    my @is = (PASS->in(new WIRE($last->a()), "$name/OR[0]/PASS[a]"), PASS->in(new WIRE($last->b()), "$name/OR[0]/PASS[b]")) ;
    for (my $j = 0 ; $j < ($n-2) ; $j++){
            my $next = new OR("$name/OR[" . ($j+1) . "]") ;
            my $w = new WIRE($last->c(), $next->a()) ;
            push @is, PASS->in(new WIRE($next->b()), "$name/OR[" . ($j+1) . "]/PASS[b]") ;
            $last = $next ;
    }

    my $this = {
        is => \@is,
        o => PASS->out(new WIRE($last->c()), "$name/PASS[c]"),
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
    return $this->{is}->[$n] ;
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
    my $name = "ADD[" . shift . "]" ;
 
    my $x1 = new XOR("$name/XOR[1]") ;
    my $x2 = new XOR("$name/XOR[2]") ;
    my $a1 = new AND("$name/AND[1]") ;
    my $a2 = new AND("$name/AND[2]") ;
    my $o = new OR("$name/OR[]") ;
    my $wa = new WIRE($x1->a(), $a2->a()) ;
    my $wb = new WIRE($x1->b(), $a2->b()) ;
    my $wxic = new WIRE($x1->c(), $x2->a(), $a1->b()) ;
    my $wci = new WIRE($x2->b(), $a1->a()) ;
    new WIRE($a1->c(), $o->a()) ;
    new WIRE($a2->c(), $o->b()) ;

    my $this = {
        a => PASS->in($wa),
        b => PASS->in($wb),
        carry_in => PASS->in($wci),
        carry_out => $o->c(),
        sum => $x2->c(),
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


sub carry_out {
    my $this = shift ;
    return $this->{carry_out} ;
}


sub sum {
    my $this = shift ;
    return $this->{sum} ;
}



return 1 ;