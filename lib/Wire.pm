package WIRE ;

use strict ;


sub new {
    my $class = shift ;

    my $this = {
        power => 0,
        gates => [],
    } ;
    bless $this, $class ;

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
            foreach my $gate (@{$this->{gates}}){
                # $pin->prepare(undef, $v) ;
                $gate->signal($this, 0, 0) ;  
            }
        }
    }
    else {
        $v = $this->{power} ;
    }

    return $v ;
}


# Connect the gates to the current wire.
sub connect {
    my $this = shift ;
    my @gates = @_ ;

    foreach my $gate (@gates){
        push @{$this->{gates}}, $gate ;
        $gate->connect($this) ;
    }

    return $this ;
}


package WIRES ;

use strict ;
use Carp ;


sub new {
    my $class = shift ;
    my $n = shift ;

    my $this = {
        wires => [map { new WIRE() } (0..($n-1))],
        n => $n,
    } ;
    bless $this, $class ;

    return $this ;
}


sub wire {
    my $this = shift ;
    my $n = shift ;

    croak("Invalid wire index $n (n is $this->{n})") unless (($n >= 0)&&($n <= $this->{n})) ;

    return $this->{wires}->[$n] ;
}


# Assign the given power values (as a string) to the given wires.
# $wires and $powers are arrayrefs and they must have the same number of elements.
sub power {
    my $this = shift ;
    my $vs = shift ;

    if (defined($vs)){
        die("Length mismatch") unless (scalar(@{$this->{wires}}) == length($vs)) ;
        my @vs = split(//, $vs) ;
        for (my $j = 0 ; $j < scalar(@{$this->{wires}}) ; $j++){
            $this->{wires}->[$j]->power($vs[$j]) ;
        }
    }

    return join '', map { $_->power() } @{$this->{wires}} ;
}


package BUS ;

use strict ;


sub new {
    my $class = shift ;

    return new WIRES(8) ;
}


1 ;