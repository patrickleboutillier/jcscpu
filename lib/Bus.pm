package BUS ;

use strict ;
use Gates ;


# A 'bundle' is a collection of 8 pins
sub new {
    my $class = shift ;
    my @bundles = @_ ;

    my $this = {
        bundles => [],
        wires => [map { new WIRE() } (0..7)]
    } ;
    bless $this, $class ;

    $this->connect(@bundles) ;

    return $this ;
}


sub wire {
    my $this = shift ;
    my $n = shift ;
    die("Bad wire index $n") unless (($n >= 0)&&($n <= 7)) ;

    return $this->{wires}->[$n] ;
}


sub wires {
    my $this = shift ;

    return @{$this->{wires}} ;
}


sub power {
    my $this = shift ;
    my $pstr = shift ;

    die("Invalid bus power string '$pstr'") unless $pstr =~ /^[01]{8}$/ ;
    my @ps = split(//, $pstr) ;
    for (my $j = 0 ; $j < 8 ; $j++){
        $this->{wires}->[$j]->power($ps[$j]) ;
    }
}


sub connect {
    my $this = shift ;
    my @bundles = @_ ;

    foreach my $bundle (@bundles){
        die("Invalid bundle count!") if scalar(@{$bundle}) != 8 ;
        for (my $j = 0 ; $j < 8 ; $j++){
            my $pin = $bundle->[$j] ;
            my $wire = $this->{wires}->[$j] ;
            $wire->connect($pin) ;
        }
    }
}


sub show {
    my $this = shift ;
    
    return join '', map { $_->power() } @{$this->{wires}} ;
}


1 ;