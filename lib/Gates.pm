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


sub signal {
    my $this = shift ;
    my $pin = shift ;
    my $reset = shift ;
    my $newconn = shift ;

    # Do nothing unless both sides are connected
    my $wa = $this->{a}->wire() ;
    return unless $wa ;
    my $wb = $this->{b}->wire() ;
    return unless $wb ;

    # warn "PASS $pin $this->{a} $this->{b} $this->{io} $reset\n" ;

    if (! $this->{io}){
        if (! $reset){
            # Ignore signals from our output pin (always b), unless it is a reset
            return if (($pin eq $this->{b})&&(! $newconn)) ;
            $wb->power($wa->power()) ;
        }
        else {
            # Reset on uni-directional PASS?
            return if ($pin eq $this->{b}) ;
            $wb->reset($this->{b}) ;
        }
    }
    else {
        if (! $reset){
            if ($pin eq $this->{a}){
                $wb->power($wa->power()) ;
            }
            else {
                $wa->power($wb->power()) ;
            }
        }
        else {
            if ($pin eq $this->{a}){
                $wb->reset($this->{b}) ;
            }
            else {
                $wa->reset($this->{a}) ;
            }
        }
    }

    if ($GATES::DEBUG){
        my $srca = ($pin eq $this->{a} ? ($reset ? '+' : '*') : '') ;
        my $srcb = ($pin eq $this->{b} ? ($reset ? '+' : '*') : '') ;
        my $a = $wa->power() ;
        my $b = $wb->power() ;
        warn "$this->{name}: ${srca}a:$a <-> ${srcb}b:$b\n" ;
    }
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
    my $name = "NAND[" . shift . "]" ;

    my $this = {
        name => $name,
    } ;
    $this->{a} = new PIN($this) ;
    $this->{b} = new PIN($this) ;
    $this->{c} = new PIN($this) ;
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


sub signal {
    my $this = shift ;
    my $pin = shift ;
    my $reset = shift ;
    my $newconn = shift ;

    # Do nothing if our output is not connected
    my $wc = $this->{c}->wire() ;
    return unless $wc ;
 
    if (! $reset){
        # Ignore signals from our output pin, unless it is a new connection
        return if (($pin eq $this->{c})&&(! $newconn)) ;
    }

    my $wa = $this->{a}->wire() ;
    my $a = ($wa ? $wa->power() : 0) ;
    my $wb = $this->{b}->wire() ;
    my $b = ($wb ? $wb->power() : 0) ;

    # This code could be replaced by a truth table. No need to actually the language operators to perform
    # the boolean and and the not.
    my $c = ! ($a && $b) ;

    $wc->power($c) ;
    if ($GATES::DEBUG){
        my $srca = ($pin eq $this->{a} ? ($reset ? '+' : '*') : '') ;
        my $srcb = ($pin eq $this->{b} ? ($reset ? '+' : '*') : '') ;
        my $srcc = ($pin eq $this->{c} ? ($reset ? '+' : '*') : '') ;
        $c = ($c ? 1 : 0) ;
        warn "$this->{name} : (${srca}a:$a, ${srcb}b:$b) -> ${srcc}c:$c\n" ;
    }
}


package NOT ; 
use strict ;


sub new {
    my $class = shift ;
    my $name = "NOT[" . shift . "]" ;

    my $g = new NAND("$name/NAND") ;
    my $wa = new WIRE($g->a(), $g->b()) ;

    my $this = {
        a => PASS->in($wa, "$name/PASS[a]"),
        b => $g->c(),
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
    my $name = "AND[" . shift . "]" ;

    my $g = new NAND("$name/NAND") ;
    my $n = new NOT("$name/NOT") ;
    my $wn = new WIRE($g->c(), $n->a()) ;
    my $this = {
        a => $g->a(),
        b => $g->b(),
        c => $n->b(),
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
    my $name = "OR[" . shift . "]" ;

 
    my $na = new NOT("$name/NOT[a]") ;
    my $nb = new NOT("$name/NOT[b]") ;
    my $g = new NAND("$name/NAND") ;
    new WIRE($na->b(), $g->a()) ;
    new WIRE($nb->b(), $g->b()) ;
    my $this = {
        a => $na->a(),
        b => $nb->a(),
        c => $g->c(),
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





return 1 ;