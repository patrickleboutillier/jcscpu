package IOADAPTER ;

use strict ;
use Carp ;
use Decoder ;


sub new {
    my $class = shift ;
    my $bcpu = shift ;
    my $bio = shift ;

    my $bop = new BUS(16) ;
    my $opdec = new DECODER(4, $bio, $bop) ;

    my $this = {
        indata => $opdec->o(oct("0b0100")),
        inaddr => $opdec->o(oct("0b0110")),
        outdata => $opdec->o(oct("0b1001")),
        outaddr => $opdec->o(oct("0b1011")),       
        devs => [],
        mems => [],
    } ;
    bless $this, $class ;

    my $bdev = new BUS(256) ;
    my $devdec = new DECODER(8, $bcpu, $bdev) ;
    for (my $j = 0 ; $j < 256 ; $j++){
        $this->{mems}->[$j] = new MEMORY($devdec->o($j), $this->{outaddr}, new WIRE(), $j) ;
    }

    $this->{devdec} = $devdec ;

    return $this ;
}


sub active {
    my $this = shift ;
    my $n = shift ;

    if (($n < 0)||($n > 255)){
        croak("Invalid device number '$n'") ;
    }
    if (! defined($this->{devs}->[$n])){
        croak("No device registered at address $n!") ;
    }

    return $this->{mems}->[$n]->o()->power() ;
}


sub registered {
    my $this = shift ;
    my $n = shift ;

    if (($n < 0)||($n > 255)){
        croak("Invalid device number '$n'") ;
    }

    return ($this->{devs}->[$n] ? 1 : 0) ;
}


# Register a new device
sub register {
    my $this = shift ;
    my $n = shift ; # Device number
    my $outdata = shift ;
    my $indata = shift ;
    my $name = shift ;

    if (($n < 0)||($n > 255)){
        croak("Invalid device number '$n'") ;
    }
    if (defined($this->{devs}->[$n])){
        croak("Device already registered at address $n") ;
    }

    if (defined($outdata)){
        my $active = $this->{mems}->[$n]->o() ;
        new AND($active, $this->{outdata}, $outdata) ; 
    }
    if (defined($indata)){
        my $active = $this->{mems}->[$n]->o() ;
        new AND($active, $this->{indata}, $indata) ; 
    }

    $this->{devs}->[$n] = { name => $name } ;
}


sub show {
    my $this = shift ;

    my $str = '' ;
    for (my $j = 0 ; $j < 256 ; $j++){
        if ($this->{devs}->[$j]){
            $str .= "  DEV($this->{devs}->[$j]->{name}, $j): " . $this->{mems}->[$j]->show() . "\n" ;
        }
    }

    return $str ;
}


1 ;