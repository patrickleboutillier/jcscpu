package parts

/*
package NOTTER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $bos = shift ;

    # Build the register circuit
    map { new NOT($bis->wire($_), $bos->wire($_)) } (0..7) ;

    my $this = {
        as => $bis,
        bs => $bos,
    } ;
    bless $this, $class ;

    return $this ;
}


sub show {
    my $this = shift ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;

    return "NOTTER: a:$a, b:$b\n" ;
}


1 ;
*/
