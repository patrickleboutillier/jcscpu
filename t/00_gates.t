use strict ;
use Test::More ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(all) ;
use Gates ;


plan(tests => 57) ;


# Coverage for WIRE
my $w = new WIRE() ;
$w->prehook(sub { ok(1, "Hook called") }) ;
$w->posthook(sub { ok(1, "Hook called") }) ;
$w->prehook() ;
$w->posthook() ;
$w->power(1) ;
$w->terminal() ;
$w->power(0) ;
is($w->power(), 1, "Terminal froze the wire") ;


# NAND
my $wa = new WIRE() ;
my $wb = new WIRE() ;
my $wc = new WIRE() ;
my $g = new NAND($wa, $wb, $wc) ;

is($wc->power(), 1, "NAND(0,0)=1") ;
$wa->power(1) ;
is($wc->power(), 1, "NAND(1,0)=1") ;
$wb->power(1) ;
is($wc->power(), 0, "NAND(1,1)=0") ;
$wa->power(0) ;
is($wc->power(), 1, "NAND(0,1)=1") ;


# Tests for wire reset
$wa->power(0) ;
$wb->power(1) ;
is($wc->power(), 1, "c=1 to start") ;
$wc->power(0) ;
is($wa->power(), 0, "a unchanged") ;
is($wb->power(), 1, "b unchanged") ;
is($wc->power(), 0, "c=0 forced on the wire") ;


# NOT
$wa = new WIRE() ;
$wb = new WIRE() ;
my $n = new NOT($wa, $wb) ;

is($wb->power(), 1, "NOT(0)=1") ;
$wa->power(1) ;
is($wb->power(), 0, "NOT(1)=0") ;


# AND
$wa = new WIRE() ;
$wb = new WIRE() ;
$wc = new WIRE() ;
my $a = new AND($wa, $wb, $wc) ;

is($wc->power(), 0, "AND(0, 0)=0") ;
$wa->power(1) ;
is($wc->power(), 0, "AND(1, 0)=0") ;
$wb->power(1) ;
is($wc->power(), 1, "AND(1, 1)=1") ;
$wa->power(0) ;
is($wc->power(), 0, "AND(0, 1)=0") ;


# OR
$wa = new WIRE() ;
$wb = new WIRE() ;
$wc = new WIRE() ;
my $o = new OR($wa, $wb, $wc) ;

is($wc->power(), 0, "OR(0, 0)=0") ;
$wa->power(1) ;
is($wc->power(), 1, "OR(1, 0)=1") ;
$wb->power(1) ;
is($wc->power(), 1, "OR(1, 1)=1") ;
$wa->power(0) ;
is($wc->power(), 1, "OR(0, 1)=1") ;


$wa = new WIRE() ;
$wb = new WIRE() ;
$wc = new WIRE() ;
my $xo = new XOR($wa, $wb, $wc) ;

is($wc->power(), 0, "XOR(0, 0)=0") ;
$wa->power(1) ;
is($wc->power(), 1, "XOR(1, 0)=1") ;
$wb->power(1) ;
is($wc->power(), 0, "XOR(1, 1)=0") ;
$wa->power(0) ;
is($wc->power(), 1, "XOR(0, 1)=1") ;


# ADD
my $wa = new WIRE() ;
my $wb = new WIRE() ;
my $wci = new WIRE() ;
my $wsum = new WIRE() ;
my $wco = new WIRE() ;
my $a = new ADD($wa, $wb, $wci, $wsum, $wco) ;

$wa->power(0) ;
$wb->power(0) ;
$wci->power(0) ;
is($wsum->power(), 0, "ADD(0,0,0)=(0,0)") ;
is($wco->power(),  0, "ADD(0,0,0)=(0,0)") ;
$wa->power(1) ;
$wb->power(0) ;
$wci->power(0) ;
is($wsum->power(), 1, "ADD(1,0,0)=(1,0)") ;
is($wco->power(),  0, "ADD(1,0,0)=(1,0)") ;
$wa->power(0) ;
$wb->power(1) ;
$wci->power(0) ;
is($wsum->power(), 1, "ADD(0,1,0)=(1,0)") ;
is($wco->power(),  0, "ADD(0,1,0)=(1,0)") ;
$wa->power(1) ;
$wb->power(1) ;
$wci->power(0) ;
is($wsum->power(), 0, "ADD(1,1,0)=(0,1)") ;
is($wco->power(),  1, "ADD(1,1,0)=(0,1)") ;

