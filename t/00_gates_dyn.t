use strict ;
use Test::More ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(all) ;
use Gates ;


my $max_andn_tests = 8 ;
plan(tests => 4 + nb_andn_tests()) ;


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

