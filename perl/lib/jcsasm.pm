package jcsasm ;
use strict ;
use Carp ;
require Exporter ;
our @ISA = qw(Exporter) ;
our @EXPORT = qw(R0 R1 R2 R3 REM ADD SHR SHL NOT AND OR XOR CMP LD ST DATA JMPR JMP CLF JC JA JE JZ 
    JCA JCE JCZ JAE JAZ JEZ JCAE JCAZ JCEZ JAEZ JCAEZ INA IND OUTA OUTD LABEL GOTO HALT DEBUG ASM) ;


my $HALT  = "01100001" ;

my $PRINT = 1 ;
my @LINES = () ;
my %LABELS = () ;
my $NB_REM = 0 ;


$SIG{__DIE__} = sub {
    $PRINT = 0 ;
} ;


sub nb_lines {
    return scalar(@LINES) - $NB_REM ;
}


sub ASM (&){
    my $sub = shift ;
    $sub->() ;
    return done() ;
}


sub done {
    return [] unless scalar(@LINES) ;

    my $last = $LINES[-1] ;
    # Add HALT at the end if not already there.
    if ($last !~ /^$HALT /){
        HALT("(automatically inserted by jscasm)") ;
    }
    
    # Process GOTOs
    for (my $i = 0 ; $i < scalar(@LINES) ; $i++){
        my $l = $LINES[$i] ;
        if ($l =~ /^\@(\w+)/){
            my $label = $1 ;
            my $byte = $LABELS{$label} ;

            if (! defined($byte)){
                print STDERR "Undefined label '$label'!\n" ;
                exit(1) ;
            }
            my $bin = sprintf("%08b", $byte) ;
            $LINES[$i] =~ s/^\@$label/$bin/ ;
            $LINES[$i] =~ s/\@\@$label/$byte/ ;
        }
    }

    my @ret = @LINES ;
    @LINES = () ;
    %LABELS = () ;
    $NB_REM = 0 ;
    
    return \@ret ;
}


sub add_inst {
    my $byte = shift ;
    my $comment = shift ;

    my $no = scalar(@LINES) ;
    my $pos = $no - $NB_REM ;
    push @LINES, sprintf("$byte # line %3d, pos %3d - %s", $no, $pos, $comment) ;
}


