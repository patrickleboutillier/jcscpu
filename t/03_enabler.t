use strict ;
use Test::More ;
use Enabler ;

plan(tests => 7) ;

# Basic test for ENABLER circuit.
my $E = new ENABLER() ;
my @eis = $E->is() ;
my @wis = () ;
for (my $j = 0 ; $j < 8 ; $j++){
    my $i = new WIRE($eis[$j]) ;
    push @wis, $i ;    
}
my $we = new WIRE($E->e()) ;
my @eos = $E->os() ;
my @wos = () ;
for (my $j = 0 ; $j < 8 ; $j++){
    my $o = new WIRE($eos[$j]) ;    
    push @wos, $o ;    
}


$wis[0]->power(1) ;
is(WIRE->show(@wos), "00000000", "B(i:10001000,e:0)=o:00000000, e=off, no output") ;
$wis[4]->power(1) ;
is(WIRE->show(@wos), "00000000", "B(i:10001000,e:0)=o:00000000, e=off, i should equal o") ;
$we->power(1) ;
is(WIRE->show(@wos), "10001000", "B(i:10001000,e:1)=o:10001000, e=on, i goes through") ;
$wis[4]->power(0) ;
is(WIRE->show(@wos), "10000000", "B(i:10000000,e:1)=o:10000000, e=on, i goes through") ;
$wis[0]->power(0) ;
is(WIRE->show(@wos), "00000000", "B(i:00000000,e:1)=o:00000000, e=on, i goes through") ;
$wis[7]->power(1) ;
is(WIRE->show(@wos), "00000001", "B(i:00000001,e:1)=o:00000001, e=on, i goes through") ;
$we->power(0) ;
is(WIRE->show(@wos), "00000000", "B(i:00000001,e:0)=o:00000000, e=off, no output") ;
