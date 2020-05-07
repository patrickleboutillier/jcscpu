use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;


my $nb_test_per_op = 32 ;
plan(tests => $nb_test_per_op) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => ['CLF'],
) ;

map { make_clf_test() } (1..$nb_test_per_op) ;


sub make_clf_test {
    my $a = int(rand(256)) ;
    my $iaddr = sprintf("%08b", $a) ;
    my $aluflags = sprintf("%04b", int rand(4)) ;
    my $cinst = "01100000" ;

    # Inject the flags in the FLAG reg input
    $BB->get("FLAGS")->is()->power($aluflags . "0000") ;
    $BB->get("FLAGS.s")->power(1) ;
    $BB->get("FLAGS.s")->power(0) ;
    $BB->setRAM($iaddr, $cinst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;

    is($BB->get("FLAGS")->power(), "00001111", "FLAGS reset") ;
}



