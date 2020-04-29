use strict ;
use Test::More ;
use Clock ;

plan(tests => 31) ;

# CLOCK
my $wclk = new WIRE() ;
my $wclke = new WIRE() ;
my $wclks = new WIRE() ;
my $c = new CLOCK($wclk, $wclke, $wclks, 2) ;
$c->clkd() ;

eval {
    $c->start(100) ;
} ;
if ($@){
    like($@, qr/Max clock ticks/, "Clock stopped after max (2) ticks") ;
}
is($c->qticks(), 8, "Clock did 8 qticks") ;


# Test with infite Hz
my $wclk = new WIRE() ;
my $wclke = new WIRE() ;
my $wclks = new WIRE() ;
my $c = new CLOCK($wclk, $wclke, $wclks, 2) ;
$c->clkd() ;

eval {
    $c->start() ;
} ;
if ($@){
    like($@, qr/Max clock ticks/, "Clock stopped after max (2) ticks") ;
}
is($c->qticks(), 8, "Clock did 8 qticks") ;

# The with no maxticks
my $wclk = new WIRE() ;
my $wclke = new WIRE() ;
my $wclks = new WIRE() ;
my $c = new CLOCK($wclk, $wclke, $wclks) ;
my $wclkd = $c->clkd() ;

# Add a prehook to clk to grab interrupt at the right moment.
$wclkd->prehook(sub { 
    my $nq = $c->qticks() ;
    die("INTERRUPT $nq") if $nq >= (2*4) ;
} ) ;
eval {
    $c->start() ;
} ;
if ($@){
    like($@, qr/INTERRUPT 8/, "Clock interrupted after 8 ticks") ;
}
is($c->qticks(), 8, "Clock did 8 qticks") ;


$wclk = new WIRE() ;
$wclke = new WIRE() ;
$wclks = new WIRE() ;
$c = new CLOCK($wclk, $wclke, $wclks) ;
map { $c->qtick() } (1..(2*4)) ;
is($c->qticks(), 8, "Clock did 8 qticks manually using qtick()") ;


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


# More precise clock cycle, qtick by qtick.
$wclk = new WIRE() ;
$wclke = new WIRE() ;
$wclks = new WIRE() ;
$c = new CLOCK($wclk, $wclke, $wclks) ;
$wclkd = $c->clkd() ;

# $CLOCK::DEBUG = 1 ;
$c->qtick() ;
is($wclk->power(),  1, "clk on") ;
is($wclkd->power(), 0, "clkd off") ;
is($wclke->power(), 1, "clke on") ;
is($wclks->power(), 0, "clks off") ;
$c->qtick() ;
is($wclk->power(),  1, "clk on") ;
is($wclkd->power(), 1, "clkd on") ;
is($wclke->power(), 1, "clke on") ;
is($wclks->power(), 1, "clks on") ;
$c->qtick() ;
is($wclk->power(),  0, "clk off") ;
is($wclkd->power(), 1, "clkd on") ;
is($wclke->power(), 1, "clke on") ;
is($wclks->power(), 0, "clks off") ;
$c->qtick() ;
is($wclk->power(),  0, "clk off") ;
is($wclkd->power(), 0, "clkd off") ;
is($wclke->power(), 0, "clke off") ;
is($wclks->power(), 0, "clks off") ;
$c->qtick() ;
is($wclk->power(),  1, "clk on") ;
is($wclkd->power(), 0, "clkd off") ;
is($wclke->power(), 1, "clke on") ;
is($wclks->power(), 0, "clks off") ;