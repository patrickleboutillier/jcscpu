package ALU ;

use strict ;
use Wire ;
use Gates ;
use Decoder ;
use Enabler ;
use NOTter ;
use ANDder ;
use ORer ;
use XORer ;
use ADDer ;
use Zero ;
use ShiftL ;
use ShiftR ;


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

    # Build the ALU circuit
    my $bdec = new BUS() ;
    my $dec = new DECODER(3, $bops, $bdec, "3x8 op") ;
    $bdec->wire(7)->power(0) ;
    $bdec->wire(7)->terminal() ;

    my @Es = () ;
    my $bxor = new BUS() ;
    my $xor = new XORER($bas, $bbs, $bxor, $weqo, $walo) ;
    unshift @Es, new ENABLER($bxor, $bdec->wire(6), $bcs, "/ENABLER(XORER)") ;

    my $bor = new BUS() ;
    my $or = new ORER($bas, $bbs, $bor) ;
    unshift @Es, new ENABLER($bor, $bdec->wire(5), $bcs, "/ENABLER(ORER)") ;
 
    my $band = new BUS() ;   
    my $and = new ANDDER($bas, $bbs, $band) ;
    unshift @Es, new ENABLER($band, $bdec->wire(4), $bcs, "/ENABLER(ANDDER)") ;

    my $bnot = new BUS() ;  
    my $not = new NOTTER($bas, $bnot) ;
    unshift @Es, new ENABLER($bnot, $bdec->wire(3), $bcs, "/ENABLER(NOTTER)") ;

    my $bshl = new BUS() ; 
    my $woshl = new WIRE() ;  
    my $shl = new SHIFTL($bas, $wci, $bshl, $woshl) ;
    new AND($woshl, $bdec->wire(2), $wco) ;
    unshift @Es, new ENABLER($bshl, $bdec->wire(2), $bcs, "/ENABLER(SHIFTL)") ;

    my $bshr = new BUS() ;
    my $woshr = new WIRE() ;
    my $shr = new SHIFTR($bas, $wci, $bshr, $woshr) ;
    new AND($woshr, $bdec->wire(1), $wco) ;
    unshift @Es, new ENABLER($bshr, $bdec->wire(1), $bcs, "/ENABLER(SHIFTR)") ;

    my $add = new ADDER($bas, $bbs, $wci, new BUS(), new WIRE()) ;
    new AND($add->carry_out(), $bdec->wire(0), $wco) ;
    unshift @Es, new ENABLER($add->sums(), $bdec->wire(0), $bcs, "/ENABLER(ADDER)") ;

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
        Ms => \@Ms,
        Es => \@Es,
        dec => $dec,
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


sub ops {
    my $this = shift ;
    return $this->{ops};
}


sub ci {
    my $this = shift ;
    return $this->{ci} ;
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

    my $a = $this->as()->power() ;
    my $b = $this->bs()->power() ;
    my $c = $this->cs()->power() ;
    my $ci = $this->ci()->power() ;
    my $co = $this->co()->power() ;  
    my $alo = $this->alo()->power() ;
    my $eqo = $this->eqo()->power() ;
    my $op = $this->ops()->power() ;
    my $deci = $this->{dec}->is()->power() ;
    my $deco = $this->{dec}->os()->power() ;
    my $z = $this->z()->power() ;

    my $filter = scalar(@ops) ;
    my %ops = map { ($_ => 1) } @ops ;
    my $str = "ALU: op:$op  a:$a  b:$b  ci:$ci  c:$c  dec:$deci  sw:$deco  co:$co  eqo:$eqo  alo:$alo  z:$z\n" ;
    for (my $j = 6 ; $j >= 0 ; $j--){
        next if (($filter)&&(! $ops{$j})) ;
        $str .= "    " . $this->{Ms}->[$j]->show() ;
        # $str .= "      " . $this->{Es}->[$j]->show() ;
    }

    return $str ;
}


1 ;