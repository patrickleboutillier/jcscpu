package ADDER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the ADDer circuit
    my @adds = map { new ADD() } (0..7) ;
    map { new WIRE($adds[$_]->carry_in(), $adds[$_ + 1]->carry_out()) } (0..6) ;

    my $this = {
        as => [map { $_->a() } @adds],
        bs => [map { $_->b() } @adds],
        sums => [map { $_->sum() } @adds],
        carry_in => $adds[7]->carry_in(), 
        carry_out => $adds[0]->carry_out(), 
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


sub sums {
    my $this = shift ;
    return @{$this->{sums}} ;
}


sub carry_in {
    my $this = shift ;
    return $this->{carry_in} ;
}


sub carry_out {
    my $this = shift ;
    return $this->{carry_out} ;
}


return 1 ;