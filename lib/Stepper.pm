package STEPPER ;

use strict ;
use Memory ;


sub new {
    my $class = shift ;
    my $wclk = shift ;
    my $wrst = shift ;
    my $bos = shift ;  # 7 wire bus
    my $name = shift ;

    my $wnrm1 = new WIRE() ;
    my $nr = new NOT($wrst, $wnrm1) ;
    my $wnco1 = new WIRE() ;
    my $nc = new NOT($wclk, $wnco1) ;
    my $wmsn = new WIRE() ;
    my $o1 = new OR($wrst, $wnco1, $wmsn) ;
    my $wmsnn = new WIRE() ;
    my $o2 = new OR($wrst, $wclk, $wmsnn) ;

    # M1
    my $wn12b = new WIRE() ;
    my $wn12a = new WIRE() ;
    my $s1 = new OR($wrst, $wn12b, $bos->wire(0)) ;
    my $wm112 = new WIRE() ;
    my $m1 = new MEMORY($wnrm1, $wmsn, $wm112, " 1") ;

    # M12
    my $wn12a = new WIRE() ;
    my $n12 = new NOT($wn12a, $wn12b) ;
    my $m12 = new MEMORY($wm112, $wmsnn, $wn12a, "12") ;

    # M2
    my $wn23b = new WIRE() ;
    my $s2 = new AND($wn12a, $wn23b, $bos->wire(1)) ;
    my $wm223 = new WIRE() ;
    my $m2 = new MEMORY($wn12a, $wmsn, $wm223, " 2") ;

    # M23
    my $wn23a = new WIRE() ;
    my $n23 = new NOT($wn23a, $wn23b) ;
    my $m23 = new MEMORY($wm223, $wmsnn, $wn23a, "23") ;

    # M3
    my $wn34b = new WIRE() ;
    my $s3 = new AND($wn23a, $wn34b, $bos->wire(2)) ;
    my $wm334 = new WIRE() ;
    my $m3 = new MEMORY($wn23a, $wmsn, $wm334, " 3") ;

    # M34
    my $wn34a = new WIRE() ;
    my $n34 = new NOT($wn34a, $wn34b) ;
    my $m34 = new MEMORY($wm334, $wmsnn, $wn34a, "34") ;

    # M4
    my $wn45b = new WIRE() ;
    my $s4 = new AND($wn34a, $wn45b, $bos->wire(3)) ;
    my $wm445 = new WIRE() ;
    my $m4 = new MEMORY($wn34a, $wmsn, $wm445, " 4") ;

    # M45
    my $wn45a = new WIRE() ;
    my $n45 = new NOT($wn45a, $wn45b) ;
    my $m45 = new MEMORY($wm445, $wmsnn, $wn45a, "45") ;

    # M5
    my $wn56b = new WIRE() ;
    my $s5 = new AND($wn45a, $wn56b, $bos->wire(4)) ;
    my $wm556 = new WIRE() ;
    my $m5 = new MEMORY($wn45a, $wmsn, $wm556, " 5") ;

    # M56
    my $wn56a = new WIRE() ;
    my $n56 = new NOT($wn56a, $wn56b) ;
    my $m56 = new MEMORY($wm556, $wmsnn, $wn56a, "56") ;

    # M6
    my $wn67b = new WIRE() ;
    my $s6 = new AND($wn56a, $wn67b, $bos->wire(5)) ;
    my $wm667 = new WIRE() ;
    my $m6 = new MEMORY($wn56a, $wmsn, $wm667, " 6") ;

    # M67
    my $n67 = new NOT($bos->wire(6), $wn67b) ;
    my $m67 = new MEMORY($wm667, $wmsnn, $bos->wire(6), "67") ;

    my $this = {
        clk => $wclk,
        rst => $wrst,
        os => $bos,
        Ss => [$s1, $s2, $s3, $s4, $s5, $s6, $bos->wire(6)],
        Ms => [$m1, $m12, $m2, $m23, $m3, $m34, $m4, $m45, $m5, $m56, $m6, $m67],
        name => $name
    } ;
    bless $this, $class ;

    $wclk->prehook(sub {
        my $v = shift ;
        $wmsn->power(! $v, 1) ;
        $wmsnn->power($v, 1) ;
    }) ;
    
    $wrst->prehook(sub {
        my $v = shift ;
        if ($v){
            $wmsn->power($v, 1) ;
            $wmsnn->power($v, 1) ;
        }
        else {
            $wmsn->power(! $wclk->power(), 1) ;
            $wmsnn->power($wclk->power(), 1) ;    
        }
    }) ;


    return $this ;
}


sub rst {
    my $this = shift ;

    return $this->{rst} ;
}


sub show {
    my $this = shift ;

    my $clk = $this->{clk}->power() ;
    my $rst = $this->{rst}->power() ;
    my $steps = $this->{os}->power() ;
    my @Ss = @{$this->{Ss}} ;
    my @Ms = @{$this->{Ms}} ;

    my $str = "STEPPER($this->{name}): rst:$rst, clk:$clk, steps:$steps\n  " ;
    foreach my $S (@Ss){
        $str .= "  " . $S->show() . "                " ;
    }
    $str .= "\n  " ;
    foreach my $M (@Ms){
        $str .= $M->show() . "  " ;
    }
    $str .= "\n" ;

    return $str ;
}


return 1 ;