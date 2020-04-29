package STEPPER ;

use strict ;
use Memory ;


sub new {
    my $class = shift ;
    my $wclk = shift ;
    my $wrst = shift ;
    my $bos = shift ;  # 6 wire bus
    my $name = shift ;

    my $wnrm1 = new WIRE() ;
    my $nr = new NOT($wrst, $wnrm1) ;
    my $wnco1 = new WIRE() ;
    my $nc = new NOT($wclk, $wnco1) ;
    my $wmsn = new WIRE() ;
    my $o1 = new OR($wrst, $wnco1, $wmsn) ;
    my $wmsnn = new WIRE() ;
    my $o2 = new OR($wrst, $wclk, $wmsnn) ;
    
    my $wn12b = new WIRE() ;
    my $wn12a = new WIRE() ;
    my $s1 = new OR($wrst, $wn12b, $bos->wire(0)) ;
    my $wm112 = new WIRE() ;
    my $m1 = new MEMORY($wnrm1, $wsn, $wm112) ;

    # Foreach memory circuit, connect to the wires.
    #for (my $j = 0 ; $j < 8 ; $j++){
    #    new MEMORY($bis->wire($j), $ws, $bos->wire($j), $j)  
    #}
    
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