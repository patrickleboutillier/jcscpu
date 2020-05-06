package ENABLER ;

use strict ;
use Gates ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $we = shift ;
    my $bos = shift ;
    my $name = shift ;

    # Foreach AND circuit, connect to the wires.
    for (my $j = 0 ; $j < 8 ; $j++){
        new AND($bis->wire($j), $we, $bos->wire($j), $j) ; 
    }
    
    my $this = {
        is => $bis,
        e => $we,
        os => $bos,
        name => $name
    } ;
    bless $this, $class ;

    return $this ;
}


sub is {
    my $this = shift ;
    return $this->{is} ;
}


sub e {
    my $this = shift ;
    return $this->{e} ;
}


sub os {
    my $this = shift ;
    return $this->{os} ;
}


sub show {
    my $this = shift ;

    my $i = $this->{is}->power() ;
    my $e = $this->{e}->power() ;
    my $o = $this->{os}->power() ;

    return "ENABLER($this->{name}): i:$i, e:$e, o:$o\n" ;
}


1 ;