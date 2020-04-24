package XORER ;

use strict ;
use Wire ;
use Gates ;


sub new {
    my $class = shift ;
    my $name = shift ;

    # Build the XORer circuit
    my @cmps = map { new CMP() } (0..7) ;
    WIRE->new($cmps[0]->eqi())->power(1) ;
    WIRE->new($cmps[0]->ali())->power(0) ;

    map { 
        new WIRE($cmps[$_]->eqo(), $cmps[$_+1]->eqi()) ;
        new WIRE($cmps[$_]->alo(), $cmps[$_+1]->ali()) ;
    } (0..6) ;

    my $this = {
        as => [map { $_->a() } @cmps],
        bs => [map { $_->b() } @cmps],
        cs => [map { $_->c() } @cmps],
        eqo => $cmps[7]->eqo(),
        alo => $cmps[7]->alo(),
    } ;
    bless $this, $class ;

    return $this ;
}


sub as {
    my $this = shift ;
    return @{$this->{as}} ;
}


sub bs {
    my $this = shift ;
    return @{$this->{bs}} ;
}


sub cs {
    my $this = shift ;
    return @{$this->{cs}} ;
}


# 'a' larger out
sub alo {
    my $this = shift ;
    return $this->{alo} ;
}


# 'equal so far' out
sub eqo {
    my $this = shift ;
    return $this->{eqo} ;
}


return 1 ;