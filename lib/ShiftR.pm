package SHIFTR ;

use strict ;
use Wire ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $wsi = shift ;
    my $bos = shift ;
    my $wso = shift ;
    my $name = shift ;

    new PASS($wsi, $bos->wire(0)) ;
    map { new PASS($bis->wire($_-1), $bos->wire($_)) } (1..7) ;
    new PASS($bis->wire(7), $wso) ;
    
    my $this = {
        name => $name,
        is => $bis,
        si => $wsi,
        os => $bos,
        so => $wso,
    } ;
    bless $this, $class ;

    return $this ;
    my $class = shift ;
    my $name = shift ;

    # Build the shifter circuit
    my @wires = map { new WIRE() } (0..6) ;
    my $sow = new WIRE() ;
    my $siw = new WIRE() ;
    my @is = ((map { PASS->in($wires[$_]) } (0..6)), PASS->in($sow)) ;
    my @os = (PASS->out($siw), (map { PASS->out($wires[$_]) } (0..6))) ;
 
    my $this = {
        name => $name,
        is => \@is,
        os => \@os,
        so => PASS->out($sow),
        si => PASS->in($siw),
    } ;
    bless $this, $class ;
    
    return $this ;
}


sub is {
    my $this = shift ;
    return $this->{is} ;
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
    return $this->{os} ;
}


return 1 ;