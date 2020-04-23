package WIRE ;

use strict ;


sub new {
    my $class = shift ;
    my @pins = @_ ;

    my $this = {
        power => 0,
        pins => [],
    } ;
    bless $this, $class ;

    $this->connect(@pins) ;

    return $this ;
}


# Get or set power on a wire.
sub power {
    my $this = shift ;
    my $v = shift ;
    my $suppress_signal = shift ;

    if (defined($v)){
        $v = ($v ? 1 : 0) ;
        if ($v != $this->{power}){
            # There is a change in power. Record it and propagate the effect.
            $this->{power} = $v ;
            foreach my $pin (@{$this->{pins}}){
                 $pin->gate()->signal($pin, 0) unless $suppress_signal;  
            }
        }
    }

    return $this->{power} ;   
}


# Connect the pins to the current wire.
sub connect {
    my $this = shift ;
    my @pins = @_ ;

    foreach my $pin (@pins){
        push @{$this->{pins}}, $pin ;
        $pin->connect($this) ;
        $pin->gate()->signal($pin, 1) ;
    }
}


# Create new wires, one per pin.
sub new_wires {
    my $class = shift ;
    my @pins = @_ ;

    map { new WIRE($_) } @pins ;
}


# Assign the given power values (as a string)to the given wires.
# $wires and $powers are arrayrefs and they must have the same number of elements.
sub power_wires {
    my $class = shift ;
    my @wires = @_ ;

    my $vs = undef ;
    if (ref($wires[-1]) eq 'ARRAY'){
        $vs = pop @wires ;        
    }

    if (defined($vs)){
        die("Length mismatch") unless (scalar(@wires) == scalar(@{$vs})) ;
        for (my $j = 0 ; $j < scalar(@wires) ; $j++){
            $wires[$j]->power($vs->[$j]) ;
        }
    }

    return join '', map { $_->power() } @wires ;
}


1 ;