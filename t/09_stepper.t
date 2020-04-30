use strict ;
use Test::More ;
use Clock ;
use Stepper ;

plan(tests => 1) ;

# STEPPER
# First we need a clock
my $wclk = new WIRE() ;
my $wclke = new WIRE() ;
my $wclks = new WIRE() ;
my $c = new CLOCK($wclk, $wclke, $wclks) ;

my $wrst = new WIRE() ;
my $bsteps = new BUS(7) ;
my $s = new STEPPER($wclk, $wrst, $bsteps) ;
warn $s->show() ;
$wclk->power(1) ;
warn $s->show() ;
$wclk->power(0) ;
warn $s->show() ;