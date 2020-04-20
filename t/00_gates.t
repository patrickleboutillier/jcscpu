use strict ;
use Test::More ;
use Gates ;

plan(tests => 11) ;

# Basic tests for NAND gate.
my $g = new NAND() ;
my $wa = new WIRE($g->a()) ;
my $wb = new WIRE($g->b()) ;
my $wc = new WIRE($g->c()) ;

is($wc->power(), 1, "NAND(0,0)=1") ;
$wa->power(1) ;
is($wc->power(), 1, "NAND(1,0)=1") ;
$wb->power(1) ;
is($wc->power(), 0, "NAND(1,1)=0") ;
$wa->power(0) ;
is($wc->power(), 1, "NAND(0,1)=1") ;

my $wt = new WIRE() ;
eval {
    $wt->connect($g->c()) ;
} ;
like($@, qr/Pin already has wire attached!/, "Attaching wire on an already used pin.") ;

my $n = new NOT() ;
$wa = new WIRE($n->a()) ;
$wb = new WIRE($n->b()) ;

is($wb->power(), 1, "NOT(0)=1") ;
$wa->power(1) ;
is($wb->power(), 0, "NOT(1)=0") ;

my $a = new AND() ;
$wa = new WIRE($a->a()) ;
$wb = new WIRE($a->b()) ;
$wc = new WIRE($a->c()) ;

is($wc->power(), 0, "AND(0, 0)=0") ;
$wa->power(1) ;
is($wc->power(), 0, "AND(1, 0)=0") ;
$wb->power(1) ;
is($wc->power(), 1, "AND(1, 1)=1") ;
$wa->power(0) ;
is($wc->power(), 0, "AND(0, 1)=0") ;
