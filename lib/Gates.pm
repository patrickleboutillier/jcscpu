use Wire ;

package PIN ;
use strict ;


sub new {
    my $class = shift ;
    my $gate = shift ;
    my $output = shift ;
    my $this = {
        gate => $gate,
        output => $output,
    } ;
    bless $this, $class ;
    return $this ;
}


sub wire {
    my $this = shift ;
    my $wire = shift ;

    if ($wire){
        # New wire attached
        die "Pin already has wire attached! " if ($this->{wire}) ;
        $this->{wire} = $wire ;
        $this->gate()->eval($wire) ;
    }

    return $this->{wire} ;   
}


sub gate {
    my $this = shift ;
    return $this->{gate} ;
}


sub output {
    my $this = shift ;
    return $this->{output} ;
}


package NAND ; 
use strict ;
$NAND::nb = 0  ;


sub new {
    my $class = shift ;
    my $name = shift ;
    my $this = {} ;
    $this->{a} = new PIN($this) ;
    $this->{b} = new PIN($this) ;
    $this->{c} = new PIN($this, 1) ;
    $this->{name} = $name ;
    bless $this, $class ;
    $NAND::nb++ ;
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

    my $wa = $this->{a}->wire() ;
    return unless $wa ;
    my $wb = $this->{b}->wire() ;
    return unless $wb ;
    my $wc = $this->{c}->wire() ;
    return unless $wc ;

    # This code could be replaced by a truth table. No need to actually the language operators to perform
    # the boolean and and the not.
    my $a = $wa->power() ;
    my $b = $wb->power() ;
    my $c = ! ($a && $b) ;

    $wc->power($c) ;
    # warn "NAND[$this->{name}]: (a:$a, b:$b) -> c:$c\n" ;
}


package PASS ; 
use strict ;
$PASS::nb = 0 ;

# A PASS gate is just a dummy gate used to expose wires from internal circuits
# via pins in the enclosing circuit. 

sub new {
    my $class = shift ;
    my $io = shift ;
    my $this = {} ;
    $this->{a} = new PIN($this, 0) ;
    $this->{b} = new PIN($this, !$io) ;
    $this->{io} = $io ;
    bless $this, $class ;
    $PASS::nb++ ;
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
    my $origin = shift ;

    my $wa = $this->{a}->wire() ;
    return unless $wa ;
    my $wb = $this->{b}->wire() ;
    return unless $wb ;

    if (($this->{io})&&($origin eq $wb)){
        $wa->power($wb->power()) ;
    }
    else {
        $wb->power($wa->power()) ;  
    }
}


sub in {
    my $class = shift ;
    my $wire = shift ;

    my $pi = new PASS(0) ;
    $wire->connect($pi->b()) ;
    return $pi->a() ;
}


sub out {
    my $class = shift ;
    my $wire = shift ;
    
    my $po = new PASS(0) ;
    $wire->connect($po->a()) ;
    return $po->b() ;
}


sub io {
    my $class = shift ;
    my $wire = shift ;
    
    my $po = new PASS(1) ;
    $wire->connect($po->b()) ;
    return $po->a() ;
}


package NOT ; 
use strict ;


sub new {
    my $class = shift ;

    my $g = new NAND() ;
    my $wa = new WIRE($g->a(), $g->b()) ;

    my $this = {
        a => PASS->in($wa),
        b => $g->c(),
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

    my $g = new NAND() ;
    my $n = new NOT() ;
    my $wn = new WIRE($g->c(), $n->a()) ;

    my $this = {
        a => $g->a(),
        b => $g->b(),
        c => $n->b(),
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

    die ("Invalid ANDn number of inputs $n") unless ($n >= 2) ;
    my $last = new AND() ;
    my @is = (PASS->in(new WIRE($last->a())), PASS->in(new WIRE($last->b()))) ;
    for (my $j = 0 ; $j < ($n-2) ; $j++){
            my $next = new AND() ;
            my $w = new WIRE($last->c(), $next->a()) ;
            push @is, PASS->in(new WIRE($next->b())) ;
            $last = $next ;
    }

    my $this = {
        is => \@is,
        o => PASS->out(new WIRE($last->c())),
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