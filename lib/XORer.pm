package XORER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the XORer circuit
    my @xors = map { new XOR() } (0..7) ;

    my $this = {
        as => [map { $_->a() } @xors],
        bs => [map { $_->b() } @xors],
        cs => [map { $_->c() } @xors]
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


sub cs {
    my $this = shift ;
    return @{$this->{cs}} ;
}


return 1 ;