use strict ;
use Test::More ;
use Gates ;

plan(tests => 4) ;

# Basic tests for NAND gate.
my $g = new NAND() ;
my $wa = new WIRE() ;
$wa->connect($g->a()) ;
my $wb = new WIRE() ;
$wb->connect($g->b()) ;
my $wc = new WIRE() ;
$wc->connect($g->c()) ;

is($wc->power(), 1, "NAND(0,0)=1") ;
$wa->power(1) ;
is($wc->power(), 1, "NAND(1,0)=1") ;
$wb->power(1) ;
is($wc->power(), 0, "NAND(1,1)=0") ;
$wa->power(0) ;
is($wc->power(), 1, "NAND(0,1)=1") ;