package parts

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
DECODER
*/
type Decoder struct {
	is, os *g.Bus
	name   string
}

func NewDecoder(bis *g.Bus, bos *g.Bus, name string) *Decoder {
	ni := bis.GetSize()
	no := bos.GetSize()
	if ni < 2 {
		panic(fmt.Errorf("Invalid DECODER number of inputs %d", ni))
	}
	if (1 << ni) != no {
		panic(fmt.Errorf("Invalid number of wires in DECODER output bus (%d) (2**n is %d)", no, (1 << ni)))
	}

	this := &Decoder{bis, bos, name}

	/*
	   # Build the decoder circuit
	   map := make([][2]bool, n, n)
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
	*/

	return this
}

/*


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

1 ;
*/
