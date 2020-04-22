package REGISTER ;

use strict ;
use Byte ;
use Enabler ;
use Bus ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the register circuit
    my $B = new BYTE() ;
    my $E = new ENABLER() ;

    my $bus = new BUS([$B->os()], [$E->is()]) ;
    
    my $this = {
        is => [$B->is()],
        e => $E->e(),
        s => $B->s(),
        os => [$E->os()],
        name => $name,
        B => $B, 
        E => $E, 
        bus => $bus,
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


sub e {
    my $this = shift ;
    return $this->{e} ;
}


sub os {
    my $this = shift ;
    return @{$this->{os}} ;
}


sub show {
    my $this = shift ;

    my $is = WIRE->power_wires(map { $_->wire() } $this->{B}->is()) ;
    my $bus = $this->{bus}->power() ;
    my $os = WIRE->power_wires(map { $_->wire() } $this->{E}->os()) ;
    my $e = $this->e()->wire()->power() ;
    my $s = $this->s()->wire()->power() ;
    return "REGISTER($this->{name}): e:$e, s:$s, is:$is, bus:$bus, os:$os" ;
}


return 1 ;