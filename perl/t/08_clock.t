use strict ;
use Test::More ;
use Clock ;

plan(tests => 38) ;

# CLOCK
my $wclk = new WIRE() ;
my $wclke = new WIRE() ;
my $wclks = new WIRE() ;
my $c = new CLOCK($wclk, $wclke, $wclks, 2) ;
my $wclkd = $c->clkd() ;
is($c->qticks(), 0, "Clock starts with 0 completed qticks") ;
is($c->ticks(), 0, "Clock starts with 0 completed ticks") ;

eval {
    $c->start(100) ;
} ;
if ($@){
    like($@, qr/Max clock ticks/, "Clock stopped after max (2) ticks") ;
}
is($c->qticks(), 8, "Clock did 8 (+1) qticks") ;
is($c->ticks(), 2, "Clock did 2 ticks") ;


foreach my $mode (qw(gates loop)){
    $CLOCK::MODE = $mode ;

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
    is($c->qticks(), 8, "Clock did 8 (+1) qticks") ;

    # The with no maxticks
    my $wclk = new WIRE() ;
    my $wclke = new WIRE() ;
    my $wclks = new WIRE() ;
    my $c = new CLOCK($wclk, $wclke, $wclks) ;
    my $wclkd = $c->clkd() ;

    # Add a prehook to clk to grab interrupt at the right moment.
    $wclk->prehook(sub { 
        my $qt = $c->qticks() ;
        die("INTERRUPT $qt") if $qt >= (2*4) ;
    } ) ;
    eval {
        $c->start() ;
    } ;
    # Since we are interrupting the clock on a prehook, it will have done the next $qtick when we get the signal.
    # So when we stop it will have done an extra qtick.
     if ($@){
        like($@, qr/INTERRUPT 9/, "Clock interrupted after 9 ticks") ;
    }
    is($c->qticks(), 9, "Clock did 9 qticks") ;
}


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