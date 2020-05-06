package XORER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bas = shift ;
    my $bbs = shift ;
    my $bcs = shift ;
    my $weqo = shift ;
    my $walo = shift ; 

    # Build the XORer circuit
    my $weqi = new WIRE(1, 1) ;
    my $wali = new WIRE(0, 1) ;
    for (my $j = 0 ; $j < 8 ; $j++){
        my $teqo = new WIRE() ;
        my $talo = new WIRE() ;
        new CMP($bas->wire($j), $bbs->wire($j), $weqi, $wali, $bcs->wire($j), ($j < 7 ? $teqo : $weqo), ($j < 7 ? $talo : $walo)) ;
        $weqi = $teqo ;
        $wali = $talo ;
    }

    my $this = {
        as => $bas,
        bs => $bbs,
        cs => $bcs,
        eqo => $weqo,
        alo => $walo,
    } ;
    bless $this, $class ;

    return $this ;
}


sub show {
    my $this = shift ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;
    my $c = $this->{cs}->power() ;
    my $alo = $this->{alo}->power() ;
    my $eqo = $this->{eqo}->power() ;

    return "XORER: a:$a, b:$b, c:$c, eqo:$eqo, alo:$alo\n" ;
}


1 ;