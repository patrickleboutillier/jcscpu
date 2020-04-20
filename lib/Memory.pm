use strict ;
use Gates ;


package MEMORY ;


sub new {
    my $class = shift ;
    my $name = shift ;

    my $this = {} ;
    $this->{i} = new PIN($this) ;
    $this->{s} = new PIN($this) ;
    $this->{o} = new PIN($this, 1) ;
    $this->{name} = $name ;

    # Build the memory circuit, and record the wires.
    my $g1 = new NAND("g1") ;
    my $g2 = new NAND("g2") ;
    my $g3 = new NAND("g3") ;
    my $g4 = new NAND("g4") ;
    my $wi = new WIRE() ;
    my $ws = new WIRE() ;
    my $wa = new WIRE() ;
    my $wb = new WIRE() ;
    my $wc = new WIRE() ;
    my $wo = new WIRE() ;
    $wi->connect($g1->a()) ;
    $ws->connect($g1->b(), $g2->b()) ;
    $wa->connect($g1->c(), $g2->a(), $g3->a()) ;
    $wb->connect($g2->c(), $g4->b()) ;
    $wc->connect($g3->b(), $g4->c()) ;
    $wo->connect($g3->c(), $g4->a()) ;
  
    $this->{wi} = $wi ;
    $this->{ws} = $ws ;
    $this->{wo} = $wo ;

    bless $this, $class ;
    return $this ;
}


sub i {
    my $this = shift ;
    return $this->{i} ;
}


sub s {
    my $this = shift ;
    return $this->{s} ;
}


sub o {
    my $this = shift ;
    return $this->{o} ;
}


sub eval {
    my $this = shift ;

    return unless $this->i()->wire() ;
    return unless $this->s()->wire() ;
    return unless $this->o()->wire() ;

    my $i = $this->i()->wire()->power() ;
    $this->{wi}->power($i) ;
    my $s = $this->s()->wire()->power() ;
    $this->{ws}->power($s) ;

    my $o = $this->{wo}->power() ;
    $this->o()->wire()->power($o) ;
    #warn "M[$this->{name}]: (is:$i, s:$s) -> os:$o\n" ;
}


return 1 ;