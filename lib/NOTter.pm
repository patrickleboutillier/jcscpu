package NOTTER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the register circuit
    my @nots = map { new NOT() } (0..7) ;

    my $this = {
        as => [map { $_->a() } @nots],
        bs => [map { $_->b() } @nots]
    } ;
    bless $this, $class ;

    return $this ;
}


sub as {
    my $this = shift ;
    return @{$this->{as}} ;
}


sub bs {
    my $this = shift ;
    return @{$this->{bs}} ;
}


return 1 ;