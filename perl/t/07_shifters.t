use strict ;
use Test::More ;
use ShiftL ;
use ShiftR ;


plan(tests => nb_shifter_tests()) ;

# Basic test for MEMORY circuit.
my $wrap = new WIRE() ;
my $bis = new BUS() ;
my $bos = new BUS() ;
my $sl = new SHIFTL($bis, $wrap, $bos, $wrap) ;
$sl->show() ;

make_shifterl_test(0) ;
make_shifterl_test(1) ;

$wrap = new WIRE() ;
$bis = new BUS() ;
$bos = new BUS() ;
my $sr = new SHIFTR($bis, $wrap, $bos, $wrap) ;
$sr->show() ;

make_shifterr_test(0) ;
make_shifterr_test(1) ;


sub nb_shifter_tests { 
    return 256*4 ;
}


sub make_shifterl_test {
    my $random = shift ;

    my @ts = map { ($random ? int rand(256) : $_) } (0..255) ;
    foreach my $t (@ts){
        my $bin = sprintf("%08b", $t) ;
        $bis->power($bin) ;

        my @res = split(//, $bin) ;
        my $head = shift @res ;
        push @res, $head ;
        my $res = join('', @res) ;
        is($bos->power(), $res, "SHIFTL($bin)=$res") ;
    }
}


sub make_shifterr_test {
    my $random = shift ;
 
    my @ts = map { ($random ? int rand(256) : $_) } (0..255) ;
    foreach my $t (@ts){
        my $bin = sprintf("%08b", $t) ;
        $bis->power($bin) ;

        my @res = split(//, $bin) ;
        my $head = pop @res ;
        unshift @res, $head ;
        my $res = join('', @res) ;
        is($bos->power(), $res, "SHIFTR($bin)=$res") ;
    }
}

