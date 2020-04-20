package ENABLER ;

use strict ;
use Gates ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the byte circuit
    my @as = map { new AND() } (0..7) ;
    my @is = () ;
    my @os = () ;
    my $we = new WIRE() ;

    # For each AND, connect a wire and a PASS to i and o, and connect e to we.
    for (my $j = 0 ; $j < 8 ; $j++){
        push @is, PASS->in(new WIRE($as[$j]->a())) ;
        $we->connect($as[$j]->b()) ;
        push @os, PASS->out(new WIRE($as[$j]->c())) ;    
    }
    
    my $this = {
        is => \@is,
        e => PASS->in($we),
        os => \@os,
        name => $name
    } ;

    bless $this, $class ;
    return $this ;
}


sub is {
    my $this = shift ;
    return @{$this->{is}} ;
}


sub e {
    my $this = shift ;
    return $this->{e} ;
}


sub os {
    my $this = shift ;
    return @{$this->{os}} ;
}


return 1 ;