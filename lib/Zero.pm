package ZERO ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the ZERO circuit
    my $a8 = new ORn(8) ;
    my $n = new NOT() ;
    new WIRE($a8->o(), $n->a()) ;

    my $this = {
        is => [map { $a8->i($_) } (0..7)],
        z => PASS->out(new WIRE($n->b())),
    } ;
    bless $this, $class ;

    return $this ;
}


sub is {
    my $this = shift ;
    return @{$this->{is}} ;
}


sub z {
    my $this = shift ;
    return $this->{z} ;
}


return 1 ;