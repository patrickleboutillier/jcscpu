use strict ;
use Test::More ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(all) ;
use Gates ;


my $max_andn_tests = 8 ;
plan(tests => (16 + nb_andn_tests())) ;


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


my $n = new NOT("TEST") ;
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


# ANDn
sub nb_andn_tests {
    my $sum = 0 ;
    for (my $j = 2 ; $j <= $max_andn_tests ; $j++){
        $sum += 2 ** $j ;    
    }    
    return $sum ;
}

sub make_andn_test {
    my $n = shift ;

    my $a = new ANDn($n) ;
    my @wis = map { new WIRE($_) } $a->is() ;
    my $wo = new WIRE($a->o()) ;

    my @ts = tuples_with_repetition([0, 1], $n) ;
    foreach my $t (@ts){
        WIRE->power_wires(@wis, $t) ;
        my $res = (all { $_ } @{$t}) || 0 ;
        is($wo->power(), $res, "AND$n(" . join(", ", @{$t}) . ")=$res") ;
    }
}

map { make_andn_test($_) } (2..$max_andn_tests) ;

eval {
    new ANDn(1) ;
} ;
like($@, qr/Invalid ANDn number of inputs/, "Invalid ANDn number of inputs <=2") ;
$a = new ANDn(4) ;
$a->i(0) ;
is($a->n(), 4, "Size of ANDn") ;
eval { $a->i(-1) ;} ;
like($@, qr/Invalid input index/, "Invalid input index <0") ;
eval { $a->i(6) ;} ;
like($@, qr/Invalid input index/, "Invalid input index >n") ;

