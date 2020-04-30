use strict ;
use Test::More ;
use Memory ;

plan(tests => 20) ;

# Basic test for MEMORY circuit.
my $wi = new WIRE() ;
my $ws = new WIRE() ;
my $wo = new WIRE() ;
my $m = new MEMORY($wi, $ws, $wo) ;

is($wo->power(), 0, "M(i:0,s:0)=o:0, s=off, o should be initialized at 0") ;
$ws->power(1) ;
is($wo->power(), 0, "M(i:0,s:1)=o:0, s=on, o should equal i") ;
$wi->power(1) ;
is($wo->power(), 1, "M(i:1,s:1)=o:1, s=on, o should equal i") ;
$ws->power(0) ;
is($wo->power(), 1, "M(i:1,s:0)=o:1, s=off, o still equal to i") ;
$wi->power(0) ;
is($wo->power(), 1, "M(i:0,s:0)=o:1, s=off and i=off, o stays at 1") ;
$ws->power(1) ;
is($wo->power(), 0, "M(i:0,s:1)=o:0, s=on, o goes to 0 since i is 0") ;
$ws->power(0) ;
is($wo->power(), 0, "M(i:0,s:0)=o:0, s=off, i and o stay at 0") ;
$wi->power(1) ;
is($wo->power(), 0, "M(i:1,s:0)=o:0, s=off, o stays at 0") ;


# More specific cases...
$wi = new WIRE() ;
$ws = new WIRE() ;
$wo = new WIRE() ;
$m = new MEMORY($wi, $ws, $wo) ;
is($wo->power(), 0, "M(i:0,[0],s:0)=o:0") ;
is($m->m(), 0, "M(i:0,[0],s:0)=o:0") ;
$ws->power(1) ;
is($wo->power(), 0, "M(i:0,[0],s:0)=o:0") ;
is($m->m(), 0, "M(i:0,[0],s:0)=o:0") ;

$ws->power(0) ;
$wi->power(1) ;
is($wo->power(), 0, "M(i:0,[0],s:0)=o:0") ;
is($m->m(), 0, "M(i:i,[0],s:0)=o:0") ;


$wi = new WIRE() ;
$ws = new WIRE() ;
$wo = new WIRE() ;
$m = new MEMORY($wi, $ws, $wo) ;
is($wo->power(), 0, "M(i:0,[0],s:0)=o:0") ;
is($m->m(), 0, "M(i:0,[0],s:0)=o:0") ;
$ws->power(1) ;
is($wo->power(), 0, "M(i:0,[0],s:0)=o:0") ;
is($m->m(), 0, "M(i:0,[0],s:0)=o:0") ;

$wi->power(1) ;
$ws->power(0) ;
is($wo->power(), 1, "M(i:1,[1],s:0)=o:1") ;
is($m->m(), 1, "M(i:1,[1],s:0)=o:1") ;