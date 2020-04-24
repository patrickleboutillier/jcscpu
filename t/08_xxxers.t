use strict ;
use Test::More ;
use NOTTER ;
use ANDDER ;
use ORER ;
use XORER ;
use ADDER ;
use ZERO ;
use Bus ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(shuffle) ;

my $make_xxer_size = 64 ;
# my $make_xxer_size = 8 ;
plan(tests => nb_xxxer_tests()) ;


# Basic test for XXXer circuits.
my $n = new NOTTER() ;
my $ba = new BUS([$n->as()]) ;
my $bb = new BUS([$n->bs()]) ;

make_notter_test(0) ;
make_notter_test(1) ;


my $z = new ZERO() ;
my $bi = new BUS([$z->is()]) ;
my $wz = new WIRE($z->z()) ;

make_zero_test(0) ;
make_zero_test(1) ;


my $a = new ANDDER() ;
$ba = new BUS([$a->as()]) ;
$bb = new BUS([$a->bs()]) ;
my $bc = new BUS([$a->cs()]) ;

make_andder_test(1) ;


my $o = new ORER() ;
$ba = new BUS([$o->as()]) ;
$bb = new BUS([$o->bs()]) ;
$bc = new BUS([$o->cs()]) ;

make_orer_test(1) ;


my $x = new XORER() ;
$ba = new BUS([$x->as()]) ;
$bb = new BUS([$x->bs()]) ;
$bc = new BUS([$x->cs()]) ;

make_xorer_test(1) ;


$a = new ADDER() ;
$ba = new BUS([$a->as()]) ;
$bb = new BUS([$a->bs()]) ;
my $bsum = new BUS([$a->sums()]) ;
my $wci = new WIRE($a->carry_in()) ;
my $wco = new WIRE($a->carry_out()) ;

make_adder_test(1) ;


sub nb_xxxer_tests { 
    return 256*4 + ($make_xxer_size**2)*5  ;
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
    my @ts1 = @ts[0..($make_xxer_size-1)] ;
    my @ts2 = @ts[$make_xxer_size..($make_xxer_size*2-1)] ;

    foreach my $t1 (@ts1){
        foreach my $t2 (@ts2){
            my $bin1 = join('', @{$t1}) ;
            my $bin2 = join('', @{$t2}) ;
            $ba->power($bin1) ;
            $bb->power($bin2) ;

            my @res = () ;
            for (my $j = 0 ; $j < 8 ; $j++){
                push @res, map { ($_ ? 1 : 0) } ($t1->[$j] and $t2->[$j]) ;
            }
            my $res = join('', @res) ;
            is($bc->power(), $res, "ANDDER($bin1,$bin2)=$res") ;
        }
    }
}

sub make_orer_test {
    my $random = shift ;

    my @ts = tuples_with_repetition([0, 1], 8) ;
    @ts = shuffle @ts if $random ;
    my @ts1 = @ts[0..($make_xxer_size-1)] ;
    my @ts2 = @ts[$make_xxer_size..($make_xxer_size*2-1)] ;

    foreach my $t1 (@ts1){
        foreach my $t2 (@ts2){
            my $bin1 = join('', @{$t1}) ;
            my $bin2 = join('', @{$t2}) ;
            $ba->power($bin1) ;
            $bb->power($bin2) ;

            my @res = () ;
            for (my $j = 0 ; $j < 8 ; $j++){
                push @res, map { ($_ ? 1 : 0) } ($t1->[$j] or $t2->[$j]) ;
            }
            my $res = join('', @res) ;
            is($bc->power(), $res, "ORER($bin1,$bin2)=$res") ;
        }
    }
}

sub make_xorer_test {
    my $random = shift ;

    my @ts = tuples_with_repetition([0, 1], 8) ;
    @ts = shuffle @ts if $random ;
    my @ts1 = @ts[0..($make_xxer_size-1)] ;
    my @ts2 = @ts[$make_xxer_size..($make_xxer_size*2-1)] ;

    foreach my $t1 (@ts1){
        foreach my $t2 (@ts2){
            my $bin1 = join('', @{$t1}) ;
            my $bin2 = join('', @{$t2}) ;
            $ba->power($bin1) ;
            $bb->power($bin2) ;

            my @res = () ;
            for (my $j = 0 ; $j < 8 ; $j++){
                push @res, map { ($_ ? 1 : 0) } ($t1->[$j] xor $t2->[$j]) ;
            }
            my $res = join('', @res) ;
            is($bc->power(), $res, "XORER($bin1,$bin2)=$res") ;
        }
    }
}

sub make_adder_test {
    my $random = shift ;

    my @ts = tuples_with_repetition([0, 1], 8) ;
    @ts = shuffle @ts if $random ;
    my @ts1 = @ts[0..($make_xxer_size-1)] ;
    my @ts2 = @ts[$make_xxer_size..($make_xxer_size*2-1)] ;
    foreach my $t1 (@ts1){
        foreach my $t2 (@ts2){
            my $bin1 = join('', @{$t1}) ;
            my $bin2 = join('', @{$t2}) ;
            my $ci = int rand(2) ;
            $ba->power($bin1) ;
            $bb->power($bin2) ;
            $wci->power($ci) ;

            my $resd = oct("0b" . $bin1) + oct("0b" . $bin2) + $ci ;
            my $res = sprintf("%08b", $resd) ;
            my $co = '0' ;
            if ($resd > 255){
                # Remove first char of $res and place it in $co
                $res =~ s/^(.)// ;
                $co = $1 ;
            }
            $wco->power($co) ;
            is($bsum->power(), $res, "ADDER($bin1,$bin2,$ci)=($co,$res)") ;
            is($wco->power(), $co, "ADDER($bin1,$bin2,$ci)=($co,$res) (carry out)") ;
        }
    }
}

sub make_zero_test {
    my $random = shift ;

    my @ts = tuples_with_repetition([0, 1], 8) ;
    @ts = shuffle @ts if $random ;
    foreach my $t (@ts){
        my $bin = join('', @{$t}) ;
        $bi->power($bin) ;

        my @res = map { ($_ ? 1 : 0) } map {! $_ } @{$t} ;
        my $res = ($bin eq "00000000" ? 1 : 0) ;
        is($wz->power(), $res, "ZERO($bin)=$res") ;
    }
}