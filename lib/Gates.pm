use Wire ;

package PIN ;
use strict ;


sub new {
    my $class = shift ;
    my $gate = shift ;

    my $this = {
        gate => $gate,
    } ;

    bless $this, $class ;
    return $this ;
}


sub wire {
    my $this = shift ;

    return $this->{wire} ;   
}


sub connect {
    my $this = shift ;
    my $wire = shift ;

    # New wire attached
    die "Pin already has wire attached! " if ($this->{wire}) ;
    $this->{wire} = $wire ;

    return $this->{wire} ;   
}


sub gate {
    my $this = shift ;
    return $this->{gate} ;
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
    my $connection = shift ; # Does this signal come from a connection to the pin as opposed to a power change on the wire.

    # Ignore signals from our output pin, unless this is a new connection
    return if (($pin eq $this->{c})&&(! $connection)) ;

    # Do nothing if our output is not connected
    my $wc = $this->{c}->wire() ;
    return unless $wc ;

    my $wa = $this->{a}->wire() ;
    my $a = ($wa ? $wa->power() : 0) ;
    my $wb = $this->{b}->wire() ;
    my $b = ($wb ? $wb->power() : 0) ;
 
    # This code could be replaced by a truth table. No need to actually the language operators to perform
    # the boolean and and the not.
    my $c = ! ($a && $b) ;

    $wc->power($c) ;
    if ($GATES::DEBUG){
        my $srca = ($pin eq $this->{a} ? ($connection ? '+' : '*') : '') ;
        my $srcb = ($pin eq $this->{b} ? ($connection ? '+' : '*') : '') ;
        my $srcc = ($pin eq $this->{c} ? ($connection ? '+' : '*') : '') ;
        $c = ($c ? 1 : 0) ;
        warn "$this->{name} : (${srca}a:$a, ${srcb}b:$b) -> ${srcc}c:$c\n" ;
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
    my $connection = shift ; # Does this signal come from a connection to the pin as opposed to a power change on the wire.

    
    # Do nothing unless both sides are connected
    my $wa = $this->{a}->wire() ;
    return unless $wa ;
    my $wb = $this->{b}->wire() ;
    return unless $wb ;
    
    # warn "$this $connection $this->{io} $pin a:$this->{a} b:$this->{b} " . $wa->power() . " " . $wb->power() ;
    
    if (! $this->{io}){
        # Only react to events from $pin 'a', or connections
        return unless (($pin eq $this->{a})||($connection)) ;
        $wb->power($wa->power()) ;
    }
    else {
        if ($pin eq $this->{a}){
            $wb->power($wa->power(), $connection) ;
        }
        else {
            $wa->power($wb->power(), $connection) ;
        }
    }

    if ($GATES::DEBUG){
        my $srca = ($pin eq $this->{a} ? ($connection ? '+' : '*') : '') ;
        my $srcb = ($pin eq $this->{b} ? ($connection ? '+' : '*') : '') ;
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