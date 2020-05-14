package jcshll ;
use strict ;
use Carp ;
use jcsasm ;
require Exporter ;
our @ISA = qw(Exporter) ;
our @EXPORT = qw(VAR SET COPY PLUS MINUS SET PRINT REM IF WHILE HALT DEBUG HLL) ;


my $DATAADDR = 255 ;


sub HLL (&){
    my $sub = shift ;
    return ASM(sub { 
        $sub->() ;
    }) ;
}


sub VAR(;$) {
    my $value = undef ;
    ($value) = jcsasm::_check_proto("A", @_) if scalar(@_) ;

    my $addr = $DATAADDR-- ;
    croak("Data segment overlapped code sgement!!!") if ($DATAADDR <= jcsasm::nb_lines()) ;
    my $this = \$addr ;

    # TODO: Validate $value
    if (defined($value)){
        SET($this, $value) ;
    }

    return bless($this, "V") ;
}


sub SET($$){
    my ($var, $value) = _check_proto("VA", @_) ;

    DATA R0, $value ;
    DATA R1, $$var ; 
    ST R1, R0 ;
}


sub COPY($$){
    my ($vara, $varb) = _check_proto("VV", @_) ;

    # Place addr for vara in R0
    DATA R0, $$vara ;
    # Place byte in vara location in R0
    LD R0, R0 ;
    # Place addr of varb in R1
    DATA R1, $$varb ;
    # Put byte in R0 to R1 (addr of varb) 
    ST R1, R0 ;
}


sub EQUALS($$) {
    my ($vara, $varb) = _check_proto("VV", @_) ;

}


sub PLUS($$;$) {
    my ($vara, $varb) = _check_proto("VV", @_) ;
    shift ; shift ;
    my $varc = undef ;
    ($varc) = _check_proto("V", @_) if (scalar(@_)) ;

    DATA R0, $$vara ;
    LD R0, R0 ;
    DATA R1, $$varb ;
    LD R1, R1 ;
    CLF ;
    ADD R0, R1 ;

    my $dest = $varc ;
    $dest = VAR() unless defined($dest) ;
    DATA R0, $$dest ;
    ST R0, R1 ;

    return $dest ;
}


sub MINUS($$;$) {
    my ($vara, $varb, $varc) = _check_proto("VV", @_) ;
    shift ; shift ;
    my $varc = undef ;
    ($varc) = _check_proto("V", @_) if (scalar(@_)) ;

    DATA R0, $$vara ;
    LD R0, R0 ;
    DATA R1, $$varb ;
    LD R1, R1 ;
    NOT R1, R1 ;
    DATA R2, 1 ;
    CLF ;
    ADD R2, R1 ;
    CLF ;
    ADD R0, R1 ;

    my $dest = $varc ;
    $dest = VAR() unless defined($dest) ;
    DATA R0, $$dest ;
    ST R0, R1 ;

    return $dest ;
}


sub PRINT($){
    my ($var) = _check_proto("V", @_) ;

    DATA R0, $$var ;
    LD R0, R0 ; 
    DATA R3, DEVICES::TTY() ;
    OUTA R3 ;
    OUTD R0 ;
}


# TODO: Validate the last arg of present
sub IF($&;&){
    my ($var, $blkif, $blkelse) = _check_proto("VBB", @_) ;

    # Put $var in R0
    DATA R0, $$var ;
    LD R0, R0 ; 
    XOR R1, R1 ;  # Put 0 in R1
    CLF ;
    # eqo flag will be set if R0 == 0
    CMP R0, R1 ;

    my $fi = "FI" . jcsasm::nb_lines() ; 
    my $else = "ELSE" . jcsasm::nb_lines() ; 
    JE "\@$else" ;
    $blkif->() ;
    GOTO $fi ;
    LABEL $else ;
    $blkelse->() if $blkelse ;
    LABEL $fi ;
}


sub WHILE($&) {
    my $var = shift ;
    my $block = shift ;

    my $while = "WHILE" . jcsasm::nb_lines() ;
    my $elihw = "ELIHW" . jcsasm::nb_lines() ;
    LABEL $while ;
    IF $var, sub {
        $block->() ;
    }, sub {
        GOTO $elihw ;
    } ;
    GOTO $while ;
    LABEL $elihw ;
}


sub _check_proto {
    my $proto = shift ;
    my @args = @_ ;

    my @ps = split(//, $proto) ;
    my @newargs = () ;
    for (my $j = 0 ; $j < scalar(@ps) ; $j++){
        my $ok = 1 ;
        my $arg = shift @args ;
        if (($ps[$j] eq "V")&&(ref($arg) != "V")){
            $ok = 0 ;
        }
        if (($ps[$j] eq "B")&&(ref($arg) != "CODE")){
            $ok = 0 ;
        }     

        croak("JCSHLL: Invalid syntax") unless $ok ;
        push @newargs, $arg ; 
    }

    return @newargs ;
}


1 ;