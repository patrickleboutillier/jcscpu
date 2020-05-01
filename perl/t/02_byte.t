use strict ;
use Test::More ;
use Byte ;

plan(tests => 9) ;

# BYTE
my $bis = new BUS() ;
my $ws = new WIRE() ;
my $bos = new BUS() ;
my $B = new BYTE($bis, $ws, $bos) ;

$ws->power(1) ;
is($bos->power(), "00000000", "B(i:00000000,s:1)=o:00000000, s=on, i should equal o") ;
$bis->wire(0)->power(1) ;
is($bos->power(), "10000000", "B(i:10001000,s:1)=o:10001000, s=on, i should equal o") ;
$bis->wire(4)->power(1) ;
is($bos->power(), "10001000", "B(i:10001000,s:1)=o:10001000, s=on, i should equal o") ;
$ws->power(0) ;
is($bos->power(), "10001000", "B(i:10001000,s:0)=o:10001000, s=off, i still equal o") ;
$bis->wire(0)->power(0) ;
is($bos->power(), "10001000", "B(i:00001000,s:0)=o:10001000, s=off, o stays at 10001000") ;
$ws->power(1) ;
is($bos->power(), "00001000", "B(i:00001000,s:1)=o:00001000, s=on, o goes to 00001000 since i is 00001000") ;
$ws->power(0) ;
is($bos->power(), "00001000", "B(i:00001000,s:0)=o:00001000, s=on, i and o stay at 00001000") ;
$bis->wire(5)->power(1) ;
$bis->wire(6)->power(1) ;
$bis->wire(7)->power(1) ;
is($bos->power(), "00001000", "B(i:00001111,s:0)=o:00001000, s=off, o stays at 00001000") ;
$ws->power(1) ;
is($bos->power(), "00001111", "B(i:00001111,s:1)=o:00001111, s=on, o goes to i (00001111)") ;

