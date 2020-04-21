package RAM ;

use strict ;
use Register ;
use Decoder ;


sub new {
    my $class = shift ;
    my $name = shift ;
    
    # Build the RAM circuit
    my $MAR = new REGISTER() ;
    my @maris = $MAR->is() ;
    my $TD = new DECODER(4, "4x16") ;
    my $LD = new DECODER(4, "4x16") ;
    # Hook up the MAR to both decoders.
    map { new WIRE($maris[$_], $TD->i($_)) } (0..3) ;
    map { new WIRE($maris[$_+4], $LD->i($_)) } (0..3) ;

    my $bus = new BUS() ;
    my $ws = new WIRE() ;
    my $we = new WIRE() ;
    my @ios = () ; # This should be a set of PASS gates hooked up to $bus

    # Attach wires to all decoder outputs.
    my @wxs = map { new WIRE($TD->o($_)) ; } (0..15) ;
    my @wys = map { new WIRE($LD->o($_)) ; } (0..15) ;
    # Now we create the circuit
    for (my $x = 0 ; $x < 16 ; $x++){
        for (my $y = 0 ; $y < 16 ; $y++){
            # Create the subcircuit to be used at each location
            my $xg = new AND() ;
            my $sg = new AND() ;
            my $eg = new AND() ;
            my $R = new REGISTER("RAM($x, $y)") ;
            $wxs[$x]->connect($xg->b()) ;
            $wys[$y]->connect($xg->a()) ;
            new WIRE($xg->c(), $sg->a(), $eg->a()) ;
            $ws->connect($sg->b()) ;
            $we->connect($eg->b()) ;
            new WIRE($sg->c(), $R->s()) ;
            new WIRE($eg->c(), $R->e()) ;
        }
    }
    
    my $this = {
        as => [$MAR->is()],
        sa => $MAR->s(),
        e => PASS->in($we),
        s => PASS->in($ws),
        ios => \@ios,
        name => $name,
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


return 1 ;