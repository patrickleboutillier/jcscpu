use strict ;
use Test::More ;
use Data::Dumper ;
use ALU ;


my $nb_test_per_op = 256 ;
my @ops = (0,1,2,3,4,5,6,7) ;
plan(tests => $nb_test_per_op*(scalar(@ops)+1)) ;


my $bas = new BUS() ; 
my $bbs = new BUS() ;
my $wci = new WIRE() ;
my $bops = new BUS(3) ;
my $wope = new WIRE() ;
my $bcs = new BUS() ; 
my $wco = new WIRE() ;
my $weqo = new WIRE() ;
my $walo = new WIRE() ;
my $wz = new WIRE() ;
my $ALU = new ALU($bas, $bbs, $wci, $bops, $wope, $bcs, $wco, $weqo, $walo, $wz, "ALU") ;
$ALU->show() ;
$ALU->show(0) ;

foreach my $op (@ops){
    for (my $j = 0 ; $j < $nb_test_per_op ; $j++){
        do_test_case($op) ;
    }
}

# Random ops
@ops = map { int rand(8) } (0 .. ($nb_test_per_op-1)) ;
foreach my $op (@ops){
    do_test_case($op) ;
}


sub do_test_case {
    my $op = shift ;
    
    my $tc = gen_test_case() ;
    $tc->{op} = $op ;

    my $res = alu($tc) ; 
    my $vres = valu($tc) ;

    my $desc = Dumper($tc) ;
    $desc =~ s/\n\s*//gs ;
    is_deeply($res, $vres, $desc) ;
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
    # warn $ALU->show($res{op}) ;

    $bops->power(sprintf("%03b", $res{op})) ;
    $wope->power(1) ;
    # warn $ALU->show($res{op}) ;

    $res{out} = oct("0b" . $bcs->power()) if ($res{op} < 7) ;   
    $res{co} = $wco->power() if ($res{op} < 3) ;

    if (defined($res{out})){
        $res{binout} = sprintf("%08b", $res{out}) ; 
        $res{z} = $wz->power() ;
        $res{eqo} = $weqo->power() ;
        $res{alo} = $walo->power() ;
    }
    $wope->power(0) ;

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
    # AND
    elsif (($res{op}) == 4){
        my @bina = split(//, sprintf("%08b", $res{a})) ;
        my @binb = split(//, sprintf("%08b", $res{b})) ;
        my @res = () ;
        for (my $j = 0 ; $j < 8 ; $j++){
            push @res, ($bina[$j] && $binb[$j]) ;
        }
        $res{out} = oct("0b" . join('', map { ($_ ? 1 : 0) } @res)) ;
    }
    # OR
    elsif (($res{op}) == 5){
        my @bina = split(//, sprintf("%08b", $res{a})) ;
        my @binb = split(//, sprintf("%08b", $res{b})) ;
        my @res = () ;
        for (my $j = 0 ; $j < 8 ; $j++){
            push @res, ($bina[$j] || $binb[$j]) ;
        }
        $res{out} = oct("0b" . join('', map { ($_ ? 1 : 0) } @res)) ;
    }
    # XOR
    elsif (($res{op}) == 6){
        my @bina = split(//, sprintf("%08b", $res{a})) ;
        my @binb = split(//, sprintf("%08b", $res{b})) ;
        my @res = () ;
        for (my $j = 0 ; $j < 8 ; $j++){
            push @res, ($bina[$j] xor $binb[$j]) ;
        }
        $res{out} = oct("0b" . join('', map { ($_ ? 1 : 0) } @res)) ;
    }
    #CMP
    elsif (($res{op}) == 7){
        # Nothing...
    }

    if (defined($res{out})){
        $res{binout} = sprintf("%08b", $res{out}) ; 
        $res{z} = ($res{out} == 0 ? 1 : 0) ;
        $res{eqo} = $weqo->power() ;
        $res{alo} = $walo->power() ;
    }

    return \%res ;
}