use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;


my $nb_test_per_op = 32 ;
plan(tests => $nb_test_per_op*3) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => ['JUMP'],
) ;

map { make_jumpr_test() } (1..$nb_test_per_op) ;
map { make_jump_test() } (1..$nb_test_per_op) ;
map { make_jumpif_test() } (1..$nb_test_per_op) ;

# Testing of JUMP instructions.
sub make_jumpr_test {
    my $iaddr = sprintf("%08b", int rand(256)) ;
    my $jaddr = sprintf("%08b", int rand(256)) ;
    my $rb = int rand(4) ;
    my $jinst = "001100" . sprintf("%02b", $rb) ;

    $BB->setREG("R$rb", $jaddr) ;
    $BB->setRAM($iaddr, $jinst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->step() ; 
    is($BB->get("IAR")->power(), $jaddr, "IAR is now $jaddr") ;
}

sub make_jump_test {
    my $a = int(rand(255)) ;
    my $iaddr = sprintf("%08b", $a) ;
    my $i2addr = sprintf("%08b", $a + 1) ;
    my $jaddr = sprintf("%08b", int rand(256)) ;
    my $jinst = "01000000" ;

    $BB->setRAM($iaddr, $jinst) ; 
    $BB->setRAM($i2addr, $jaddr) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->step() ; 
    is($BB->get("IAR")->power(), $jaddr, "IAR is now $jaddr") ;
}

sub make_jumpif_test {
    my $a = int(rand(254)) ;
    my $iaddr = sprintf("%08b", $a) ;
    my $i2addr = sprintf("%08b", $a + 1) ;
    my $i3addr = sprintf("%08b", $a + 2) ;
    my $jaddr = sprintf("%08b", int rand(256)) ;
    my $aluflags = sprintf("%04b", int rand(4)) ;
    my $jflags = sprintf("%04b", int rand(4)) ;
    my $jinst = "0101$jflags" ;

    my $ba = new BUS() ;
    my $bb = new BUS() ;
    my $bc = new BUS() ;
    new ANDDER($ba, $bb, $bc) ;
    $ba->power($aluflags . "0000") ;
    $bb->power($jflags . "0000") ;
    my $jump = substr($bc->power(), 0, 4) ;
    my $wj = new WIRE() ;
    new ORn(4, $bc, $wj) ; 
    my $j = $wj->power() ;
    # warn "$jinst\@$iaddr: $aluflags | $jflags = $jump $j (jaddr=$jaddr, i3addr=$i3addr)" ;

    # Inject the flags in the FLAG reg input
    $BB->setRAM($iaddr, $jinst) ; 
    $BB->setRAM($i2addr, $jaddr) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->get("FLAGS")->is()->power($aluflags . "0000") ;
    $BB->get("FLAGS.s")->power(1) ;
    $BB->get("FLAGS.s")->power(0) ;
    $BB->step() ;

    if ($j){
        is($BB->get("IAR")->power(), $jaddr, "IAR is now $jaddr") ;
    }
    else {
        is($BB->get("IAR")->power(), $i3addr, "IAR is now $i3addr") ;
    }
}



