use strict ;
use Test::More ;
use Harness ;

plan(tests => 1) ;


my $h = new HARNESS() ;

# Place some fake instructions in RAM
$h->get("DATA.bus")->power("00000100") ;
$h->get("RAM.MAR.s")->power(1) ;
$h->get("RAM.MAR.s")->power(0) ;
$h->get("DATA.bus")->power("10101010") ;
$h->get("RAM.s")->power(1) ;
$h->get("RAM.s")->power(0) ;
is($h->get("RAM")->r("00000100")->ms(), "10101010", "RAM set correctly at 00000100") ;
$h->get("DATA.bus")->power("00000101") ;
$h->get("RAM.MAR.s")->power(1) ;
$h->get("RAM.MAR.s")->power(0) ;
$h->get("DATA.bus")->power("01010101") ;
$h->get("RAM.s")->power(1) ;
$h->get("RAM.s")->power(0) ;
is($h->get("RAM")->r("00000101")->ms(), "01010101", "RAM set correctly at 00000101") ;
$h->get("DATA.bus")->power("00000110") ;
$h->get("RAM.MAR.s")->power(1) ;
$h->get("RAM.MAR.s")->power(0) ;
$h->get("DATA.bus")->power("11110000") ;
$h->get("RAM.s")->power(1) ;
$h->get("RAM.s")->power(0) ;
is($h->get("RAM")->r("00000110")->ms(), "11110000", "RAM set correctly at 00000110") ;

# Set the IAR to our start address
$h->get("DATA.bus")->power("00000100") ;
$h->get("IAR.s")->power(1) ;
$h->get("IAR.s")->power(0) ;
is($h->get("IAR")->ms(), "00000100", "IAR set correctly") ;

warn $h->show() ;
$h->start() ;
$h->get("CLK")->tick() ;
warn $h->show() ;
exit ;

$h->get("CLK")->tick() ;
$h->get("CLK")->tick() ;
is($h->get("TMP")->ms(), "00010110", "TMP contains 00010110 (22)") ;
$h->get("CLK")->tick() ;
is($h->get("ACC")->ms(), "00101010", "ACC contains 00101010 (42)") ;
$h->get("CLK")->tick() ;
is($h->get("R0")->ms(), "00101010", "R0 contains 00101010 (42)") ;

__DATA__
$h->show() ;

# Add our extra connections to the Harness
my $steps = $h->get("STP.bus") ;
my $clke = $h->get("CLK.clke") ;
new AND($clke, $steps->wire(5), $h->get("ACC.e")) ;
# Specific to my installation (extra enabler in ALU)
new AND($clke, $steps->wire(4), $h->get("ALU.op.e")) ;
new AND($clke, $steps->wire(4), $h->get("R0.e")) ;
new AND($clke, $steps->wire(3), $h->get("R1.e")) ;
my $clks = $h->get("CLK.clks") ;
new AND($clks, $steps->wire(3), $h->get("TMP.s")) ;
new AND($clks, $steps->wire(4), $h->get("ACC.s")) ;
new AND($clks, $steps->wire(5), $h->get("R0.s")) ;

# Check our binary values.
is(oct('0b00010100'), 20, "00010100=20") ;
is(oct('0b00010110'), 22, "00010110=22") ;
is(oct('0b00101010'), 42, "00101010=42") ;

# Initialize registers with vaues.
init() ;

# $CLOCK::DEBUG = 1 ;
# Since we are hooked on stesp 4-5-6, the first 3 ticks do nothing...
$h->get("CLK")->tick() ;
$h->get("CLK")->tick() ;
$h->get("CLK")->tick() ;
is($h->get("TMP")->ms(), "00010110", "TMP contains 00010110 (22)") ;
$h->get("CLK")->tick() ;
is($h->get("ACC")->ms(), "00101010", "ACC contains 00101010 (42)") ;
$h->get("CLK")->tick() ;
is($h->get("R0")->ms(), "00101010", "R0 contains 00101010 (42)") ;


sub init {
    # Put a number on the data bus, say 20.
    $h->get("DATA.bus")->power("00010100") ;
    # Let in go into R0.
    $h->get("R0.s")->power(1) ;
    $h->get("R0.s")->power(0) ;
    # Put a different number on the data bus, say 22.
    $h->get("DATA.bus")->power("00010110") ;
    # Let in go into R1.
    $h->get("R1.s")->power(1) ;
    $h->get("R1.s")->power(0) ;
    is($h->get("R0")->ms(), "00010100", "R0 contains 00010100 (20)") ;
    is($h->get("R1")->ms(), "00010110", "R1 contains 00010110 (22)") ;
} 