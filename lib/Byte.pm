package BYTE ;

use strict ;
use Memory ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the byte circuit
    my @ms = map { new MEMORY($_ - 1) } (0..7) ;
    my @is = () ;
    my @os = () ;
    my $ws = new WIRE() ;

    # Foreach memory circuit, connect a wire and a PASS to i and o, and connect s to ws.
    for (my $j = 0 ; $j < 8 ; $j++){
        push @is, PASS->in(new WIRE($ms[$j]->i())) ;
        $ws->connect($ms[$j]->s()) ;
        push @os, PASS->out(new WIRE($ms[$j]->o())) ;    
    }
    
    my $this = {
        is => \@is,
        s => PASS->in($ws),
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


sub s {
    my $this = shift ;
    return $this->{s} ;
}


sub os {
    my $this = shift ;
    return @{$this->{os}} ;
}


return 1 ;