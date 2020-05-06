package IOADAPTER ;

use strict ;
use Carp ;
use Decoder ;


sub new {
    my $class = shift ;
    my $bcpu = shift ;
    my $bio = shift ;

    my $this = {
        bcpu => $bcpu,
        bio => $bio,    
        devs => [],
    } ;
    bless $this, $class ;

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

    return $this->{devs}->[$n]->{mem}->o()->power() ;
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

    if (! $this->{devdec}){
        my $bop = new BUS(16) ;
        my $opdec = new DECODER(4, $this->{bio}, $bop) ;
        my $bdev = new BUS(256) ;
        $this->{devdec} = new DECODER(8, $this->{bcpu}, $bdev) ;
        $this->{indata} = $opdec->o(oct("0b0100")) ;
        $this->{inaddr} = $opdec->o(oct("0b0110")) ;
        $this->{outdata} = $opdec->o(oct("0b1001")) ;
        $this->{outaddr} = $opdec->o(oct("0b1011")) ;
    }

    my $wmem = new WIRE() ;
    my $mem = new MEMORY($this->{devdec}->o($n), $this->{outaddr}, $wmem, $n) ;
    $this->{devs}->[$n] = { 
        name => $name, 
        mem => $mem,
    } ;

    new AND($wmem, $this->{outdata}, $outdata) if defined($outdata) ;
    new AND($wmem, $this->{indata}, $indata) if defined($indata) ; 
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