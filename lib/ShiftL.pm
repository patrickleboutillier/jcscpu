package SHIFTL ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bis = shift ;
    my $wsi = shift ;
    my $bos = shift ;
    my $wso = shift ;
    my $name = shift ;

    new CONN($bis->wire(0), $wso) ;
    map { new CONN($bis->wire($_), $bos->wire($_-1)) } (1..7) ;
    new CONN($wsi, $bos->wire(7)) ;
    
    my $this = {
        name => $name,
        is => $bis,
        si => $wsi,
        os => $bos,
        so => $wso,
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


sub show {
    my $this = shift ;

    my $i = $this->{is}->power() ;
    my $si = $this->{si}->power() ;
    my $so = $this->{so}->power() ;    
    my $o = $this->{os}->power() ;

    return "SHIFTL($this->{name}): i:$i, si:$so, so:$so, o:$o\n" ;
}


return 1 ;