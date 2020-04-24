package SHIFTR ;

use strict ;
use Wire ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the register circuit
    my $this = {
        name => $name,
    } ;
    bless $this, $class ;

    my @wires = map { new WIRE() } (0..6) ;
    my $sow = new WIRE() ;
    my $siw = new WIRE() ;
    my @is = ((map { PASS->in($wires[$_]) } (0..6)), PASS->in($sow)) ;
    my @os = (PASS->out($siw), (map { PASS->out($wires[$_]) } (0..6))) ;

    $this->{is} = \@is ;
    $this->{os} = \@os ;
    $this->{so} = PASS->out($sow) ;
    $this->{si} = PASS->in($siw) ;

    return $this ;
}


sub is {
    my $this = shift ;
    return @{$this->{is}} ;
}


sub si {
    my $this = shift ;
    return $this->{si} ;
}


sub so {
    my $this = shift ;
    return $this->{so} ;
}


sub os {
    my $this = shift ;
    return @{$this->{os}} ;
}


return 1 ;