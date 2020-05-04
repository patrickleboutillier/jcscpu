# Some function to facilitate ALU testing.


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


sub valu {
    my $tc = shift ;
    my $no_flags = shift ;

    my %res = %{$tc} ;

    if ($no_flags){
        delete $res{ci} ;       
    }

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
        $res{eqo} = ($res{a} == $res{b}) || 0 ;
        $res{alo} = ($res{a} > $res{b}) || 0;
    }

    if ($no_flags){
        delete $res{co} ;   
        delete $res{z} ;
        delete $res{eqo} ;
        delete $res{alo} ;     
    }

    return \%res ;
}


1 ;