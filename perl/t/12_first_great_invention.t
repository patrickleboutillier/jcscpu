use strict ;
use Test::More ;
use Breadboard ;

plan(tests => 1) ;
$CLOCK::DEBUG = 1 ;

my $BB = new BREADBOARD('enaset' => 1,  'instruct' => 1) ;

# Place some fake instructions in RAM
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

# Set the IAR to our start address
$BB->get("DATA.bus")->power("00000100") ;
$BB->get("IAR.s")->power(1) ;
$BB->get("IAR.s")->power(0) ;
is($BB->get("IAR")->power(), "00000100", "IAR set correctly") ;

warn $BB->show() ;
$BB->get("CLK")->tick() ;
warn $BB->show() ;
is($BB->get("RAM.MAR")->power(), "00000100", "RAM.MAR contains previous contents of IAR") ;
is($BB->get("ACC")->power(), "00000101", "ACC contains previous contents of IAR + 1") ;
$BB->get("CLK")->tick() ;
is($BB->get("IR")->power(), "10101010", "IR contains our first fake instruction") ;
exit
$BB->get("CLK")->tick() ;
is($BB->get("R0")->power(), "00101010", "R0 contains 00101010 (42)") ;

__DATA__
$BB->show() ;

# Add our extra connections to the Harness
my $steps = $BB->get("STP.bus") ;
my $clke = $BB->get("CLK.clke") ;
new AND($clke, $steps->wire(5), $BB->get("ACC.e")) ;
# Specific to my installation (extra enabler in ALU)
new AND($clke, $steps->wire(4), $BB->get("ALU.op.e")) ;
new AND($clke, $steps->wire(4), $BB->get("R0.e")) ;
new AND($clke, $steps->wire(3), $BB->get("R1.e")) ;
my $clks = $BB->get("CLK.clks") ;
new AND($clks, $steps->wire(3), $BB->get("TMP.s")) ;
new AND($clks, $steps->wire(4), $BB->get("ACC.s")) ;
new AND($clks, $steps->wire(5), $BB->get("R0.s")) ;

# Check our binary values.
is(oct('0b00010100'), 20, "00010100=20") ;
is(oct('0b00010110'), 22, "00010110=22") ;
is(oct('0b00101010'), 42, "00101010=42") ;

# Initialize registers with vaues.
init() ;

# $CLOCK::DEBUG = 1 ;
# Since we are hooked on stesp 4-5-6, the first 3 ticks do nothing...
$BB->get("CLK")->tick() ;
$BB->get("CLK")->tick() ;
$BB->get("CLK")->tick() ;
is($BB->get("TMP")->power(), "00010110", "TMP contains 00010110 (22)") ;
$BB->get("CLK")->tick() ;
is($BB->get("ACC")->power(), "00101010", "ACC contains 00101010 (42)") ;
$BB->get("CLK")->tick() ;
is($BB->get("R0")->power(), "00101010", "R0 contains 00101010 (42)") ;


sub init {
    # Put a number on the data bus, say 20.
    $BB->get("DATA.bus")->power("00010100") ;
    # Let in go into R0.
    $BB->get("R0.s")->power(1) ;
    $BB->get("R0.s")->power(0) ;
    # Put a different number on the data bus, say 22.
    $BB->get("DATA.bus")->power("00010110") ;
    # Let in go into R1.
    $BB->get("R1.s")->power(1) ;
    $BB->get("R1.s")->power(0) ;
    is($BB->get("R0")->power(), "00010100", "R0 contains 00010100 (20)") ;
    is($BB->get("R1")->power(), "00010110", "R1 contains 00010110 (22)") ;
} 