package NOTTER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $bos = shift ;
    my $name = shift ;

    # Build the register circuit
    map { new NOT($bis->wire($_), $bos->wire($_)) } (0..7) ;

    my $this = {
        as => $bis,
        bs => $bos,
    } ;
    bless $this, $class ;

    return $this ;
}


sub as {
    my $this = shift ;
    return $this->{as} ;
}


sub bs {
    my $this = shift ;
    return $this->{bs} ;
}


sub show {
    my $this = shift ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;

    return "NOTTER($this->{name}): a:$a, b:$b\n" ;
}


return 1 ;