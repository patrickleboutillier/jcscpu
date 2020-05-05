use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;


my $nb_test_per_op = 32 ;
plan(tests => $nb_test_per_op) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => ['DATA'],
) ;

map { make_data_test() } (1..$nb_test_per_op) ;


# Testing of DATA instructions.
# Generate a random addr, 2 registers and data
sub make_data_test {
    my $a = int(rand(255)) ;
    my $iaddr = sprintf("%08b", $a) ;
    my $daddr = sprintf("%08b", $a + 1) ;
    my $rb = int rand(4) ;
    my $data = sprintf("%08b", int rand(256)) ;
    my $dinst = "001000" . sprintf("%02b", $rb) ;

    $BB->setRAM($iaddr, $dinst) ; 
    $BB->setRAM($daddr, $data) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->step() ; 
    is($BB->get("R$rb")->power(), $data, "$data copied from program (RAM\@$daddr) to R$rb") ;
}