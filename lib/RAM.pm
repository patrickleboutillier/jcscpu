package RAM ;

use strict ;
use Register ;
use Decoder ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the RAM circuit  
    my $MAR = new REGISTER("MAR") ;
    # MAR output (e) is always on
    WIRE->new($MAR->e())->power(1) ;

    my @maris = $MAR->os() ;
    my $TD = new DECODER(4, "4x16") ;
    my $LD = new DECODER(4, "4x16") ;
    # Hook up the MAR to both decoders.
    map { new WIRE($maris[$_], $TD->i($_)) } (0..3) ;
    map { new WIRE($maris[$_+4], $LD->i($_)) } (0..3) ;

    my $bus = new BUS() ;
    my $ws = new WIRE() ;
    my $we = new WIRE() ;
    my @ios = map { PASS->io($_) } $bus->wires() ;

    # Attach wires to all decoder outputs.
    my @wxs = map { new WIRE($TD->o($_)) ; } (0..15) ;
    my @wys = map { new WIRE($LD->o($_)) ; } (0..15) ;
    # Now we create the circuit
    my %GRID = () ;
    for (my $x = 0 ; $x < 16 ; $x++){
        for (my $y = 0 ; $y < 16 ; $y++){
            # Create the subcircuit to be used at each location
            my $xg = new AND() ;
            my $sg = new AND() ;
            my $eg = new AND() ;
            my $label = sprintf("%04b%04b", $x, $y) ;
            my $R = new REGISTER("RAM($label)") ;
            $GRID{$label} = $R ;
            $wxs[$x]->connect($xg->b()) ;
            $wys[$y]->connect($xg->a()) ;
            new WIRE($xg->c(), $sg->a(), $eg->a()) ;
            $ws->connect($sg->b()) ;
            $we->connect($eg->b()) ;
            new WIRE($sg->c(), $R->s()) ;
            new WIRE($eg->c(), $R->e()) ;
            $bus->connect([$R->is()], [$R->os()]) ;
        }
    }
    
    my $this = {
        as => [$MAR->is()],
        sa => $MAR->s(),
        e => PASS->in($we),
        s => PASS->in($ws),
        ios => \@ios,
        name => $name,
        MAR => $MAR,
        bus => $bus,
        GRID => \%GRID,
    } ;

    bless $this, $class ;
    return $this ;
}


sub as {
    my $this = shift ;
    return @{$this->{as}} ;
}


sub sa {
    my $this = shift ;
    return $this->{sa} ;
}


sub ios {
    my $this = shift ;
    return @{$this->{ios}} ;
}


sub s {
    my $this = shift ;
    return $this->{s} ;
}


sub e {
    my $this = shift ;
    return $this->{e} ;
}


sub show {
    my $this = shift ;
    my @addrs = @_ ;

    my $mar = $this->{MAR}->show() ;
    my $bus = $this->{bus}->power() ;
    my $ios = WIRE->power_wires(map { $_->wire() } $this->ios()) ;
    my $e = $this->e()->wire()->power() ;
    my $s = $this->s()->wire()->power() ;
    my $str = "RAM($this->{name}):\n  $mar" ;
    foreach my $a (@addrs){
        $str .= "\n  " . $this->{GRID}->{$a}->show() ;
    }
    $str .= "\n  e:$e, s:$s, bus:$bus, ios:$ios" ;

    return $str ;
}


return 1 ;