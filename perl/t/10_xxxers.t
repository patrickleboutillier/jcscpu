use strict ;
use Test::More ;
use NOTTER ;
use ANDDER ;
use ORER ;
use XORER ;
use ADDER ;
use ZERO ;
use BUS1 ;


my $make_xxer_size = 64 ;
$make_xxer_size = 8 ;
plan(tests => nb_xxxer_tests()) ;


# Basic test for XXXer circuits.
my $bas = new BUS() ;
my $bbs = new BUS() ;
my $n = new NOTTER($bas, $bbs) ;
$n->show() ;

make_notter_test(0) ;
make_notter_test(1) ;


my $bis = new BUS() ;
my $wz = new WIRE() ; 
my $z = new ZERO($bis, $wz) ;
$z->show() ;

make_zero_test(0) ;
make_zero_test(1) ;


$bas = new BUS() ;
$bbs = new BUS() ;
my $bcs = new BUS() ;
my $a = new ANDDER($bas, $bbs, $bcs) ;
$a->show() ;

make_andder_test(1) ;


$bas = new BUS() ;
$bbs = new BUS() ;
$bcs = new BUS() ;
my $o = new ORER($bas, $bbs, $bcs) ;
$o->show() ;

make_orer_test(1) ;


$bas = new BUS() ;
$bbs = new BUS() ;
$bcs = new BUS() ;
my $weqo = new WIRE() ;
my $walo = new WIRE() ;
my $x = new XORER($bas, $bbs, $bcs, $weqo, $walo) ;
$x->show() ;
make_xorer_test(1) ;


$bas = new BUS() ;
$bbs = new BUS() ;
my $wci = new WIRE() ;
my $bsums = new BUS() ;
my $wco = new WIRE() ;
$a = new ADDER($bas, $bbs, $wci, $bsums, $wco) ;
$a->show() ;
make_adder_test(1) ;


$bis = new BUS() ;
my $bos = new BUS() ;
my $wbus1 = new WIRE() ;
$b = new BUS1($bis, $wbus1, $bos) ;
$b->show() ;
make_bus1_test(1) ;


sub nb_xxxer_tests { 
    return 256*5 + ($make_xxer_size*($make_xxer_size+1))*5  ;
}


