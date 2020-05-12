package V ;
use strict ;
use jcsasm ;


my $DATAADDR = 255 ;


sub TIESCALAR {
    my $class = shift ;
    my $obj = $DATAADDR-- ;

    croak("Data segment overlapped code sgement!!!") if ($DATAADDR <= jcsasm::nb_lines()) ;

    return bless \$obj, $class ;
}


sub STORE {
    my $this = shift ;
    my $value = shift ;

    DATA R0, $value ;
    DATA R1, $$this ; 
    ST R1, R0 ;   
    # jcshll::SET($this, $value) ;
}


package jcshll ;
use strict ;
use Carp ;
use jcsasm ;
require Exporter ;
our @ISA = qw(Exporter) ;
our @EXPORT = qw(VAR PLUS SET PRINT HALT HLL) ;


sub HLL (&){
    my $sub = shift ;
    return ASM(sub { 
        $sub->() ;
        HALT ;
    }) ;
}


sub VAR(;$) {
    my $value = shift ;
    tie my $v, "V" ;
    
    if (defined($value)){
        $v = $value ;    
    }

    return \$v ;
}


sub SET($$){
    my $tvar = shift ;
    my $value = shift ;

    DATA R0, $value ;
    DATA R1, ${tied $$tvar} ; 
    ST R1, R0 ;
}


sub PLUS($$) {
    my $tvara = shift ;
    my $tvarb = shift ;
    # my $tvarc = shift ;

    DATA R0, ${tied $$tvara} ;
    LD R0, R0 ;
    DATA R1, ${tied $$tvarb} ;
    LD R1, R1 ;
    ADD R0, R1 ;

    my $temp = VAR() ;
    DATA R0, ${tied $$temp} ;
    # DATA R0, ${tied $$tvarc} ;

    ST R0, R1 ;

    return $temp ;
}


sub PRINT($){
    my $tvar = shift ;

    DATA R0, ${tied $$tvar} ;
    LD R0, R0 ; 
    DATA R3, DEVICES::TTY() ;
    OUTA R3 ;
    OUTD R0 ;
}





1 ;