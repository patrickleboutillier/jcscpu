package MEMORY ;

use strict ;
use Gates ;


sub new {
    my $class = shift ;
    my $name = "MEMORY[" . shift . "]" ;

    # Build the memory circuit, and record the wires.
    my $g1 = new NAND("g1") ;
    my $g2 = new NAND("g2") ;
    my $g3 = new NAND("g3") ;
    my $g4 = new NAND("g4") ;
    my $ws = new WIRE($g1->b(), $g2->b()) ;
    my $wa = new WIRE($g1->c(), $g2->a(), $g3->a()) ;
    my $wb = new WIRE($g2->c(), $g4->b()) ;
    my $wc = new WIRE($g3->b(), $g4->c()) ;
    my $wo = new WIRE($g3->c(), $g4->a()) ;

    my $this = {
        i => $g1->a(),
        s => PASS->in($ws),
        o => PASS->out($wo),
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


return 1 ;