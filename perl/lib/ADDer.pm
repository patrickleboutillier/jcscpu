package ADDER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $bas = shift ;
    my $bbs = shift ;
    my $wci = shift ;
    my $bsums = shift ;
    my $wco = shift ;

    # Build the ADDer circuit
    my $twci = new WIRE() ;
    my $twco = $wco ;
    for (my $j = 0 ; $j < 8 ; $j++){
        new ADD($bas->wire($j), $bbs->wire($j), ($j < 7 ? $twci : $wci), $bsums->wire($j), $twco) ;
        $twco = $twci ;
        $twci = new WIRE() ;
    }

    my $this = {
        as => $bas,
        bs => $bbs,
        carry_in => $wci, 
        sums => $bsums,
        carry_out => $wco, 
    } ;
    bless $this, $class ;

    return $this ;
}


sub as {
    my $this = shift ;
    return $this->{as} ;
}


sub bs {
    my $this = shift ;
    return $this->{bs} ;
}


sub carry_in {
    my $this = shift ;
    return $this->{carry_in} ;
}


sub sums {
    my $this = shift ;
    return $this->{sums} ;
}


sub carry_out {
    my $this = shift ;
    return $this->{carry_out} ;
}


sub show {
    my $this = shift ;

    my $a = $this->{as}->power() ;
    my $b = $this->{bs}->power() ;
    my $ci = $this->{carry_in}->power() ;
    my $co = $this->{carry_out}->power() ;    
    my $sum = $this->{sums}->power() ;

    return "ADDER: a:$a, b:$b, ci:$ci, co:$co, sum:$sum\n" ;
}


1 ;