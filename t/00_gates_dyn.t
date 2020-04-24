use strict ;
use Test::More ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(all any shuffle) ;
use Gates ;


my $max_n_tests = 8 ;
plan(tests => 8 + nb_andn_tests() + nb_orn_tests()) ;


# ANDn
map { make_andn_test($_, 0) } (2..$max_n_tests) ;
map { make_andn_test($_, 1) } (2..$max_n_tests) ;

eval {
    new ANDn(1) ;
} ;
like($@, qr/Invalid ANDn number of inputs/, "Invalid ANDn number of inputs <=2") ;
my $a = new ANDn(4) ;
$a->i(0) ;
is($a->n(), 4, "Size of ANDn") ;
eval { $a->i(-1) ;} ;
like($@, qr/Invalid input index/, "Invalid input index <0") ;
eval { $a->i(6) ;} ;
like($@, qr/Invalid input index/, "Invalid input index >n") ;


# ORn
map { make_orn_test($_, 0) } (2..$max_n_tests) ;
map { make_orn_test($_, 1) } (2..$max_n_tests) ;

eval {
    new ORn(1) ;
} ;
like($@, qr/Invalid ORn number of inputs/, "Invalid ORn number of inputs <=2") ;
my $o = new ORn(4) ;
$o->i(0) ;
is($o->n(), 4, "Size of ORn") ;
eval { $o->i(-1) ;} ;
like($@, qr/Invalid input index/, "Invalid input index <0") ;
eval { $o->i(6) ;} ;
like($@, qr/Invalid input index/, "Invalid input index >n") ;


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

    my $a = new ANDn($n) ;
    my @wis = map { new WIRE($_) } $a->is() ;
    my $wo = new WIRE($a->o()) ;

    my @ts = tuples_with_repetition([0, 1], $n) ;
    @ts = shuffle @ts if $random ;
    foreach my $t (@ts){
        WIRE->power_wires(@wis, $t) ;
        my $res = (all { $_ } @{$t}) || 0 ;
        is($wo->power(), $res, "AND$n(" . join(", ", @{$t}) . ")=$res") ;
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

    my $a = new ORn($n) ;
    my @wis = map { new WIRE($_) } $a->is() ;
    my $wo = new WIRE($a->o()) ;

    my @ts = tuples_with_repetition([0, 1], $n) ;
    @ts = shuffle @ts if $random ;
    foreach my $t (@ts){
        WIRE->power_wires(@wis, $t) ;
        my $res = (any { $_ } @{$t}) || 0 ;
        is($wo->power(), $res, "OR$n(" . join(", ", @{$t}) . ")=$res") ;
    }
}

