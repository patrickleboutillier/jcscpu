package ALU ;

use strict ;
use Wire ;
use Gates ;
use DECODER ;
use ENABLER ;
use NOTTER ;
use ANDDER ;
use ORER ;
use XORER ;
use ADDER ;
use ZERO ;
use SHIFTL ;
use SHIFTR ;


sub new {
    my $class = shift ;
    my $bas = shift ; 
    my $bbs = shift ;
    my $wci = shift ;
    my $bops = shift ;
    my $bcs = shift ; 
    my $wco = shift ;
    my $weqo = shift ;
    my $walo = shift ;
    my $wz = shift ;
    my $name = shift ;

    # Build the ALU circuit
    my $bdec = new BUS() ;
    my $a3x8 = new DECODER(3, $bops, $bdec, "3x8") ;
    $bdec->wire(7)->power(0) ;

    my $xor = new XORER($bas, $bbs, new BUS(), $weqo, $walo) ;
    new ENABLER($xor->cs(), $bdec->wire(6), $bcs) ;
    my $or = new ORER($bas, $bbs, new BUS()) ;
    new ENABLER($or->cs(), $bdec->wire(5), $bcs) ;
    my $and = new ANDDER($bas, $bbs, new BUS()) ;
    new ENABLER($and->cs(), $bdec->wire(4), $bcs) ;
    my $not = new NOTTER($bas, new BUS()) ;
    new ENABLER($not->bs(), $bdec->wire(3), $bcs) ;

    my $shl = new SHIFTL($bas, $wci, new BUS(), new WIRE()) ;
    new AND($shl->so(), $bdec->wire(2), $wco) ;
    new ENABLER($shl->os(), $bdec->wire(2), $bcs) ;
    my $shr = new SHIFTR($bas, $wci, new BUS(), new WIRE()) ;
    new AND($shr->so(), $bdec->wire(1), $wco) ;
    new ENABLER($shr->os(), $bdec->wire(1), $bcs) ;

    my $add = new ADDER($bas, $bbs, $wci, new BUS(), new WIRE()) ;
    new AND($add->carry_out(), $bdec->wire(0), $wco) ;
    new ENABLER($add->sums(), $bdec->wire(0), $bcs) ;

    my $zero = new ZERO($bcs, $wz) ;

    my $this = {
        as => $bas,
        bs => $bbs,
        cs => $bcs,
        ops => $bops,
        carry_in => $wci,
        carry_out => $wco,
        eqo => $weqo,
        alo => $walo,
        z => $wz,
        name => $name,
    } ;
    bless $this, $class ;

    return $this ;
}


sub as {
    my $this = shift ;
    return @$this->{as} ;
}


sub bs {
    my $this = shift ;
    return @$this->{bs} ;
}


sub cs {
    my $this = shift ;
    return @$this->{cs} ;
}


sub ops {
    my $this = shift ;
    return $this->{cs};
}


sub carry_in {
    my $this = shift ;
    return $this->{carry_in} ;
}


sub carry_out {
    my $this = shift ;
    return $this->{carry_out} ;
}


# 'a' larger out
sub alo {
    my $this = shift ;
    return $this->{alo} ;
}


# 'equal so far' out
sub eqo {
    my $this = shift ;
    return $this->{eqo} ;
}


sub z {
    my $this = shift ;
    return $this->{z} ;
}


return 1 ;