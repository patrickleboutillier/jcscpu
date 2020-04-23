use strict ;
use Test::More ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(all) ;
use Gates ;


plan(tests => 20) ;


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
eval {
    WIRE->power_wires($wt, []) ;
} ;
like($@, qr/Length mismatch/, "Length mismatch") ;


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


my $o = new OR() ;
$wa = new WIRE($o->a()) ;
$wb = new WIRE($o->b()) ;
$wc = new WIRE($o->c()) ;

is($wc->power(), 0, "OR(0, 0)=0") ;
$wa->power(1) ;
is($wc->power(), 1, "OR(1, 0)=1") ;
$wb->power(1) ;
is($wc->power(), 1, "OR(1, 1)=1") ;
$wa->power(0) ;
is($wc->power(), 1, "OR(0, 1)=1") ;


my $xo = new XOR() ;
$wa = new WIRE($xo->a()) ;
$wb = new WIRE($xo->b()) ;
$wc = new WIRE($xo->c()) ;

is($wc->power(), 0, "XOR(0, 0)=0") ;
$wa->power(1) ;
is($wc->power(), 1, "XOR(1, 0)=1") ;
$wb->power(1) ;
is($wc->power(), 0, "XOR(1, 1)=0") ;
$wa->power(0) ;
is($wc->power(), 1, "XOR(0, 1)=1") ;

