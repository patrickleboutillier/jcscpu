package DECODER ;

use strict ;
use Gates ;


sub new {
    my $class = shift ;
    my $n = shift ;
    my $name = shift ;

    die ("Invalid DECODER number of inputs $n") unless ($n >= 2) ;
    
    # Build the decoder circuit
    my @is = () ;
    my @os = () ;
    my @map = () ;
    for (my $j = 0 ; $j < $n ; $j++){
        my $ng = new NOT() ;
        my $w1 = new WIRE($ng->a()) ;
        my $w0 = new WIRE($ng->b()) ;
        push @is, PASS->in($w1) ;
        
        # Now we want to classify the wires w1 and w0 and store them in a map to be able to
        # hook them up to the AND gates later.
        $map[$j]->[0] = $w0 ;
        $map[$j]->[1] = $w1 ;
    }

    for (my $j = 0 ; $j < 2**$n ; $j++){
        # What is the "label" (x/x/x...) of this ANDn gate?
        my $label = sprintf("%0${n}b", $j) ;

        my $ag = new ANDn($n, $label) ;
        push @os, $ag->o() ;
        
        # Now we must hook up the $n inputs of $a.
        my @path = split(//, $label) ;
        for (my $k = 0 ; $k < $n ; $k++){
            my $idx = $path[$k] ;
            # Connect the kth input of our ANDn gate to the proper output wire in the map.
            $map[$k]->[$idx]->connect($ag->i($k)) ;
        }
    }

    my $this = {
        is => \@is,
        os => \@os,
        n => $n,
        name => $name,
    } ;

    bless $this, $class ;
    return $this ;
}


sub is {
    my $this = shift ;
    return @{$this->{is}} ;
}


sub i {
    my $this = shift ;
    my $n = shift ;
    die ("Invalid input index $n") unless (($n >= 0)&&($n < $this->{n})) ;
    return $this->{is}->[$n] ;
}


sub os {
    my $this = shift ;
    return @{$this->{os}} ;
}


sub o {
    my $this = shift ;
    my $n = shift ;
    die ("Invalid output index $n") unless (($n >= 0)&&($n < 2**$this->{n})) ;
    return $this->{os}->[$n] ;
}

return 1 ;