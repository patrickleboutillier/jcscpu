use strict ;
use Test::More ;
use Memory ;

plan(tests => 7) ;

# Basic test for MEMORY circuit.
my $m = new MEMORY() ;
my $i = new WIRE() ;
my $s = new WIRE() ;
my $o = new WIRE() ;
$i->connect($m->i()) ;
$s->connect($m->s()) ;
$o->connect($m->o()) ;

$s->power(1) ;
is($o->power(), 0, "M(i:0,s:1)=o:0, s=on, i should equal o") ;
$i->power(1) ;
is($o->power(), 1, "M(i:1,s:1)=o:1, s=on, i should equal o") ;
$s->power(0) ;
is($o->power(), 1, "M(i:1,s:0)=o:1, s=off, i still equal to o") ;
$i->power(0) ;
is($o->power(), 1, "M(i:0,s:0)=o:1, s=off and i=off, o stays at 1") ;
$s->power(1) ;
is($o->power(), 0, "M(i:0,s:1)=o:0, s=on, o goes to 0 since i is 0") ;
$s->power(0) ;
is($o->power(), 0, "M(i:0,s:0)=o:0, s=off, i and o stay at 0") ;
$i->power(1) ;
is($o->power(), 0, "M(i:1,s:0)=o:0, s=off, o stays at 0") ;

