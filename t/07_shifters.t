use strict ;
use Test::More ;
use ShiftL ;
use ShiftR ;
use Bus ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(shuffle) ;


plan(tests => nb_shifter_tests()) ;

# Basic test for MEMORY circuit.
my $sl = new SHIFTL() ;
my $bi = new BUS([$sl->is()]) ;
my $bo = new BUS([$sl->os()]) ;
new WIRE($sl->si(), $sl->so()) ;

make_shifterl_test(0) ;
make_shifterl_test(1) ;

my $sr = new SHIFTR() ;
$bi = new BUS([$sr->is()]) ;
$bo = new BUS([$sr->os()]) ;
new WIRE($sr->si(), $sr->so()) ;

make_shifterr_test(0) ;
make_shifterr_test(1) ;


sub nb_shifter_tests { 
    return 256*4 ;
}


sub make_shifterl_test {
    my $random = shift ;

    my @ts = tuples_with_repetition([0, 1], 8) ;
    @ts = shuffle @ts if $random ;
    foreach my $t (@ts){
        my $bin = join('', @{$t}) ;
        $bi->power($bin) ;

        my @res = @{$t} ;
        my $head = shift @res ;
        push @res, $head ;
        my $res = join('', @res) ;
        is($bo->power(), $res, "SHIFTL($bin)=$res") ;
    }
}


sub make_shifterr_test {
    my $random = shift ;

    my @ts = tuples_with_repetition([0, 1], 8) ;
    @ts = shuffle @ts if $random ;
    foreach my $t (@ts){
        my $bin = join('', @{$t}) ;
        $bi->power($bin) ;

        my @res = @{$t} ;
        my $head = pop @res ;
        unshift @res, $head ;
        my $res = join('', @res) ;
        is($bo->power(), $res, "SHIFTR($bin)=$res") ;
    }
}

