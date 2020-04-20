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
    my $we = new WIRE($E->e()) ;
    my $ws = new WIRE($B->s()) ;
    
    my $this = {
        is => [$B->is()],
        e => PASS->in($we),
        s => PASS->in($ws),
        os => [$E->os()],
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


sub e {
    my $this = shift ;
    return $this->{e} ;
}


sub os {
    my $this = shift ;
    return @{$this->{os}} ;
}


return 1 ;