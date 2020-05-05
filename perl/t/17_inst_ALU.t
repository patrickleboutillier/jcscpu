use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;

push @INC, './t' ;
require 'test_alu.pm' ;


my $nb_test_per_op = 8 ;
my @ops = (0,1,2,3,4,5,6,7) ;
plan(tests => 4 + $nb_test_per_op*(scalar(@ops))) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => ['ALU'],
) ;

# Testing of ALU instructions.
# Add contents of R1 and R2, result in R2
$BB->setREG("R1", "01100100") ; # 100
$BB->setREG("R2", "00110010") ; # 50
$BB->setRAM("00001000", "10000110") ; 
$BB->setREG("IAR", "00001000") ;
$BB->step() ;
is($BB->get("R2")->power(), "10010110", "100 + 50 = 150") ; # 150

# Add contents of R1 and R1, result in R1
$BB->setREG("R1", "01100100") ; # 100
$BB->setRAM("00001000", "10000101") ; 
$BB->setREG("IAR", "00001000") ;
$BB->step() ;
is($BB->get("R1")->power(), "11001000", "100 + 100 = 200") ; # 200

# Not contents of R0 back in R0
$BB->setREG("R0", "10101010") ; 
$BB->setRAM("00001001", "10110000") ; 
$BB->setREG("IAR", "00001001") ;
$BB->step() ;
is($BB->get("R0")->power(), "01010101", "NOT of 10101010 = 01010101") ;

# Bug with TMP.e
$BB->setREG("R3", "00111101") ; 
$BB->setRAM("00001010", "11001111") ; 
$BB->setREG("IAR", "00001010") ;
$BB->setREG("TMP", "00010111") ;
$BB->get("BUS1.bit1")->power("0") ; # Simulate a bit1 reset after step1 of the stepper.
$BB->step() ;
is($BB->get("R3")->power(), "00111101", "AND of 00111101 with itself = 00111101") ;


foreach my $op (@ops){
    for (my $j = 0 ; $j < $nb_test_per_op ; $j++){
        do_test_case($op) ;
    }
}


sub do_test_case {
    my $op = shift ;
    
    my $tc = gen_test_case() ;
    $tc->{op} = $op ;

    $tc->{ra} = int rand(4) ;
    $tc->{rb} = int rand(4) ;   
    if ($tc->{ra} == $tc->{rb}){
        $tc->{b} = $tc->{a} ;
        $tc->{binb} = sprintf("%08b", $tc->{b}) ;
    }
    # Create our instruction    
    $tc->{inst} = "1" . sprintf("%03b%02b%02b", $tc->{op}, $tc->{ra}, $tc->{rb}) ;

    my $res = alu($tc) ;
    my $vres = valu($tc, 1) ;

    my $desc = Dumper($tc) ;
    $desc =~ s/\n\s*//gs ;
    is_deeply($res, $vres, "inst:$tc->{inst}, $desc") ;
}


sub alu {
    my $tc = shift ;

    my %res = %{$tc} ;

    delete $res{ci} ; # No flags

    # Generate a random RAM address
    my $addr = sprintf("%08b", int rand(255)) ;

    # When this is implemented, there is no CLF instruction available yet.
    # We need to reset the FLAGS register because the presence of a trailing CI bit will give a bad answer.
    # We also bump s on TMP to let the value into the Ctmp M. 
    $BB->get("FLAGS")->is()->power("00000000") ;
    $BB->get("FLAGS")->s()->power(1) ;
    $BB->get("FLAGS")->s()->power(0) ;
    $BB->get("TMP")->s()->power(1) ;
    $BB->get("TMP")->s()->power(0) ;

    $BB->setREG("R$res{ra}", $res{bina}) ;
    $BB->setREG("R$res{rb}", $res{binb}) ;
    $BB->setRAM($addr, $res{inst}) ; 
    $BB->setREG("IAR", $addr) ;
    $BB->step() ;
    #warn Dumper($tc) ;
    #warn $BB->show() ;
    #for (my $j = 0 ; $j < 12 ; $j++){
    #    $BB->qtick() ;
    #    warn $BB->show() ;
    #}

    $res{out} = oct("0b" . $BB->get("R$res{rb}")->power()) if ($res{op} < 7) ;   

    if (defined($res{out})){
        $res{binout} = sprintf("%08b", $res{out}) ; 
    }

    return \%res ;
}