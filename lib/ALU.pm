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
    my $dec = new DECODER(3, $bops, $bdec, "3x8") ;
    $bdec->wire(7)->power(0) ;
    $bdec->wire(7)->{terminal} = 1 ;
    $bdec->wire(7)->prehook(sub { warn "WTF(@_)!!" }) ;

    my @Es = () ;
    my $xor = new XORER($bas, $bbs, new BUS(), $weqo, $walo) ;
    unshift @Es, new ENABLER($xor->cs(), $bdec->wire(6), $bcs, "$name/ENABLER(XORER)") ;

    my $or = new ORER($bas, $bbs, new BUS()) ;
    unshift @Es, new ENABLER($or->cs(), $bdec->wire(5), $bcs, "$name/ENABLER(ORER)") ;
    
    my $and = new ANDDER($bas, $bbs, new BUS()) ;
    unshift @Es, new ENABLER($and->cs(), $bdec->wire(4), $bcs, "$name/ENABLER(ANDDER)") ;
    
    my $not = new NOTTER($bas, new BUS()) ;
    unshift @Es, new ENABLER($not->bs(), $bdec->wire(3), $bcs, "$name/ENABLER(NOTTER)") ;

    my $shl = new SHIFTL($bas, $wci, new BUS(), new WIRE()) ;
    new AND($shl->so(), $bdec->wire(2), $wco) ;
    unshift @Es, new ENABLER($shl->os(), $bdec->wire(2), $bcs, "$name/ENABLER(SHIFTL)") ;

    my $shr = new SHIFTR($bas, $wci, new BUS(), new WIRE()) ;
    new AND($shr->so(), $bdec->wire(1), $wco) ;
    unshift @Es, new ENABLER($shr->os(), $bdec->wire(1), $bcs, "$name/ENABLER(SHIFTR)") ;

    my $add = new ADDER($bas, $bbs, $wci, new BUS(), new WIRE()) ;
    new AND($add->carry_out(), $bdec->wire(0), $wco) ;
    unshift @Es, new ENABLER($add->sums(), $bdec->wire(0), $bcs, "$name/ENABLER(ADDER)") ;

    my @Ms = ($add, $shr, $shl, $not, $and, $or, $xor) ;
    my $zero = new ZERO($bcs, $wz) ;

    my $this = {
        as => $bas,
        bs => $bbs,
        cs => $bcs,
        ops => $bops,
        ci => $wci,
        co => $wco,
        eqo => $weqo,
        alo => $walo,
        z => $wz,
        name => $name,
        Ms => \@Ms,
        Es => \@Es,
        dec => $dec,
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


sub ci {
    my $this = shift ;
    return $this->{co} ;
}


sub co {
    my $this = shift ;
    return $this->{co} ;
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


sub show {
    my $this = shift ;
    my @ops = @_ ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;
    my $c = $this->{cs}->power() ;
    my $ci = $this->{ci}->power() ;
    my $co = $this->{co}->power() ;  
    my $alo = $this->{alo}->power() ;
    my $eqo = $this->{eqo}->power() ;
    my $op = $this->{ops}->power() ;
    my $dec = $this->{dec}->os()->power() ;

    my $filter = scalar(@ops) ;
    my %ops = map { ($_ => 1) } @ops ;
    my $str = "ALU($this->{name}): op:$op, a:$a, b:$b, ci:$ci, c:$c, dec:$dec, co:$co eqo:$eqo, alo:$alo\n" ;
    for (my $j = 6 ; $j >= 0 ; $j--){
        next if (($filter)&&(! $ops{$j})) ;
        $str .= "  " . $this->{Ms}->[$j]->show() ;
        $str .= "    " . $this->{Es}->[$j]->show() ;
    }

    return $str ;
}


return 1 ;