package ENABLER ;

use strict ;
use Gates ;


sub new {
    my $class = shift ;
    my $wis = shift ;
    my $we = shift ;
    my $wos = shift ;
    my $name = shift ;

    # Foreach AND circuit, connect to the wires.
    for (my $j = 0 ; $j < 8 ; $j++){
        new AND($wis->wire($j), $we, $wos->wire($j), $j) ; 
    }
    
    my $this = {
        is => $wis,
        e => $we,
        os => $wos,
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