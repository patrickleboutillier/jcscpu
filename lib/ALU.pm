package ALU ;

use strict ;
use Wire ;
use Gates ;
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
    my $name = shift ;

    # Build the ALU circuit
    my $xor = new XORER() ;
    my $or = new ORER() ;
    my $and = new ANDDER() ;
    my $not = new NOTTER() ;
    my $shl = new SHIFTL() ;
    my $shr = new SHIFTR() ;
    my $add = new ADDER() ;
    my $zero = new ZERO() ;
    my $a3x8 = new ANDn(3, "3x8") ;

    my $this = {
        #as => ,
        #bs => ,
        #cs => ,
        #ops => ,
        #carry_in => ,
        #carry_out => ,
        eqo => PASS->out($xor->eqo()),
        alo => PASS->out($xor->alo()),
        z => PASS->out($zero->z()),
        name => $name,
    } ;
    bless $this, $class ;

    return $this ;
}


sub as {
    my $this = shift ;
    return @{$this->{as}} ;
}


sub bs {
    my $this = shift ;
    return @{$this->{bs}} ;
}


sub cs {
    my $this = shift ;
    return @{$this->{cs}} ;
}


sub ops {
    my $this = shift ;
    return @{$this->{cs}} ;
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