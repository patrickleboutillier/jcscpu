use strict ;
use Test::More ;
use Harness ;

plan(tests => 30) ;


my $h = new HARNESS({instructions => 0}) ;
$h->show() ;

is(oct('0b00010100'), 20, "00010100=20") ;
is(oct('0b00010110'), 22, "00010110=22") ;
is(oct('0b00101010'), 42, "00101010=42") ;

# First time, manually
init() ;
cycle1() ;
cycle2() ;
cycle3() ;

# Second time, manually
init() ;
cycle1() ;
cycle2() ;
cycle3() ;

# Third time, using the stepper (manually)
$h->get("STP.bus")->wire(0)->prehook(sub { cycle1() if $_[0] }) ;
$h->get("STP.bus")->wire(1)->prehook(sub { cycle2() if $_[0] }) ;
$h->get("STP.bus")->wire(2)->prehook(sub { cycle3() if $_[0] }) ;
$h->get("STP.bus")->wire(3)->prehook(sub { is($h->get("STP")->step(), 3, "Step 4 does nothing!") if $_[0] }) ;
$h->get("STP.bus")->wire(4)->prehook(sub { is($h->get("STP")->step(), 4, "Step 5 does nothing!") if $_[0] }) ;
$h->get("STP.bus")->wire(5)->prehook(sub { is($h->get("STP")->step(), 5, "Step 6 does nothing!") if $_[0] }) ;
$h->get("STP.bus")->wire(6)->posthook(sub { is($h->get("STP")->step(), 0, "Stepper reset!") if $_[0] }) ;
init() ;
$h->get("CLK")->tick() ;
$h->get("CLK")->tick() ;
$h->get("CLK")->tick() ;
is($h->get("STP")->step(), 3, "Stepper is at step 4") ;

# Fourth time, using the stepper (automatically)
init() ;
eval {
    $h->get("CLK")->start(0, $h->get("CLK")->ticks() + 6) ;
} ;
if ($@){
    is($h->get("CLK")->ticks(), 9, "Clock is at 9 ticks") ;
    like($@, qr/Max clock ticks/, "Clock stopped after max ticks") ;
}


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


sub cycle1 {
    $h->get("R1.e")->power(1) ;
        $h->get("TMP.s")->power(1) ;
        $h->get("TMP.s")->power(0) ;
    $h->get("R1.e")->power(0) ;
    is($h->get("TMP")->ms(), "00010110", "TMP contains 00010110 (22)") ;
}


sub cycle2 {
    $h->get("R0.e")->power(1) ;
    $h->get("ALU.op")->power("000") ;
    $h->get("ALU.op.e")->power(1) ;
        $h->get("ACC.s")->power(1) ;
        $h->get("ACC.s")->power(0) ;
    $h->get("ALU.op.e")->power(0) ; 
    $h->get("R0.e")->power(0) ;
    is($h->get("ACC")->ms(), "00101010", "ACC contains 00101010 (42)") ;
}


sub cycle3 {
    $h->get("ACC.e")->power(1) ;
        $h->get("R0.s")->power(1) ;
        $h->get("R0.s")->power(0) ;
    $h->get("ACC.e")->power(0) ;
    is($h->get("R0")->ms(), "00101010", "R0 contains 00101010 (42)") ;
}


__DATA__
Let's say that we want to do something useful, like adding one number to another number. 
We have a number in R0, and there is another number in R1 that we want to add to the number in R0. 
The processor we have built so far has all of the connections to do this addition, 
but it will take more than one clock cycle to do it. 
In the first clock cycle, we can enable R1 onto the bus, and set it into TMP. 
In the second cycle we can enable R0 onto the bus, set the ALU to ADD, and set the answer into ACC. 
In the third cycle, we can enable ACC onto the bus, and set it into Ro. We now have the old value of R0, 
plus R1 in R0. Perhaps this doesn't seem very useful, 