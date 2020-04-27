package ZERO ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $wz = shift ;
    my $name = shift ;

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


sub is {
    my $this = shift ;
    return $this->{is} ;
}


sub z {
    my $this = shift ;
    return $this->{z} ;
}


return 1 ;