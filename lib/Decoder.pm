package DECODER ;

use strict ;
use Gates ;
use Carp ;

sub new {
    my $class = shift ;
    my $n = shift ;
    my $bis = shift ;
    my $bos = shift ;
    my $name = shift ;

    croak("Invalid DECODER number of inputs $n") unless ($n >= 2) ;
    croak("Invalid number of wires in DECODER input bus (" . $bis->n(). ") (n is $n)") unless $bis->n() eq $n ;
    croak("Invalid number of wires in DECODER output bus (" . $bos->n(). ") (2**n is " . 2**$n . ")") unless $bos->n() eq 2**$n ;

    # Build the decoder circuit
    my @map = () ;
    for (my $j = 0 ; $j < $n ; $j++){
        my $w1 = $bis->wire($j) ;
        my $w0 = new WIRE() ;
        new NOT($w1, $w0, "$name/NOT[$j]") ;
        
        # Now we want to classify the wires w1 and w0 and store them in a map to be able to
        # hook them up to the AND gates later.
        $map[$j]->[0] = $w0 ;
        $map[$j]->[1] = $w1 ;
    }

    for (my $j = 0 ; $j < 2**$n ; $j++){
        # What is the "label" (x/x/x...) of this ANDn gate?
        my $label = sprintf("%0${n}b", $j) ;
        my @path = split(//, $label) ;

        # Now we must hook up the $n inputs of $a.
        my @wos = () ;
        for (my $k = 0 ; $k < $n ; $k++){
            my $idx = $path[$k] ;
            # Connect the kth input of our ANDn gate to the proper output wire in the map.
            push @wos, $map[$k]->[$idx] ;
        }

        new ANDn($n, BUS->wrap(@wos), $bos->wire($j), $label) ;
    }

    my $this = {
        is => $bis,
        os => $bos,
        n => $n,
        name => $name,
    } ;
    bless $this, $class ;

    return $this ;
}


sub is {
    my $this = shift ;
    return $this->{is} ;
}


sub i {
    my $this = shift ;
    my $n = shift ;
    die ("Invalid input index $n") unless (($n >= 0)&&($n < $this->{n})) ;
    return $this->{is}->wire($n) ;
}


sub os {
    my $this = shift ;
    return $this->{os} ;
}


sub o {
    my $this = shift ;
    my $n = shift ;
    die ("Invalid output index $n") unless (($n >= 0)&&($n < 2**$this->{n})) ;
    return $this->{os}->wire($n) ;
}


return 1 ;