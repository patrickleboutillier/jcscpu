use strict ;
use Test::More ;
use Clock ;
use Stepper ;

my $max_clock_ticks = 256 ;
plan(tests => 11 + $max_clock_ticks*2) ;

# STEPPER
# First we need a clock
my $wclk = new WIRE() ;
my $wclke = new WIRE() ;
my $wclks = new WIRE() ;
my $c = new CLOCK($wclk, $wclke, $wclks) ;

# First we make the stepper advance manually.
my $bsteps = new BUS(7) ;
my $s = new STEPPER($wclk, $bsteps) ;
$s->show() ;

is($bsteps->power(), "0000000", "initial state, step 0") ;
$c->tick() ;
is($bsteps->power(), "1000000", "step 1") ;
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
$bsteps = new BUS(7) ;
$s = new STEPPER($wclk, $bsteps) ;

is($c->qticks(), 0, "Starting test at qtick 0") ;
is($c->ticks(), 0, "Starting test at tick 0") ;
is($bsteps->power(), "0000000", "initial state, step 7") ;
# Get out of step 7 by doing one click.
$c->tick() ;

$wclk->prehook(sub{
    my $v = shift ;
    if ($v){
        # Since ticks() has already been incremented to the next tick by the clock prehook, 
        # Subtract 1 from it.
        my $t = $c->ticks() - 1 ;
        my $tmod6 = ($t % 6) ;
        is($s->step(), $tmod6 + 1, "Step is $t") ; # steps os 1-6

        # Check the matching power value
        my @os = split(//, $bsteps->power()) ;
        # Bit $t should be on, and it should the the only one one.
        # If we set it to 0, we should have power = "0000000"
        $os[$tmod6] = "0" ;
        is(join('', @os), "0000000", "Proper step ($t) should be set (" . $bsteps->power() . ")") ;
    }
}) ;


eval {
    $c->start() ;
} ;
if ($@){
    like($@, qr/Max clock ticks/, "Clock stopped after max ticks") ;
}
is($c->qticks(), 1024, "Clock did 1024 qticks") ;
