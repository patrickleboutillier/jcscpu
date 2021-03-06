package BYTE ;

use strict ;
use Memory ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $ws = shift ;
    my $bos = shift ;
    my $name = shift  ;

    # Foreach memory circuit, connect to the wires.
    for (my $j = 0 ; $j < 8 ; $j++){
        new MEMORY($bis->wire($j), $ws, $bos->wire($j), $j)  
    }
    
    my $this = {
        is => $bis,
        s => $ws,
        os => $bos,
        name => $name
    } ;
    bless $this, $class ;

    return $this ;
}


1 ;