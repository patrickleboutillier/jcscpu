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
        #B => $B, 
        #E => $E, 
        bus => $bus,
    } ;
    bless $this, $class ;
    
    # Moved to ENABLER
    # Setup the hook when e changes to clear the bus
    # $this->{e}->prehook(sub { $this->clear_bus_before_e(@_) }) ;

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


sub show {
    my $this = shift ;

    my $is = $this->{is}->power() ;
    my $bus = $this->{bus}->power() ;
    my $os = $this->{os}->power() ;
    my $e = $this->{e}->power() ;
    my $s = $this->{s}->power() ;
    return "REGISTER($this->{name}): e:$e, s:$s, is:$is, bus:$bus, os:$os" ;
}


sub clear_bus_before_e {
    my $this = shift ;
    my $v = shift ;

    if ($v){
        # warn "e is turning on ($v) for register $this->{name}!" ;
        $this->{os}->power("00000000") ;
    }
}


return 1 ;