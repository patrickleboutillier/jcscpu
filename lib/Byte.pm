use strict ;
use Memory ;


package BYTE ;


sub new {
    my $class = shift ;
    my $name = shift ;

    my $this = {} ;
    $this->{is} = [map { new PIN($this) } (1..8)] ;
    $this->{s} = new PIN($this) ;
    $this->{os} = [map { new PIN($this, 1) } (1..8)] ;
    $this->{name} = $name ;

    $this->{ms} = [map { new MEMORY($_ - 1) } (1..8)] ;
    $this->{wis} = [map {my $wi = new WIRE() ; $wi->connect($_->i()) ; $wi} @{$this->{ms}}] ;
    my $ws = new WIRE() ;
    map {$ws->connect($_->s())} @{$this->{ms}} ;
    $this->{ws} = $ws ;
    $this->{wos} = [map {my $wo = new WIRE() ; $wo->connect($_->o()) ; $wo} @{$this->{ms}}] ;

    bless $this, $class ;
    return $this ;
}


sub is {
    my $this = shift ;
    return @{$this->{is}} ;
}


sub s {
    my $this = shift ;
    return $this->{s} ;
}


sub os {
    my $this = shift ;
    return @{$this->{os}} ;
}


sub eval {
    my $this = shift ;

    my @is = $this->is() ;
    foreach my $i (@is){
        return unless $i->wire() ;    
    }
    return unless $this->s()->wire() ;
    my @os = $this->os() ;
    foreach my $o (@os){
        return unless $o->wire() ;    
    }

    my $i = '' ;
    for (my $j = 0 ; $j < 8 ; $j++){
        my $t = $is[$j]->wire()->power() ;
        $i .= $t ;
        $this->{wis}->[$j]->power($t) ;
    }
    my $s = $this->s()->wire()->power() ;
    $this->{ws}->power($s) ;
    my $o = '' ;
    for (my $j = 0 ; $j < 8 ; $j++){
        my $t = $this->{wos}->[$j]->power() ;
        $o .= $t ;    
        $os[$j]->wire()->power($t) ;
    }

    #warn "B[$this->{name}]: (is:$i, s:$s) -> os:$o\n" ;
}


return 1 ;