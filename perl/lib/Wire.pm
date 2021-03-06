package WIRE ;

use strict ;
use Carp ;


my $ON = new WIRE(1, 1) ;
my $OFF = new WIRE(0, 1) ;

sub new {
    my $class = shift ;
    my $v = shift ;
    my $terminal = shift ;

    my $this = {
        power => $v || 0,
        terminal => $terminal,  # Terminal wires cannot change power.
        gates => [],
        prehooks => [],
        soft => 0,
    } ;
    bless $this, $class ;

    return $this ;
}


sub on {
    return $ON ;
}


sub off {
    return $OFF ;
}


sub terminal {
    my $this = shift ;

    $this->{terminal} = 1 ;
    return 1 ;
}


sub prehook {
    my $this = shift ;
    my $sub = shift ;

    if (defined($sub)){
        # Set prehook
        push @{$this->{prehooks}}, $sub ;
    }
}


# Get or set power on a wire.
sub power {
    my $this = $_[0] ;
    my $v = $_[1] ;
    my $soft = $_[2] ; # Soft signal only changes the power value, no signals and no hooks.

    return $this->{power} unless defined($v) ;
    return $this->{power} if $this->{terminal} ;

    # $v = ($v ? 1 : 0) ;
    $this->{power} = $v ;
    $this->{soft} = $soft ;

    if (! $soft){
        # Do prehooks
        foreach my $hook (@{$this->{prehooks}}){
            $hook->($v)  ;
        }

        foreach my $gate (@{$this->{gates}}){
            # Don't send signals to output pin.
            $gate->signal() if ($this ne $gate->{c}) ;
        }
    }

    return $v ;
}


# Connect the gates to the current wire.
sub connect {
    my $this = shift ;
    my @gates = @_ ;

    foreach my $gate (@gates){
        push @{$this->{gates}}, $gate ;
    }

    return $this ;
}


sub show {
    my $this = shift ;

    return $this->power() ;
}


sub name {
    my $this = shift ;
    my $name = shift ;

    if (defined($name)){
        $this->{name} = $name ;
        $this->prehook(sub {
            warn "Wire $this->{name}\@$this (smart:$this->{smart}) changing power to $_[0]\n" ;
        }) ;
    }

    return $this->{name} ;
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


sub show {
    my $this = shift ;

    return $this->power() ;
}


1 ;