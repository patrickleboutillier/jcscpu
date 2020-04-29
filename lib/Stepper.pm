package STEPPER ;

use strict ;
use Memory ;


sub new {
    my $class = shift ;
    my $wclk = shift ;
    my $wrst = shift ;
    my $bos = shift ;  # 7 wire bus
    my $name = shift ;

    # Foreach memory circuit, connect to the wires.
    for (my $j = 0 ; $j < 8 ; $j++){
        new MEMORY($bis->wire($j), $ws, $bos->wire($j), $j)  
    }
    
    my $this = {
        clk => $wclk,
        rst => $wrst,
        os => $bos,
        name => $name
    } ;
    bless $this, $class ;

    return $this ;
}



return 1 ;