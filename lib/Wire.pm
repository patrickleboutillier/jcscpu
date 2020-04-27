package WIRE ;

use strict ;


sub new {
    my $class = shift ;
    my $v = shift ;

    my $this = {
        power => $v || 0,
        gates => [],
    } ;
    bless $this, $class ;

    return $this ;
}


sub prehook {
    my $this = shift ;
    my $sub = shift ;

    if (defined($sub)){
        # Set prehook
        $this->{prehook} = $sub ;
    }

    return $this->{prehook} ;
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
            my $prehook = $this->{prehook} ;
            $prehook->($v) if $prehook ;
            foreach my $gate (@{$this->{gates}}){
                $gate->signal($this) ;  
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


package BUS ;

use strict ;
use Carp ;


sub new {
    my $class = shift ;
    my $n = shift || 8 ;

    return $class->wrap(map { new WIRE() } (0..($n-1)))
}


sub wrap {
    my $class = shift ;
    my @wires = @_ ;

    my $this = {
        wires => \@wires,
        n => scalar(@wires),
    } ;
    bless $this, $class ;

    return $this ;
}


sub n {
    my $this = shift ;
    return $this->{n} ;
}


sub wires {
    my $this = shift ;

    return @{$this->{wires}} ;
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
        die("Invalid bus power string '$vs' (n is $this->{n})") unless (scalar(@{$this->{wires}}) == length($vs)) ;
        my @vs = split(//, $vs) ;
        for (my $j = 0 ; $j < scalar(@{$this->{wires}}) ; $j++){
            $this->{wires}->[$j]->power($vs[$j]) ;
        }
    }

    return join '', map { $_->power() } @{$this->{wires}} ;
}


1 ;