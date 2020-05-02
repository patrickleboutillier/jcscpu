use strict ;
use Test::More ;
use Breadboard ;

plan(tests => 7) ;
# $CLOCK::DEBUG = 1 ;

my $BB = new BREADBOARD('enaset' => 1,  'instruct' => 1) ;

# Place some fake instructions in RAM
init() ;

# Set the IAR to our start address
$BB->get("DATA.bus")->power("00000100") ;
$BB->get("IAR.s")->power(1) ;
$BB->get("IAR.s")->power(0) ;
is($BB->get("IAR")->power(), "00000100", "IAR set correctly") ;

$BB->get("CLK")->tick() ;
is($BB->get("RAM.MAR")->power(), "00000100", "RAM.MAR contains previous contents of IAR") ;
is($BB->get("ACC")->power(), "00000101", "ACC contains previous contents of IAR + 1") ;
$BB->get("CLK")->tick() ;
is($BB->get("IR")->power(), "10101010", "IR contains our first fake instruction") ;
$BB->get("CLK")->tick() ;
warn $BB->show() ;
exit ;
# is() ;


sub init {
    $BB->get("DATA.bus")->power("00000100") ;
    $BB->get("RAM.MAR.s")->power(1) ;
    $BB->get("RAM.MAR.s")->power(0) ;
    $BB->get("DATA.bus")->power("10101010") ;
    $BB->get("RAM.s")->power(1) ;
    $BB->get("RAM.s")->power(0) ;
    is($BB->get("RAM")->r("00000100")->power(), "10101010", "RAM set correctly at 00000100") ;
    $BB->get("DATA.bus")->power("00000101") ;
    $BB->get("RAM.MAR.s")->power(1) ;
    $BB->get("RAM.MAR.s")->power(0) ;
    $BB->get("DATA.bus")->power("01010101") ;
    $BB->get("RAM.s")->power(1) ;
    $BB->get("RAM.s")->power(0) ;
    is($BB->get("RAM")->r("00000101")->power(), "01010101", "RAM set correctly at 00000101") ;
    $BB->get("DATA.bus")->power("00000110") ;
    $BB->get("RAM.MAR.s")->power(1) ;
    $BB->get("RAM.MAR.s")->power(0) ;
    $BB->get("DATA.bus")->power("11110000") ;
    $BB->get("RAM.s")->power(1) ;
    $BB->get("RAM.s")->power(0) ;
    is($BB->get("RAM")->r("00000110")->power(), "11110000", "RAM set correctly at 00000110") ;
} 