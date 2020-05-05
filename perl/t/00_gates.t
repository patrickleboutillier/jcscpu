use strict ;
use Test::More ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(all) ;
use Gates ;


my $max_n_tests = 8 ;
plan(tests => 58 +
    8 + nb_andn_tests() + nb_orn_tests()) ;


# Coverage for WIRE
my $w = new WIRE() ;
$w->prehook(sub { ok(1, "Hook called") }) ;
$w->posthook(sub { ok(1, "Hook called") }) ;
$w->prehook() ;
$w->posthook() ;
$w->power(1) ;
$w->terminal() ;
$w->power(0) ;
$w->pause() ;
is($w->power(), 1, "Terminal froze the wire") ;
$w->power(0, 1) ;
$w->power(1, 1) ;

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




# ANDn
map { make_andn_test($_, 0) } (2..$max_n_tests) ;
map { make_andn_test($_, 1) } (2..$max_n_tests) ;

eval {
    new ANDn(1, new BUS(), new WIRE()) ;
} ;
like($@, qr/Invalid ANDn number of inputs/, "Invalid ANDn number of inputs <=2") ;
my $a = new ANDn(4, , new BUS(), new WIRE()) ;
$a->i(0) ;
is($a->n(), 4, "Size of ANDn") ;
eval { $a->i(-1) } ;
like($@, qr/Invalid input index/, "Invalid input index <0") ;
eval { $a->i(6) } ;
like($@, qr/Invalid input index/, "Invalid input index >n") ;


# ORn
map { make_orn_test($_, 0) } (2..$max_n_tests) ;
map { make_orn_test($_, 1) } (2..$max_n_tests) ;

eval {
    new ORn(1, new BUS(), new WIRE()) ;
} ;
like($@, qr/Invalid ORn number of inputs/, "Invalid ORn number of inputs <=2") ;
my $o = new ORn(4, new BUS(), new WIRE()) ;
$o->i(0) ;
is($o->n(), 4, "Size of ORn") ;
eval { $o->i(-1) ;} ;
like($@, qr/Invalid input index/, "Invalid input index <0") ;
eval { $o->i(6) ;} ;
like($@, qr/Invalid input index/, "Invalid input index >n") ;


# ORe coverage
my $o = new ORe(new WIRE()) ;
map { $o->add(new WIRE()) } (0..5) ;
eval {
    $o->add(new WIRE()) ;
} ;
like($@, qr/Elastic OR has reached maximum capacity/) ;



sub nb_andn_tests {
    my $sum = 0 ;
    for (my $j = 2 ; $j <= $max_n_tests ; $j++){
        $sum += 2 ** $j ;    
    }    
    return $sum * 2 ;
}


sub make_andn_test {
    my $n = shift ;
    my $random = shift ;

    my $bis = new BUS($n) ;
    my $wo = new WIRE() ;
    my $a = new ANDn($n, $bis, $wo) ;

    my @ts = map { ($random ? int rand(2**$n) : $_) } (0 .. ((2**$n)-1)) ;
    foreach my $t (@ts){
        my $bin = sprintf("%0${n}b", $t) ;
        $bis->power($bin) ;
        my $res = ($t == ((2**$n)-1)) || 0 ;
        is($wo->power(), $res, "AND$n($bin)=$res") ;
    }
}


sub nb_orn_tests {
    my $sum = 0 ;
    for (my $j = 2 ; $j <= $max_n_tests ; $j++){
        $sum += 2 ** $j ;    
    }    
    return $sum * 2 ;
}


sub make_orn_test {
    my $n = shift ;
    my $random = shift ;

    my $bis = new BUS($n) ;
    my $wo = new WIRE() ;
    my $a = new ORn($n, $bis, $wo) ;

    my @ts = map { ($random ? int rand(2**$n) : $_) } (0 .. ((2**$n)-1)) ;
    foreach my $t (@ts){
        my $bin = sprintf("%0${n}b", $t) ;
        $bis->power($bin) ;
        my $res = ($t != 0) || 0 ;
        is($wo->power(), $res, "OR$n($bin)=$res") ;
    }
}
