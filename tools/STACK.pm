package STACK ;
use strict ;
use jcsasm ;
use Carp ;

require Exporter ;
our @ISA = qw(Exporter) ;
our @EXPORT = qw(PUSH POP) ;

# Constants that would normally be hardcoded if the number of bits in the architecture was not variable.
my $MINUS1 = (1 << $jcsasm::ARCH_BITS) - 1 ; 
my $MINUS2 = $MINUS1 - 1 ;
my $LAST_RAM = $MINUS1 ; 
my $TMP = $LAST_RAM ;
my $TMP0 = $LAST_RAM ;
my $TMP1 = $LAST_RAM - 1 ;
my $TMP2 = $LAST_RAM - 2 ;
my $TMP3 = $LAST_RAM - 3 ;
my $SP = $LAST_RAM - 4 ; # 251
my $STACK = $LAST_RAM - 5 ; # 250
my $SP_INIT = $SP ;


# Make RAM[$SP] point to $SP_INIT, using R1 temporarily
sub init {
    SAVE R1 ;
    DATA R1, $SP_INIT ;
    PTR $SP ;
    PTRST R1 ;
    RSTR R1 ;
}


# Push R1, R2 or R3 onto the stack
sub PUSH($) {
    my ($r) = jcsasm::_check_proto("R", @_) ;

    SAVE R1 ;
    # Decrement SP
    # Load SP in R1
    PTR $SP ;
    PTRLD R1 ;
    SAVE R0 ;
    DATA R0, $MINUS1 ;
    CLF ;
    ADD R0, R1 ;
    RSTR R0 ;
    # Store R1 in SP and in PTR
    PTRST R1 ;
    PTRR R1 ;
    RSTR R1 ;  

    # Put the contents of $r in @PTR
    PTRST $r ;
}

# Pop the stack into R1, R2 or R3
sub POP($) {
    my ($r) = jcsasm::_check_proto("R", @_) ;

    PTR $SP ;
    PTRLD $r ;
    PTRR $r ;
    PTRLD $r ;

    SAVE R1 ;
    # Decrement SP
    # Load SP in R1
    PTR $SP ;
    PTRLD R1 ;
    SAVE R0 ;
    DATA R0, 1 ;
    CLF ;
    ADD R0, R1 ;
    RSTR R0 ;
    # Store R1 in SP and in PTR
    PTRST R1 ;
    RSTR R1 ; 
}