use strict ;
use Test::More ;
use Data::Dumper ;
use ALU ;


my $nb_test_per_op = 1 ;
my @ops = (0,1,3,4) ;
plan(tests => $nb_test_per_op*scalar(@ops)) ;


my $bas = new BUS() ; 
my $bbs = new BUS() ;
my $wci = new WIRE() ;
my $bops = new BUS(3) ;
my $bcs = new BUS() ; 
my $wco = new WIRE() ;
my $weqo = new WIRE() ;
my $walo = new WIRE() ;
my $wz = new WIRE() ;
my $ALU = new ALU($bas, $bbs, $wci, $bops, $bcs, $wco, $weqo, $walo, $wz, "ALU") ;


foreach my $op (@ops){
    for (my $j = 0 ; $j < $nb_test_per_op ; $j++){
        my $tc = gen_test_case() ;
        $tc->{op} = $op ;

        my $res = alu($tc) ; 
        my $vres = valu($tc) ;

        my $desc = Dumper($tc) ;
        $desc =~ s/\n\s*//gs ;
        is_deeply($res, $vres, $desc) ;
    }
}


sub gen_test_case {
    my $ret = {
        a => int rand(256),
        b => int rand(256),
        ci => int rand(2),
    } ;
    $ret->{bina} = sprintf("%08b", $ret->{a}) ;
    $ret->{binb} = sprintf("%08b", $ret->{b}) ;

    return $ret ;
}


sub alu {
    my $tc = shift ;

    my %res = %{$tc} ;

    # Place values on bus
    $bas->power(sprintf("%08b", $res{a})) ;
    $bbs->power(sprintf("%08b", $res{b})) ;
    $wci->power($res{ci}) ;
    warn $ALU->show($res{op}) ;
    # $bops->power("000") ;
    $bops->power(sprintf("%03b", $res{op})) ;
    warn $ALU->show($res{op}) ;

    $res{out} = oct("0b" . $bcs->power()) if ($res{op} < 7) ;   
    $res{co} = $wco->power() if ($res{op} < 3) ;
    
    if (defined($res{out})){
        $res{binout} = sprintf("%08b", $res{out}) ; 
        $res{z} = $wz->power() ;
    }

    return \%res ;
}


sub valu {
    my $tc = shift ;

    my %res = %{$tc} ;

    # ADD
    if (($res{op}) == 0){
        my $out = $res{a} + $res{b} + $res{ci} ;
        my $co = 0 ;
        if ($out >= 256){
            $co = 1 ;
            $out -= 256 ;    
        }
        $res{out} = $out ; 
        $res{co} = $co ;
    }
    # SHR
    elsif (($res{op}) == 1){
        $res{out} = ($res{a} >> 1) + ($res{ci} * 128) ;
        $res{co} = $res{a} % 2 ;
    }
    # SHL
    elsif (($res{op}) == 2){
        my $out = ($res{a} << 1) + $res{ci} ;
        my $co = 0 ;
        if ($out >= 256){
            $out -= 256 ;
            $co = 1 ;
        }
        $res{out} = $out ;
        $res{co} = $co ;
    }
    # NOT
    elsif (($res{op}) == 3){
        my @bina = split(//, sprintf("%08b", $res{a})) ;
        my @res = map { ($_ ? 0 : 1) } @bina ;
        $res{out} = oct("0b" . join('', map { ($_ ? 1 : 0) } @res)) ;    
    }
    elsif (($res{op}) == 4){
        my @bina = split(//, sprintf("%08b", $res{a})) ;
        my @binb = split(//, sprintf("%08b", $res{b})) ;
        my @res = () ;
        for (my $j = 0 ; $j < 8 ; $j++){
            push @res, ($bina[$j] && $binb[$j]) ;
        }
        $res{out} = oct("0b" . join('', map { ($_ ? 1 : 0) } @res)) ;
    }
    elsif (($res{op}) == 5){
    }
    elsif (($res{op}) == 6){
    }
    elsif (($res{op}) == 7){
    }

    if (defined($res{out})){
        $res{binout} = sprintf("%08b", $res{out}) ; 
        $res{z} = ($res{out} == 0 ? 1 : 0) ;
    }
    # warn "bina=$res{bina} $res{a}\nbinb=$res{binb} $res{b}\nbino=$res{binout} $res{out}" ;

    return \%res ;
}