$wa->power(0) ;
$wb->power(0) ;
$wci->power(1) ;
is($wsum->power(), 1, "ADD(0,0,1)=(1,0)") ;
is($wco->power(),  0, "ADD(0,0,1)=(1,0)") ;
$wa->power(1) ;
$wb->power(0) ;
$wci->power(1) ;
is($wsum->power(), 0, "ADD(1,0,1)=(0,1)") ;
is($wco->power(),  1, "ADD(1,0,1)=(0,1)") ;
$wa->power(0) ;
$wb->power(1) ;
$wci->power(1) ;
is($wsum->power(), 0, "ADD(0,1,1)=(0,1)") ;
is($wco->power(),  1, "ADD(0,1,1)=(0,1)") ;
$wa->power(1) ;
$wb->power(1) ;
$wci->power(1) ;
is($wsum->power(), 1, "ADD(1,1,1)=(1,1)") ;
is($wco->power(),  1, "ADD(1,1,1)=(1,1)") ;


# Basic tests for CMP gate.
my $wa = new WIRE() ;
my $wb = new WIRE() ;
my $weqi = new WIRE() ;
my $wali = new WIRE() ;
my $wc = new WIRE() ;
my $weqo = new WIRE() ;
my $walo = new WIRE() ;
my $c = new CMP($wa, $wb, $weqi, $wali, $wc, $weqo, $walo) ;

$weqi->power(0) ;
$wali->power(0) ;
$wa->power(0) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,0,0], "CMP(a:0,b:0,eqi:0,ali:0)=(c:0,eqo:0,alo:0)") ;
$wa->power(0) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,0], "CMP(a:0,b:1,eqi:0,ali:0)=(c:1,eqo:0,alo:0)") ;
$wa->power(1) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,0], "CMP(a:1,b:0,eqi:0,ali:0)=(c:1,eqo:0,alo:0)") ;
$wa->power(1) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,0,0], "CMP(a:1,b:1,eqi:0,ali:0)=(c:0,eqo:0,alo:0)") ;

$weqi->power(0) ;
$wali->power(1) ;
$wa->power(0) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,0,1], "CMP(a:0,b:0,eqi:0,ali:1)=(c:0,eqo:0,alo:1)") ;
$wa->power(0) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,1], "CMP(a:0,b:1,eqi:0,ali:1)=(c:1,eqo:0,alo:1)") ;
$wa->power(1) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,1], "CMP(a:1,b:0,eqi:0,ali:1)=(c:1,eqo:0,alo:1)") ;
$wa->power(1) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,0,1], "CMP(a:1,b:1,eqi:0,ali:1)=(c:0,eqo:0,alo:1)") ;

$weqi->power(1) ;
$wali->power(0) ;
$wa->power(0) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,1,0], "CMP(a:0,b:0,eqi:1,ali:0)=(c:0,eqo:1,alo:0)") ;
$wa->power(0) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,0], "CMP(a:0,b:1,eqi:1,ali:0)=(c:1,eqo:0,alo:0)") ;
$wa->power(1) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,1], "CMP(a:1,b:0,eqi:1,ali:0)=(c:1,eqo:0,alo:1)") ;
$wa->power(1) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,1,0], "CMP(a:1,b:1,eqi:1,ali:0)=(c:0,eqo:1,alo:0)") ;


$weqi->power(1) ;
$wali->power(1) ;
$wa->power(0) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,1,1], "CMP(a:0,b:0,eqi:1,ali:1)=(c:0,eqo:1,alo:1)") ;
$wa->power(0) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,1], "CMP(a:0,b:1,eqi:1,ali:1)=(c:1,eqo:0,alo:1)") ;
$wa->power(1) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,1], "CMP(a:1,b:0,eqi:1,ali:1)=(c:1,eqo:0,alo:1)") ;
$wa->power(1) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,1,1], "CMP(a:1,b:1,eqi:1,ali:1)=(c:0,eqo:1,alo:1)") ;