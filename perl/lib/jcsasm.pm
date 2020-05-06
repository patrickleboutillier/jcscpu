package jcsasm ;
use strict ;
use Carp ;
require Exporter ;
our @ISA = qw(Exporter) ;
our @EXPORT = qw(R0 R1 R2 R3 REM ADD SHR SHL NOT AND OR XOR CMP LD ST DATA JMPR JMP CLF) ;


my $PRINT = 1 ;
my @LINES = () ;


$SIG{__DIE__} = sub {
    $PRINT = 0 ;
} ;


END {
    if ($PRINT){
        foreach my $l (@LINES){
            print "$l\n" ;
        }    
    }
}


sub R0() {
    my $this = {v => "00", n => "R0"} ;
    return bless $this, "R" ;
} 


sub R1() {
    my $this = {v => "01", n => "R1"} ;
    return bless $this, "R" ;
} 


sub R2() {
    my $this = {v => "10", n => "R2"} ;
    return bless $this, "R" ;
} 


sub R3() {
    my $this = {v => "11", n => "R3"} ;
    return bless $this, "R" ;
} 


sub REM {
    push @LINES, "# " . join('', @_) ;
}


sub ADD($$) {
    _reg_reg("1000", "ADD", @_) ;
}


sub SHR($$) {
    _reg_reg("1001", "SHR", @_) ;
}


sub SHL($$) {
    _reg_reg("1010", "SHL", @_) ;
}


sub NOT($$) {
    _reg_reg("1011", "NOT", @_) ;
}


sub AND($$) {
    _reg_reg("1100", "AND", @_) ;
}


sub OR($$) {
    _reg_reg("1101", "OR", @_) ;
}


sub XOR($$) {
    _reg_reg("1110", "XOR", @_) ;
}


sub CMP($$) {
    _reg_reg("1111", "CMP", @_) ;
}


sub LD($$) {
    _reg_reg("0000", "LD", @_) ;
}


sub ST($$) {
    _reg_reg("0001", "ST", @_) ;
}


sub DATA($$) {
    _reg_byte("0010", "DATA", @_) ;
}


sub JMPR {
    my ($rb) = _check_proto("R", @_) ;

    push @LINES, sprintf("001100%s # JMPR  %s", $rb->{v}, $rb->{n}) ;
}


sub CLF {
    _check_proto("", @_) ;

    push @LINES, sprintf("01100000 # CLF  ") ;
}


sub JMP {
    my ($byte) = _check_proto("A", @_) ;

    my $bin = sprintf("%08b", $byte) ;
    push @LINES, sprintf("01000000 # JMP   %s (%s)", $bin, $byte) ;
    push @LINES, sprintf("%s # ...   %s", $bin, $byte) ;
}


sub _check_proto {
    my $proto = shift ;
    my @args = @_ ;

    my @ps = split(//, $proto) ;
    my @newargs = () ;
    for (my $j = 0 ; $j < scalar(@ps) ; $j++){
        my $ok = 1 ;
        my $arg = shift @args ;
        if (($ps[$j] eq "R")&&(ref($arg) != "R")){
            $ok = 0 ;
        }
        if ($ps[$j] eq "A"){
            my $argn = _valid_num($arg) ;
            if ((! defined($arg))||($argn == -1)){
                $ok = 0 ;
            }          
            $arg = $argn ;
        }     

        croak("JCSASM: Invalid syntax") unless $ok ;
        push @newargs, $arg ; 
    }

    return @newargs ;
}


sub _valid_dec {
    my $d = shift ;

    if ($d =~ /^(0d)?(\d+)$/){
        $d = $2 ;
        croak("JCSASM: Decimal value '$d' to large") unless $d < 256 ;   
        return $d ;
    }

    return -1 ;
}


sub _valid_bin {
    my $b = shift ;

    if ($b =~ /^(0b)([0-1]{8})$/){ 
        return oct($b) ;
    }

    return -1 ;
}


sub _valid_num {
    my $n = shift ;

    foreach my $s (\&_valid_dec, \&_valid_bin){
        my $r = $s->($n) ;
        return $r if $r != -1 ;
    } 

    return -1 ;
}


sub _reg_reg {
    my $inst = shift ;
    my $desc = shift ;
    my ($ra, $rb) = _check_proto("RR", @_) ;

    push @LINES, sprintf("$inst%s%s # %-5s %s, %s", $ra->{v}, $rb->{v}, $desc, $ra->{n}, $rb->{n}) ;
}


sub _reg_byte {
    my $inst = shift ;
    my $desc = shift ;
    my ($rb, $byte) = _check_proto("RA", @_) ;

    my $bin = sprintf("%08b", $byte) ;
    push @LINES, sprintf("${inst}00%s # %-5s %s, %s (%s)", $rb->{v}, $desc, $rb->{n}, $bin, $byte) ;
    push @LINES, sprintf("%s # ...   %s", $bin, $byte) ;
}


1 ;
