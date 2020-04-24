package ORER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the ORer circuit
    my @ors = map { new OR() } (0..7) ;

    my $this = {
        as => [map { $_->a() } @ors],
        bs => [map { $_->b() } @ors],
        cs => [map { $_->c() } @ors]
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