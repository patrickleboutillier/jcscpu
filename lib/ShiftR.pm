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

    new CONN($wsi, $bos->wire(0)) ;
    map { new CONN($bis->wire($_-1), $bos->wire($_)) } (1..7) ;
    new CONN($bis->wire(7), $wso) ;
    
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

    my $i = $this->is()->power() ;
    my $si = $this->si()->power() ;
    my $so = $this->so()->power() ;    
    my $o = $this->os()->power() ;

    return "SHIFTR($this->{name}): si:$si, i:$i, o:$o, so:$so\n" ;
}


return 1 ;