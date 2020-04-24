use strict ;
use Test::More ;
use Decoder ;
use Data::Dumper ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(shuffle) ;


my $max_decoder_tests = 4 ;
plan(tests => nb_decoder_tests() + 7) ;


map { make_decoder_test($_, 0) } (2..$max_decoder_tests) ;
map { make_decoder_test($_, 1) } (2..$max_decoder_tests) ;


eval { my $D = new DECODER(0) ; } ;
like($@, qr/Invalid DECODER number of inputs/, "Invalid DECODER number of inputs <2") ;
my $D = new DECODER(2) ;
is($D->i(0), [$D->is()]->[0], "i(n) works") ;
is($D->o(0), [$D->os()]->[0], "o(n) works") ;
eval { $D->i(-1) ; } ;
like($@, qr/Invalid input index/, "Invalid input index <0") ;
eval { $D->i(5) ; } ;
like($@, qr/Invalid input index/, "Invalid input index >2") ;
eval { $D->o(-1) ; } ;
like($@, qr/Invalid output index/, "Invalid output index <0") ;
eval { $D->o(5) ; } ;
like($@, qr/Invalid output index/, "Invalid output index >2") ;


sub nb_decoder_tests {
    my $sum = 0 ;
    for (my $j = 2 ; $j <= $max_decoder_tests ; $j++){
        $sum += 2 ** $j ;    
    }    
    return $sum * 2 ;
}


sub make_decoder_test {
    my $n = shift ;
    my $random = shift ;

    my $D = new DECODER($n, $n . 'x' . 2**$n) ;
    my @wis = WIRE->new_wires($D->is()) ;
    my @wos = WIRE->new_wires($D->os()) ;

    my @ts = tuples_with_repetition([0, 1], $n) ;
    @ts = shuffle @ts if $random ;
    foreach my $t (@ts){
        WIRE->power_wires(@wis, $t) ;
        # Binary string representing inputs, i.e. ("011") ;
        my $bin = join('', @{$t}) ; 

        my @res = ('0') x 2**$n ;
        # Converting this binary string to decimal number will give us the bit to turn on.
        $res[oct("0b" . $bin)] = 1 ;
        my $res = join('', @res) ;
        is(WIRE->power_wires(@wos), $res, "DECODER$n(" . join(", ", @{$t}) . ")=$res") ;
    }
}