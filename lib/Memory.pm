package MEMORY ;

use strict ;
use Gates ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the memory circuit, and record the wires.
    my $g1 = new NAND("g1") ;
    my $g2 = new NAND("g2") ;
    my $g3 = new NAND("g3") ;
    my $g4 = new NAND("g4") ;
    my $wi = new WIRE() ;
    my $ws = new WIRE() ;
    my $wa = new WIRE() ;
    my $wb = new WIRE() ;
    my $wc = new WIRE() ;
    my $wo = new WIRE() ;
    $wi->connect($g1->a()) ;
    $ws->connect($g1->b(), $g2->b()) ;
    $wa->connect($g1->c(), $g2->a(), $g3->a()) ;
    $wb->connect($g2->c(), $g4->b()) ;
    $wc->connect($g3->b(), $g4->c()) ;
    $wo->connect($g3->c(), $g4->a()) ;

    my $this = {
        i => PASS->in($wi),
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