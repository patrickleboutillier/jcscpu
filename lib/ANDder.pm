package ANDDER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the ANDder circuit
    my @ands = map { new AND() } (0..7) ;

    my $this = {
        as => [map { $_->a() } @ands],
        bs => [map { $_->b() } @ands],
        cs => [map { $_->c() } @ands]
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