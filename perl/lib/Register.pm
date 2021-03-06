package REGISTER ;

use strict ;
use Byte ;
use Enabler ;
# use Bus ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $ws = shift ;
    my $we = shift ;
    my $bos = shift ;
    my $name = shift ;

    # Build the register circuit
    my $bus = new BUS() ;
    my $B = new BYTE($bis, $ws, $bus) ;
    my $E = new ENABLER($bus, $we, $bos) ;

    my $this = {
        is => $bis,
        s => $ws,
        e => $we,
        os => $bos,
        name => $name,
        bus => $bus,
    } ;
    bless $this, $class ;

    return $this ;
}


sub is {
    my $this = shift ;
    return $this->{is} ;
}


sub s {
    my $this = shift ;
    return $this->{s} ;
}


sub e {
    my $this = shift ;
    return $this->{e} ;
}


sub os {
    my $this = shift ;
    return $this->{os} ;
}


sub power {
    my $this = shift ;
    return $this->{bus}->power() ;
}


sub show {
    my $this = shift ;

    my $is = $this->{is}->power() ;
    my $bus = $this->{bus}->power() ;
    my $os = $this->{os}->power() ;
    my $e = $this->{e}->power() ;
    my $s = $this->{s}->power() ;
    my $name = $this->{name} || "REGISTER" ;

    return "$name:$s/$bus/$e" ;
}


1 ;