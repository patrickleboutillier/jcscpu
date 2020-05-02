use strict ;
use Test::More ;
use Breadboard ;


plan(tests => 8) ;


my $BB = new BREADBOARD() ;
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
# Since we are hooked on steps 4-5-6, the first 3 ticks do nothing...
$BB->get("CLK")->tick() ;
$BB->get("CLK")->tick() ;
$BB->get("CLK")->tick() ;
$BB->get("CLK")->tick() ;
is($BB->get("TMP")->ms(), "00010110", "TMP contains 00010110 (22)") ;
$BB->get("CLK")->tick() ;
is($BB->get("ACC")->ms(), "00101010", "ACC contains 00101010 (42)") ;
$BB->get("CLK")->tick() ;
is($BB->get("R0")->ms(), "00101010", "R0 contains 00101010 (42)") ;

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
    is($BB->get("R0")->ms(), "00010100", "R0 contains 00010100 (20)") ;
    is($BB->get("R1")->ms(), "00010110", "R1 contains 00010110 (22)") ;
} 