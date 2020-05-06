package ZERO ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $wz = shift ;

    # Build the ZERO circuit
    my $wi = new WIRE() ;
    new ORn(8, $bis, $wi) ;
    new NOT($wi, $wz) ;

    my $this = {
        is => $bis,
        z => $wz,
    } ;
    bless $this, $class ;

    return $this ;
}


sub show {
    my $this = shift ;

    my $i = $this->{is}->power() ;
    my $z = $this->{z}->power() ;

    return "ZERO: i:$i, z:$z\n" ;
}


1 ;