END {
    print(join("\n", @{done()})) if $PRINT ;
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
    add_inst("        ", join('', @_)) ;
    $NB_REM++ ;
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


sub JMPR($) {
    my ($rb) = _check_proto("R", @_) ;

    add_inst(sprintf("001100%s", $rb->{v}), sprintf("JMPR  %s", $rb->{n})) ;
}


sub CLF() {
    _check_proto("", @_) ;

    add_inst("01100000", "CLF   ") ;
}


sub HALT(;$) {
    _check_proto("", @_) ;

    add_inst($HALT, "HALT  " . $_[0]) ;
}


sub JMP($) {
    my ($byte) = _check_proto("A", @_) ;

    my $bin = undef ;
    if ($byte =~ /^\@/){
        $bin = $byte ;
        $byte = "\@$bin" ;
    }
    else {
        $bin = sprintf("%08b", $byte) ;
    }

    add_inst("01000000", sprintf("JMP   %s (%s)", $bin, $byte)) ;
    add_inst($bin, sprintf("      %s (%s)", $bin, $byte)) ;
}


sub GOTO($) {
    my $label = shift ;

    croak("JCSASM: Invalid label '$label'") unless $label =~ /^\w+$/ ;
    REM("GOTO  \@$label") ;
    JMP("\@$label") ;
}


sub LABEL($) {
    my $label = shift ;

    croak("JCSASM: Invalid label '$label'") unless $label =~ /^\w+$/ ;
    croak("JCSASM: Label '$label' already defined") if $LABELS{$label} ;
    my $pos = scalar(@LINES) - $NB_REM ;
    $LABELS{$label} = $pos ;
    REM("Label '$label' at pos $pos") ;
    return $pos ;
}


sub _JMPXXX {
    my $flags = shift ;
    my $label = shift ;
    my ($byte) = _check_proto("A", @_) ;

    my $bin = undef ;
    if ($byte =~ /^\@/){
        $bin = $byte ;
        $byte = "\@$bin" ;
    }
    else {
        $bin = sprintf("%08b", $byte) ;
    }

    add_inst("0101$flags", sprintf("J$label %s (%s)", $bin, $byte)) ;
    add_inst($bin, sprintf("      %s (%s)", $bin, $byte)) ;
}


sub JC    { return _JMPXXX("1000", "C   ", @_) ;}
sub JA    { return _JMPXXX("0100", "A   ", @_) ;}
sub JE    { return _JMPXXX("0010", "E   ", @_) ;}
sub JZ    { return _JMPXXX("0001", "Z   ", @_) ;}
sub JCA   { return _JMPXXX("1100", "CA  ", @_) ;}
sub JCE   { return _JMPXXX("1010", "CE  ", @_) ;}
sub JCZ   { return _JMPXXX("1001", "CZ  ", @_) ;}
sub JAE   { return _JMPXXX("0110", "AE  ", @_) ;}
sub JAZ   { return _JMPXXX("0101", "AZ  ", @_) ;}
sub JEZ   { return _JMPXXX("0011", "EZ  ", @_) ;}
sub JCAE  { return _JMPXXX("1110", "CAE ", @_) ;}
sub JCAZ  { return _JMPXXX("1101", "CAZ ", @_) ;}
sub JCEZ  { return _JMPXXX("1011", "CEZ ", @_) ;}
sub JAEZ  { return _JMPXXX("0111", "AEZ ", @_) ;}
sub JCAEZ { return _JMPXXX("1111", "CAEZ", @_) ;}


sub IND($){
    my ($rb) = _check_proto("R", @_) ;

    add_inst(sprintf("011100%s", $rb->{v}), sprintf("IND   %s", $rb->{n})) ;
}


sub INA($) {
    my ($rb) = _check_proto("R", @_) ;

    add_inst(sprintf("011101%s", $rb->{v}), sprintf("INA   %s", $rb->{n})) ;
}


sub OUTD($) {
    my ($rb) = _check_proto("R", @_) ;

    add_inst(sprintf("011110%s", $rb->{v}), sprintf("OUTD  %s", $rb->{n})) ;
}


sub OUTA($) {
    my ($rb) = _check_proto("R", @_) ;

    add_inst(sprintf("011111%s", $rb->{v}), sprintf("OUTA  %s", $rb->{n})) ;
}


sub DEBUG($) {
    my $perl = shift ;

    $perl =~ s/[\r\n]//g ;

    push @LINES, "#DEBUG $perl" ;
    $NB_REM++ ;
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
            if ($arg !~ /^\@\w+$/){
                my $argn = _valid_num($arg) ;
                if ((! defined($arg))||($argn == -1)){
                    $ok = 0 ;
                }          
                $arg = $argn ;
            }
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

    if ($b =~ /^(0b)([01]{8})$/){ 
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
    my $label = shift ;
    my ($ra, $rb) = _check_proto("RR", @_) ;

    add_inst(sprintf("$inst%s%s", $ra->{v}, $rb->{v}), sprintf("%-5s %s, %s", $label, $ra->{n}, $rb->{n})) ;
}


sub _reg_byte {
    my $inst = shift ;
    my $label = shift ;
    my ($rb, $byte) = _check_proto("RA", @_) ;

    my $bin = sprintf("%08b", $byte) ;
    add_inst(sprintf("${inst}00%s", $rb->{v}), sprintf("%-5s %s, %s (%s)", $label, $rb->{n}, $bin, $byte)) ;
    add_inst($bin, sprintf("      %s (%s)", $bin, $byte)) ;
}


1 ;