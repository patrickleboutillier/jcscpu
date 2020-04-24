use strict ;
use Test::More ;
use NOTTER ;
use ANDDER ;
use ORER ;
use XORER ;
use Bus ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(shuffle) ;


plan(tests => nb_xxxer_tests()) ;


# Basic test for XXXer circuits.
my $n = new NOTTER() ;
my $ba = new BUS([$n->as()]) ;
my $bb = new BUS([$n->bs()]) ;

make_notter_test(0) ;
make_notter_test(1) ;


my $n = new ANDDER() ;
$ba = new BUS([$n->as()]) ;
$bb = new BUS([$n->bs()]) ;
my $bc = new BUS([$n->cs()]) ;

make_andder_test(1) ;

sub nb_xxxer_tests { 
    return 256*2 + 16384 ;
}


sub make_notter_test {
    my $random = shift ;

    my @ts = tuples_with_repetition([0, 1], 8) ;
    @ts = shuffle @ts if $random ;
    foreach my $t (@ts){
        my $bin = join('', @{$t}) ;
        $ba->power($bin) ;

        my @res = map { ($_ ? 1 : 0) } map {! $_ } @{$t} ;
        my $res = join('', @res) ;
        is($bb->power(), $res, "NOTTER($bin)=$res") ;
    }
}

sub make_andder_test {
    my $random = shift ;

    my @ts = tuples_with_repetition([0, 1], 8) ;
    @ts = shuffle @ts if $random ;
    my @ts1 = @ts[0..127] ;
    my @ts2 = @ts[128..255] ;

    foreach my $t1 (@ts1){
        foreach my $t2 (@ts2){
            my $bin1 = join('', @{$t1}) ;
            my $bin2 = join('', @{$t2}) ;
            $ba->power($bin1) ;
            $bb->power($bin2) ;

            my @res = () ;
            for (my $j = 0 ; $j < 8 ; $j++){
                push @res, ($t1->[$j] && $t2->[$j]) ;
            }
            my $res = join('', @res) ;
            is($bc->power(), $res, "ANDDER($bin1,$bin2)=$res") ;
        }
    }
}

