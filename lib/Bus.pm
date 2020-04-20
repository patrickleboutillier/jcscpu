package BUS ;

use strict ;
use Gates ;


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
        my $wi = new WIRE() ;
        $wi->connect($ms[$j]->i()) ;
        push @is, PASS->in($wi) ;

        $ws->connect($ms[$j]->s()) ;
        
        my $wo = new WIRE() ;
        $wo->connect($ms[$j]->o()) ;
        push @os, PASS->out($wo) ;    
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