package CLOCK ;

use strict ;
use Time::HiRes ;
use Gates ;

# NOTE: Each tick of this clock calls itself recursively.
# This allowed the implementation to be faithful to the book. A loop could easily be used instead

sub new {
    my $class = shift ;
    my $wclk = shift ;
    my $wclke = shift ;
    my $wclks = shift ;
    my $name = shift  ;

    # Here we must fake it a bit due to the implementation system.
    my $wclkd = new WIRE() ;
    new OR($wclk, $wclkd, $wclke) ;
    new AND($wclk, $wclkd, $wclks) ;

    my $this = {
        clk => $wclk,
        clkd => $wclkd,
        clke => $wclke,
        clks => $wclks,
        name => $name,
        qticks => 0,
    } ;
    bless $this, $class ;

    return $this ;
}


sub clkd {
    my $this = shift ;

    return $this->{clkd} ;
}


sub start(){
    my $this = shift ;
    my $freqhz = shift ;
    my $maxticks = shift || -1 ;

    # Close the circuit to start the clock
    my $wclk = $this->{clk} ;
    my $wclkd = $this->{clkd} ;
    $wclkd->pause($freqhz ? (1.0 / ($freqhz * 4)) : undef) ;
    $wclk->pause($freqhz ? (1.0 / ($freqhz * 4)) : undef) ;

    $wclk->prehook(sub { $this->qtick("clk", $maxticks * 4, @_) }) ;
    $wclkd->prehook(sub { $this->qtick("clkd", $maxticks * 4, @_) }) ;

    new CONN($wclk, $wclkd) ;
    new NOT($wclkd, $wclk) ;
}


sub qtick {    
    my $this = shift ;
    my $label = shift ;
    my $max = shift ;
    my $s = shift ;

    if (($max > -1)&&($this->{qticks} >= $max)){
        $max = $max / 4 ;
        die("HALTING! (Max clock ticks of $max reached)") ;
    }

    $this->trace($label, $s) ;

    $this->{qticks}++ ; 
}


sub trace {
    my $this = shift ;
    my $label = shift ;
    my $s = shift ;

    my ($ts, $tsm) = Time::HiRes::gettimeofday() ;
    warn sprintf("[$ts.%06d] tick %8.2lf: %-4s %-3s\n", $tsm, $this->{qticks} / 4, $label, ($s ? "on" : "off")) ;
    
    $this->{qticks}++ ; 
}


return 1 ;