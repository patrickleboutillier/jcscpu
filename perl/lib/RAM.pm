package RAM ;

use strict ;
use Register ;
use Decoder ;


sub new {
    my $class = shift ;
    my $ba = shift ;
    my $wsa = shift ;
    my $bio = shift ;
    my $ws = shift ;
    my $we = shift ;
    my $name = shift ;

    # Build the RAM circuit 
    my $on = new WIRE(1, 1) ;
    my $busd = new BUS() ;
    my $MAR = new REGISTER($ba, $wsa, $on, $busd, "MAR") ;

    my $wxs = new BUS(16) ;
    my $wys = new BUS(16) ;
    my @maris = $MAR->os() ;
    my $TD = new DECODER(4, BUS->wrap(($busd->wires())[0..3]), $wxs, "4x16") ;
    my $LD = new DECODER(4, BUS->wrap(($busd->wires())[4..7]), $wys, "4x16") ;
    
    # Now we create the circuit
    my %GRID = () ;
    for (my $x = 0 ; $x < 16 ; $x++){
        for (my $y = 0 ; $y < 16 ; $y++){
            # Create the subcircuit to be used at each location
            my $wxo = new WIRE() ;
            my $wso = new WIRE() ;
            my $weo = new WIRE() ;
            new AND($wxs->wire($x), $wys->wire($y), $wxo) ;
            new AND($wxo, $ws, $wso) ;
            new AND($wxo, $we, $weo) ;
            my $label = sprintf("%04b%04b", $x, $y) ;
            $GRID{$label} = new REGISTER($bio, $wso, $weo, $bio, "ADDR($label)") ;
        }
    }
    
    my $this = {
        as => $ba,
        sa => $wsa,
        e => $we,
        s => $ws,
        ios => $bio,
        name => $name,
        MAR => $MAR,
        GRID => \%GRID,
    } ;
    bless $this, $class ;

    return $this ;
}


sub as {
    my $this = shift ;
    return $this->{as} ;
}


sub sa {
    my $this = shift ;
    return $this->{sa} ;
}


sub ios {
    my $this = shift ;
    return $this->{ios} ;
}


sub s {
    my $this = shift ;
    return $this->{s} ;
}


sub e {
    my $this = shift ;
    return $this->{e} ;
}


sub r {
    my $this = shift ;
    my $addr = shift ;

    return $this->{GRID}->{$addr} ;
}


sub MAR {
    my $this = shift ;
    
    return $this->{MAR} ;
}


sub show {
    my $this = shift ;
    my @addrs = @_ ;

    my $mar = $this->{MAR}->show() ;
    my $bio = $this->ios()->power() ;
    my $e = $this->e()->power() ;
    my $s = $this->s()->power() ;
    my $str = "RAM:\n  $mar  " . $this->{GRID}->{$this->{MAR}->os()->power()}->show() . "\n" ;
    foreach my $a (@addrs){
        $str .= "  " . $this->{GRID}->{$a}->show() ;
    }
    # $str .= "\n  e:$e, s:$s, bio:$bio\n" ;

    # Coverage
    $this->as()->power() ;
    $this->sa()->power() ;

    return $str ;
}


return 1 ;