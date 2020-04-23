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

    if (defined($v)){
        $v = ($v ? 1 : 0) ;
        if ($v != $this->{power}){
            # There is a change in power. Record it and propagate the effect.
            $this->{power} = $v ;
            foreach my $pin (@{$this->{pins}}){
                 $pin->gate()->signal($pin, 0, 0) ;  
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
        $pin->gate()->signal($pin, 0, 1) ;
    }
}


# To reset a wire, we need to "poke" the connected pins and asks them to resend their signals.  
sub reset {
    my $this = shift ;
    my $skip = shift ;

    foreach my $pin (@{$this->{pins}}){
        next if $pin eq $skip ; # This prevents infinite loops with bi-directioal PASS gates.
        $pin->gate()->signal($pin, 1, 0) ;
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