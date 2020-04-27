use strict ;
use Test::More ;
use Decoder ;
use Data::Dumper ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(shuffle) ;


my $max_decoder_tests = 4 ;
plan(tests => nb_decoder_tests() + 9) ;


map { make_decoder_test($_, 0) } (2..$max_decoder_tests) ;
map { make_decoder_test($_, 1) } (2..$max_decoder_tests) ;


eval { my $D = new DECODER(0, new BUS(0), new BUS(0)) } ;
like($@, qr/Invalid DECODER number of inputs/, "Invalid DECODER number of inputs <2") ;
eval { my $D = new DECODER(2, new BUS(1), new BUS(4)) } ;
like($@, qr/Invalid number of wires in DECODER input bus/, "Invalid DECODER number of wires on input bus") ;
eval { my $D = new DECODER(2, new BUS(2), new BUS(3)) } ;
like($@, qr/Invalid number of wires in DECODER output bus/, "Invalid DECODER number of wires on output bus") ;
my $D = new DECODER(2, new BUS(2), new BUS(4)) ;
is($D->i(0), $D->is()->wire(0), "i(n) works") ;
is($D->o(0), $D->os()->wire(0), "o(n) works") ;
eval { $D->i(-1) } ;
like($@, qr/Invalid input index/, "Invalid input index <0") ;
eval { $D->i(5) } ;
like($@, qr/Invalid input index/, "Invalid input index >2") ;
eval { $D->o(-1) } ;
like($@, qr/Invalid output index/, "Invalid output index <0") ;
eval { $D->o(5) } ;
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

    my $bis = new BUS($n) ;
    my $bos = new BUS(2**$n) ;
    my $D = new DECODER($n, $bis, $bos, $n . 'x' . 2**$n) ;

    my @ts = tuples_with_repetition([0, 1], $n) ;
    @ts = shuffle @ts if $random ;
    foreach my $t (@ts){
        my $bin = join('', @{$t}) ; 
        $bis->power($bin) ;

        my @res = ('0') x 2**$n ;
        # Converting this binary string to decimal number will give us the bit to turn on.
        $res[oct("0b" . $bin)] = 1 ;
        my $res = join('', @res) ;
        is($bos->power($res), $res, "DECODER$n($bin)=$res") ;
    }
}