use strict ;


package WIRE ;


sub new {
    my $class = shift ;
    my $this = {
        power => 0,
        pins => [],
    } ;
    bless $this, $class ;
    return $this ;
}


sub power {
    my $this = shift ;
    my $v = shift ;

    if (defined($v)){
        $v = ($v ? 1 : 0) ;
        if ($v != $this->{power}){
            # There is a change in power. Record it and propagate the effect.
            $this->{power} = $v ;
            foreach my $pin (@{$this->{pins}}){
                if (! $pin->output()){
                    $pin->wire()->power($v) ;  
                    $pin->gate()->eval() ;  
                }
            }
        }
    }

    return $this->{power} ;   
}


sub connect {
    my $this = shift ;
    my @pins = @_ ;

    foreach my $pin (@pins){
        $pin->wire($this) ;
        push @{$this->{pins}}, $pin ;
    }
}


package PIN ;


sub new {
    my $class = shift ;
    my $gate = shift ;
    my $output = shift ;
    my $this = {
        gate => $gate,
        output => $output,
    } ;
    bless $this, $class ;
    return $this ;
}


sub wire {
    my $this = shift ;
    my $wire = shift ;

    if ($wire){
        # New wire attached
        $this->{wire} = $wire ;
        $this->gate()->eval() ;
    }
    return $this->{wire} ;   
}


sub gate {
    my $this = shift ;
    return $this->{gate} ;
}


sub output {
    my $this = shift ;
    return $this->{output} ;
}


package NAND ; 


sub new {
    my $class = shift ;
    my $name = shift ;
    my $this = {} ;
    $this->{a} = new PIN($this) ;
    $this->{b} = new PIN($this) ;
    $this->{c} = new PIN($this, 1) ;
    $this->{name} = $name ;
    bless $this, $class ;
    return $this ;
}


sub a {
    my $this = shift ;
    return $this->{a} ;
}


sub b {
    my $this = shift ;
    return $this->{b} ;
}


sub c {
    my $this = shift ;
    return $this->{c} ;
}


sub eval {
    my $this = shift ;

    return unless $this->a()->wire() ;
    return unless $this->b()->wire() ;
    return unless $this->c()->wire() ;

    # This code could be replaced by a truth table. No need to actually the language operators to perform
    # the boolean and and the not.
    my $a = $this->a()->wire()->power() ;
    my $b = $this->b()->wire()->power() ;
    my $c = ! ($a && $b) ;
    $c = ($c ? 1 : 0) ;

 
    $this->c()->wire()->power($c) ;
    # warn "NAND[$this->{name}]: (a:$a, b:$b) -> c:$c\n" ;
}


return 1 ;
