use strict ;
use Test::More ;
use Harness ;

plan(tests => 8) ;


my $h = new HARNESS({instructions => 0}) ;
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