sub make_notter_test {
    my $random = shift ;

    my @ts = map { ($random ? int rand(256) : $_) } (0..255) ;
    foreach my $t (@ts){
        my $bin = sprintf("%08b", $t) ;
        $bas->power($bin) ;

        my @res = map { ($_ ? 1 : 0) } map {! $_ } split(//, $bin) ;
        my $res = join('', @res) ;
        is($bbs->power(), $res, "NOTTER($bin)=$res") ;
    }
}

sub make_andder_test {
    my $random = shift ;

    my @ts = map { ($random ? int rand(256) : $_) } (0..255) ;
    my @ts1 = @ts[0..($make_xxer_size-1)] ;
    my @ts2 = @ts[($make_xxer_size-1)..($make_xxer_size*2-1)] ;

    foreach my $t1 (@ts1){
        foreach my $t2 (@ts2){
            my $bin1 = sprintf("%08b", $t1) ;
            my $bin2 = sprintf("%08b", $t2) ;
            $bas->power($bin1) ;
            $bbs->power($bin2) ;

            my @res = () ;
            my @t1 = split(//, $bin1) ;
            my @t2 = split(//, $bin2) ;
            for (my $j = 0 ; $j < 8 ; $j++){
                push @res, map { ($_ ? 1 : 0) } ($t1[$j] and $t2[$j]) ;
            }
            my $res = join('', @res) ;
            is($bcs->power(), $res, "ANDDER($bin1,$bin2)=$res") ;
        }
    }
}

sub make_orer_test {
    my $random = shift ;

    my @ts = map { ($random ? int rand(256) : $_) } (0..255) ;
    my @ts1 = @ts[0..($make_xxer_size-1)] ;
    my @ts2 = @ts[($make_xxer_size-1)..($make_xxer_size*2-1)] ;

    foreach my $t1 (@ts1){
        foreach my $t2 (@ts2){
            my $bin1 = sprintf("%08b", $t1) ;
            my $bin2 = sprintf("%08b", $t2) ;
            $bas->power($bin1) ;
            $bbs->power($bin2) ;

            my @res = () ;
            my @t1 = split(//, $bin1) ;
            my @t2 = split(//, $bin2) ;
            for (my $j = 0 ; $j < 8 ; $j++){
                push @res, map { ($_ ? 1 : 0) } ($t1[$j] or $t2[$j]) ;
            }
            my $res = join('', @res) ;
            is($bcs->power(), $res, "ORER($bin1,$bin2)=$res") ;
        }
    }
}

sub make_xorer_test {
    my $random = shift ;

    my @ts = map { ($random ? int rand(256) : $_) } (0..255) ;
    my @ts1 = @ts[0..($make_xxer_size-1)] ;
    my @ts2 = @ts[($make_xxer_size-1)..($make_xxer_size*2-1)] ;

    foreach my $t1 (@ts1){
        foreach my $t2 (@ts2){
            my $bin1 = sprintf("%08b", $t1) ;
            my $bin2 = sprintf("%08b", $t2) ;
            $bas->power($bin1) ;
            $bbs->power($bin2) ;

            my @res = () ;
            my @t1 = split(//, $bin1) ;
            my @t2 = split(//, $bin2) ;
            for (my $j = 0 ; $j < 8 ; $j++){
                push @res, map { ($_ ? 1 : 0) } ($t1[$j] xor $t2[$j]) ;
            }
            my $res = join('', @res) ;

            # eqo and alo
            my $alo = ($bin1 gt $bin2) || 0 ;
            my $eqo = ($bin1 eq $bin2) || 0 ;

            is_deeply([$bcs->power(),$weqo->power(),$walo->power()], [$res,$eqo,$alo], "XORER($bin1,$bin2)=($res,eqo:$eqo,alo:$alo)") or exit ;
        }
    }
}

sub make_adder_test {
    my $random = shift ;

    my @ts = map { ($random ? int rand(256) : $_) } (0..255) ;
    my @ts1 = @ts[0..($make_xxer_size-1)] ;
    my @ts2 = @ts[($make_xxer_size-1)..($make_xxer_size*2-1)] ;
    foreach my $t1 (@ts1){
        foreach my $t2 (@ts2){
            my $bin1 = sprintf("%08b", $t1) ;
            my $bin2 = sprintf("%08b", $t2) ;
            my $ci = int rand(2) ;
            $bas->power($bin1) ;
            $bbs->power($bin2) ;
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
            is($bsums->power(), $res, "ADDER($bin1,$bin2,$ci)=($co,$res)") ;
            is($wco->power(), $co, "ADDER($bin1,$bin2,$ci)=($co,$res) (carry out)") ;
        }
    }
}

sub make_zero_test {
    my $random = shift ;

    my @ts = map { ($random ? int rand(256) : $_) } (0..255) ;
    foreach my $t (@ts){
        my $bin = sprintf("%08b", $t) ;
        $bis->power($bin) ;

        my @res = map { ($_ ? 1 : 0) } map {! $_ } split(//, $bin) ;
        my $res = ($bin eq "00000000" ? 1 : 0) ;
        is($wz->power(), $res, "ZERO($bin)=$res") ;
    }
}


sub make_bus1_test {
    my $random = shift ;

    my @ts = map { ($random ? int rand(256) : $_) } (0..255) ;
    foreach my $t (@ts){
        my $bin = sprintf("%08b", $t) ;
        $bis->power($bin) ;
        my $bus1 = int rand(2) ;
        $wbus1->power($bus1) ;

        my @res = map { ($_ ? 1 : 0) } map {! $_ } split(//, $bin) ;
        my $res = ($bus1 ? "00000001" : $bin) ;
        is($bos->power(), $res, "BUS1($bin,$bus1)=$res") ;
    }
}