use strict ;
use Test::More ;
use Memory ;

plan(tests => 7) ;

# Basic test for MEMORY circuit.
my $wi = new WIRE() ;
my $ws = new WIRE() ;
my $wo = new WIRE() ;
my $m = new MEMORY($wi, $ws, $wo) ;


$ws->power(1) ;
is($wo->power(), 0, "M(i:0,s:1)=o:0, s=on, i should equal o") ;
$wi->power(1) ;
is($wo->power(), 1, "M(i:1,s:1)=o:1, s=on, i should equal o") ;
$ws->power(0) ;
is($wo->power(), 1, "M(i:1,s:0)=o:1, s=off, i still equal to o") ;
$wi->power(0) ;
is($wo->power(), 1, "M(i:0,s:0)=o:1, s=off and i=off, o stays at 1") ;
$ws->power(1) ;
is($wo->power(), 0, "M(i:0,s:1)=o:0, s=on, o goes to 0 since i is 0") ;
$ws->power(0) ;
is($wo->power(), 0, "M(i:0,s:0)=o:0, s=off, i and o stay at 0") ;
$wi->power(1) ;
is($wo->power(), 0, "M(i:1,s:0)=o:0, s=off, o stays at 0") ;

