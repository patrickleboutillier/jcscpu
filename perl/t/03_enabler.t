use strict ;
use Test::More ;
use Enabler ;

plan(tests => 7 + 512) ;

# ENABLER
my $bis = new BUS() ;
my $we = new WIRE() ;
my $bos = new BUS() ;
my $E = new ENABLER($bis, $we, $bos) ;
$E->show() ;

$bis->wire(0)->power(1) ;
is($bos->power(), "00000000", "B(i:10000000,e:0)=o:00000000, e=off, no output") ;
$bis->wire(4)->power(1) ;
is($bos->power(), "00000000", "B(i:10001000,e:0)=o:00000000, e=off, no output") ;
$we->power(1) ;
is($bos->power(), "10001000", "B(i:10001000,e:1)=o:10001000, e=on, i goes through") ;
$bis->wire(4)->power(0) ;
is($bos->power(), "10000000", "B(i:10000000,e:1)=o:10000000, e=on, i goes through") ;
$bis->wire(0)->power(0) ;
is($bos->power(), "00000000", "B(i:00000000,e:1)=o:00000000, e=on, i goes through") ;
$bis->wire(7)->power(1) ;
is($bos->power(), "00000001", "B(i:00000001,e:1)=o:00000001, e=on, i goes through") ;
$we->power(0) ;
is($bos->power(), "00000000", "B(i:00000001,e:0)=o:00000000, e=off, no output") ;

make_enabler_test(0) ;
make_enabler_test(1) ;

sub make_enabler_test {
    my $random = shift ;

    my @ts = map { ($random ? int rand(256) : $_) } (0 .. 255) ;
    foreach my $t (@ts){
        my $bin = sprintf("%08b", $t) ;
        $we->power(0) ; 
        $bis->power($bin) ;
        $we->power(1) ;
        is($bos->power(), $bin, "ENABLER($bin, 1)=$bin") ;
    }
}