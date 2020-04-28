package ANDDER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bas = shift ;
    my $bbs = shift ;
    my $bcs = shift ;
    my $name = shift ;

    # Build the ANDder circuit
    map { new AND($bas->wire($_), $bbs->wire($_), $bcs->wire($_)) } (0..7) ;

    my $this = {
        as => $bas,
        bs => $bbs,
        cs => $bcs,
    } ;
    bless $this, $class ;

    return $this ;
}


sub as {
    my $this = shift ;
    return $this->{as} ;
}


sub bs {
    my $this = shift ;
    return $this->{bs} ;
}


sub cs {
    my $this = shift ;
    return $this->{cs} ;
}


sub show {
    my $this = shift ;

    my $a = $this->as()->power() ;
    my $b = $this->bs()->power() ;
    my $c = $this->cs()->power() ;

    return "ANDDER($this->{name}): a:$a, b:$b, c:$c\n" ;
}


return 1 ;