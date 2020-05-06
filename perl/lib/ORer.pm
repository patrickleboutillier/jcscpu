package ORER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bas = shift ;
    my $bbs = shift ;
    my $bcs = shift ;

    # Build the ANDder circuit
    map { new OR($bas->wire($_), $bbs->wire($_), $bcs->wire($_)) } (0..7) ;

    my $this = {
        as => $bas,
        bs => $bbs,
        cs => $bcs,
    } ;
    bless $this, $class ;

    return $this ;
}


sub show {
    my $this = shift ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;
    my $c = $this->{cs}->power() ;

    return "ORER: a:$a, b:$b, c:$c\n" ;
}


1 ;