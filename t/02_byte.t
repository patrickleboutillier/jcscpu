use strict ;
use Test::More ;
use Byte ;

plan(tests => 9) ;

# BYTE
my $wis = new WIRES(8) ;
my $ws = new WIRE() ;
my $wos = new WIRES(8) ;
my $B = new BYTE($wis, $ws, $wos) ;

$ws->power(1) ;
is($wos->power(), "00000000", "B(i:00000000,s:1)=o:00000000, s=on, i should equal o") ;
$wis->wire(0)->power(1) ;
is($wos->power(), "10000000", "B(i:10001000,s:1)=o:10001000, s=on, i should equal o") ;
$wis->wire(4)->power(1) ;
is($wos->power(), "10001000", "B(i:10001000,s:1)=o:10001000, s=on, i should equal o") ;
$ws->power(0) ;
is($wos->power(), "10001000", "B(i:10001000,s:0)=o:10001000, s=off, i still equal o") ;
$wis->wire(0)->power(0) ;
is($wos->power(), "10001000", "B(i:00001000,s:0)=o:10001000, s=off, o stays at 10001000") ;
$ws->power(1) ;
is($wos->power(), "00001000", "B(i:00001000,s:1)=o:00001000, s=on, o goes to 00001000 since i is 00001000") ;
$ws->power(0) ;
is($wos->power(), "00001000", "B(i:00001000,s:0)=o:00001000, s=on, i and o stay at 00001000") ;
$wis->wire(5)->power(1) ;
$wis->wire(6)->power(1) ;
$wis->wire(7)->power(1) ;
is($wos->power(), "00001000", "B(i:00001111,s:0)=o:00001000, s=off, o stays at 00001000") ;
$ws->power(1) ;
is($wos->power(), "00001111", "B(i:00001111,s:1)=o:00001111, s=on, o goes to i (00001111)") ;

