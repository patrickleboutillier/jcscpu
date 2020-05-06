package MEMORY ;

use strict ;
use Gates ;


sub new {
    my $class = shift ;
    my $wi = shift ;
    my $ws = shift ;
    my $wo = shift ;
    my $name = shift ;

    # Build the memory circuit, and record the wires.
    my $wa = new WIRE() ;
    my $wb = new WIRE() ;
    # Setting power to 1 here is required to have an initial value of 0 in the memory!
    my $wc = new WIRE(1) ;
    my $g1 = new NAND($wi, $ws, $wa, "g1") ;
    my $g2 = new NAND($wa, $ws, $wb, "g2") ;
    my $g3 = new NAND($wa, $wc, $wo, "g3") ;
    my $g4 = new NAND($wo, $wb, $wc, "g4") ;
    
    my $this = {
        i => $wi,
        s => $ws,
        o => $wo,
        m => $wc,
        name => $name
    } ;

    bless $this, $class ;
    return $this ;
}


sub i {
    my $this = shift ;
    return $this->{i} ;
}


sub s {
    my $this = shift ;
    return $this->{s} ;
}


sub o {
    my $this = shift ;
    return $this->{o} ;
}


sub m {
    my $this = shift ;
    return (! $this->{m}->power()) || 0 ;
}


sub show {
    my $this = shift ;

    my $i = $this->{i}->power() ;
    my $s = $this->{s}->power() ;
    my $o = $this->{o}->power() ;

    return "M($this->{name})[$i/$s/$o]" ;
}


1 ;