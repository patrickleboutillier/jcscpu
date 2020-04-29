use strict ;
use Test::More ;
use Clock ;

plan(tests => 7) ;

# CLOCK
my $wclk = new WIRE() ;
my $wclke = new WIRE() ;
my $wclks = new WIRE() ;
my $c = new CLOCK($wclk, $wclke, $wclks) ;

eval {
    $c->start(1, 2) ;
} ;
if ($@){
    like($@, qr/Max clock ticks/, "Clock stopped after max (2) ticks") ;
}
is($c->qticks(), 8, "Clock did 8 qticks") ;


$wclk = new WIRE() ;
$wclke = new WIRE() ;
$wclks = new WIRE() ;
$c = new CLOCK($wclk, $wclke, $wclks) ;
map { $c->qtick() } (1..(2*4)) ;
is($c->qticks(), 8, "Clock did 8 qticks") ;


$wclk = new WIRE() ;
$wclke = new WIRE() ;
$wclks = new WIRE() ;
$c = new CLOCK($wclk, $wclke, $wclks) ;
map { $c->tick() } (1..2) ;
is($c->qticks(), 8, "Clock did 8 qticks") ;
map { $c->qtick() } (1..4) ;
is($c->qticks(), 12, "Clock did 12 qticks") ;
$c->qtick() ;
is($c->qticks(), 13, "Clock did 13 qticks") ;
eval {
    $c->tick() ;
} ;
if ($@){
    like($@, qr/Can't tick a clock mid-cycle/, "Clock can't tick mid-cycle") ;   
}