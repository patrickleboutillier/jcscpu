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
    my $wc = new WIRE() ;
    my $g1 = new NAND($wi, $ws, $wa, "g1") ;
    my $g2 = new NAND($wa, $ws, $wb, "g2") ;
    my $g3 = new NAND($wa, $wc, $wo, "g3") ;
    my $g4 = new NAND($wo, $wb, $wc, "g4") ;
    
    my $this = {
        i => $wi,
        s => $ws,
        o => $wo,
        name => $name
    } ;

    bless $this, $class ;
    return $this ;
}


return 1 ;