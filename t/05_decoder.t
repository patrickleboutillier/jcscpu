use strict ;
use Test::More ;
use Decoder ;
use Data::Dumper ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;


my $max_decoder_tests = 4 ;
plan(tests => nb_decoder_tests()) ;


sub nb_decoder_tests {
    my $sum = 0 ;
    for (my $j = 2 ; $j <= $max_decoder_tests ; $j++){
        $sum += 2 ** $j ;    
    }    
    return $sum ;
}


sub make_decoder_test {
    my $n = shift ;

    my $D = new DECODER($n, $n . 'x' . 2**$n) ;
    my @wis = WIRE->news($D->is()) ;
    my @wos = WIRE->news($D->os()) ;

    my @ts = tuples_with_repetition([0, 1], $n) ;
    foreach my $t (@ts){
        for (my $j = 0 ; $j < $n ; $j++){
            $wis[$j]->power($t->[$j]) ;
        }
        # Binary string representing inputs, i.e. ("011") ;
        my $bin = join('', @{$t}) ; 

        my @res = ('0') x 2**$n ;
        # Converting this binary string to decimal number will give us the bit to turn on.
        $res[oct("0b" . $bin)] = 1 ;
        my $res = join('', @res) ;
        is(WIRE->show(@wos), $res, "DECODER$n(" . join(", ", @{$t}) . ")=$res") ;
    }
}

map { make_decoder_test($_) } (2..$max_decoder_tests) ;