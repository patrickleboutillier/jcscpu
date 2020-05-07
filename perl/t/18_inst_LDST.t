use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;


my $nb_test_per_op = 16 ;
plan(tests => $nb_test_per_op*2*2) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => ['LDST'],
) ;

map { make_load_test() } (1..$nb_test_per_op) ;
map { make_store_test() } (1..$nb_test_per_op) ;


# Testing of LOAD/STORE instructions.
# Generate a random addr, 2 registers and data
sub make_load_test {
    my $a = int(rand(255)) + 1 ;
    my $addr = sprintf("%08b", $a) ;
    my $iaddr = sprintf("%08b", $a - 1) ;
    my $ra = int rand(4) ;
    my $rb = int rand(4) ;
    my $data = sprintf("%08b", int rand(256)) ;
    my $linst = "0000" . sprintf("%02b%02b", $ra, $rb) ;

    $BB->setREG("R$ra", $addr) ;
    $BB->setRAM($addr, $data) ; 
    $BB->setRAM($iaddr, $linst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ; 
    is($BB->get("R$rb")->power(), $data, "$data copied from RAM\@$addr (R$ra) to R$rb") ;
    is($BB->get("IAR")->power(), $addr, "IAR has advanced to $addr") ;
}


sub make_store_test {
    my $a = int(rand(255)) + 1 ;
    my $addr = sprintf("%08b", $a) ;
    my $iaddr = sprintf("%08b", $a - 1) ;
    my $ra = int rand(4) ;
    my $rb = int rand(4) ;
    my $data = sprintf("%08b", int rand(256)) ;
    my $linst = "0001" . sprintf("%02b%2b", $ra, $rb) ;

    $BB->setREG("R$ra", $addr) ;
    $BB->setREG("R$rb", $data) ;
    $BB->setRAM($iaddr, $linst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;
    is($BB->get("R$rb")->power(), $data, "$data stored from R$rb to RAM\@$addr") ;
    is($BB->get("IAR")->power(), $addr, "IAR has advanced to $addr") ;
}
