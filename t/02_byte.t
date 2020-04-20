use strict ;
use Test::More ;
use Byte ;

plan(tests => 9) ;

# Basic test for BYTE circuit.
my $B = new BYTE() ;
my @bis = $B->is() ;
my @wis = () ;
for (my $j = 0 ; $j < 8 ; $j++){
    my $i = new WIRE($bis[$j]) ;
    push @wis, $i ;   
}
my $ws = new WIRE($B->s()) ;
my @bos = $B->os() ;
my @wos = () ;
for (my $j = 0 ; $j < 8 ; $j++){
    my $o = new WIRE($bos[$j]) ;    
    push @wos, $o ;  
}

$ws->power(1) ;
is(WIRE->show(@wos), "00000000", "B(i:00000000,s:1)=o:00000000, s=on, i should equal o") ;
$wis[0]->power(1) ;
is(WIRE->show(@wos), "10000000", "B(i:10001000,s:1)=o:10001000, s=on, i should equal o") ;
$wis[4]->power(1) ;
is(WIRE->show(@wos), "10001000", "B(i:10001000,s:1)=o:10001000, s=on, i should equal o") ;
$ws->power(0) ;
is(WIRE->show(@wos), "10001000", "B(i:10001000,s:0)=o:10001000, s=off, i still equal o") ;
$wis[0]->power(0) ;
is(WIRE->show(@wos), "10001000", "B(i:00001000,s:0)=o:10001000, s=off, o stays at 10001000") ;
$ws->power(1) ;
is(WIRE->show(@wos), "00001000", "B(i:00001000,s:1)=o:00001000, s=on, o goes to 00001000 since i is 00001000") ;
$ws->power(0) ;
is(WIRE->show(@wos), "00001000", "B(i:00001000,s:0)=o:00001000, s=on, i and o stay at 00001000") ;
$wis[5]->power(1) ;
$wis[6]->power(1) ;
$wis[7]->power(1) ;
is(WIRE->show(@wos), "00001000", "B(i:00001111,s:0)=o:00001000, s=off, o stays at 00001000") ;
$ws->power(1) ;
is(WIRE->show(@wos), "00001111", "B(i:00001111,s:1)=o:00001111, s=on, o goes to i (00001111)") ;

