package BUS1 ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $wbit1 = shift ;
    my $bos = shift ;

    # Build the BUS1 circuit
    my $wnbit1 = new WIRE() ;
    new NOT($wbit1, $wnbit1) ;
    # Foreach AND circuit, connect to the wires.
    for (my $j = 0 ; $j < 8 ; $j++){
        if ($j < 7){
            new AND($bis->wire($j), $wnbit1, $bos->wire($j)) ; 
        }
        else {
            new OR($bis->wire($j), $wbit1, $bos->wire($j)) ;             
        }
    }

    my $this = {
        is => $bis,
        os => $bos,
        bit1 => $wbit1,
    } ;
    bless $this, $class ;

    return $this ;
}


sub show {
    my $this = shift ;

    my $i = $this->{is}->power() ;
    my $o = $this->{os}->power() ;

    return "BUS1:$i/$o" ;
}


return 1 ;