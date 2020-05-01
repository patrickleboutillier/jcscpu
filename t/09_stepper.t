use strict ;
use Test::More ;
use Clock ;
use Stepper ;

my $max_clock_ticks = 256 ;
plan(tests => 11 + $max_clock_ticks) ;

# STEPPER
# First we need a clock
my $wclk = new WIRE() ;
my $wclke = new WIRE() ;
my $wclks = new WIRE() ;
my $c = new CLOCK($wclk, $wclke, $wclks) ;

# First we make the stepper advance manually.
my $wrst = new WIRE() ;
my $bsteps = new BUS(7) ;
my $s = new STEPPER($wclk, $wrst, $bsteps) ;
# Connect step 7 wire to rst.
new CONN($bsteps->wire(6), $wrst) ;

is($bsteps->power(), "1000000", "initial state, step 1") ;
$c->tick() ;
is($bsteps->power(), "0100000", "step 2") ;
$c->tick() ;
is($bsteps->power(), "0010000", "step 3") ;
$c->tick() ;
is($bsteps->power(), "0001000", "step 4") ;
$c->tick() ;
is($bsteps->power(), "0000100", "step 5") ;
$c->tick() ;
is($bsteps->power(), "0000010", "step 6") ;
$c->tick() ;
is($bsteps->power(), "1000000", "step 1, auto reset") ;


# Now with an automatic clock
$wclk = new WIRE() ;
$wclke = new WIRE() ;
$wclks = new WIRE() ;
$c = new CLOCK($wclk, $wclke, $wclks, 256) ;

# First we make the stepper advance manually.
$wrst = new WIRE() ;
$bsteps = new BUS(7) ;
$s = new STEPPER($wclk, $wrst, $bsteps) ;
# Connect step 7 wire to rst.
new CONN($bsteps->wire(6), $wrst) ;

$wclk->prehook(sub{
    my $v = shift ;
    if ($v){
        my $tick = $c->ticks() % 6 ;
        my @os = split(//, $bsteps->power()) ;
        # Bit $tick should be on, and it should the the only one one.
        # If we set it to 0, we should have power = "0000000"
        $os[$tick] = "0" ;
        is(join('', @os), "0000000", "Proper step ($tick) should be set (" . $bsteps->power() . ")") ;
    }
}) ;

is($bsteps->power(), "1000000", "initial state, step 1") ;
eval {
    $c->start() ;
} ;
if ($@){
    like($@, qr/Max clock ticks/, "Clock stopped after max ticks") ;
}

