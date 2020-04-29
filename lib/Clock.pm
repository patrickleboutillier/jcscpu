package CLOCK ;

use strict ;
use Time::HiRes ;
use Gates ;
use Carp ;

# NOTE: Each tick of this clock calls itself recursively.
# This allowed the implementation to be faithful to the book. A loop could easily be used instead

sub new {
    my $class = shift ;
    my $wclk = shift ;
    my $wclke = shift ;
    my $wclks = shift ;
    my $maxticks = shift || -1 ;
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
        qticks => 0,
        maxticks => $maxticks,
        name => $name,
    } ;
    bless $this, $class ;

    $wclk->prehook(sub { $this->_qtick_callback("clk", @_) }) ;
    $wclkd->prehook(sub { $this->_qtick_callback("clkd", @_) }) ;

    $wclke->prehook(sub { $this->_trace("clke", @_) }) ;
    $wclks->prehook(sub { $this->_trace("clks", @_) }) ;

    return $this ;
}


sub clkd {
    my $this = shift ;

    return $this->{clkd} ;
}


sub qticks {
    my $this = shift ;

    return $this->{qticks} ;
}


sub start(){
    my $this = shift ;
    my $freqhz = shift || 0 ;

    # Close the circuit to start the clock
    my $wclk = $this->{clk} ;
    my $wclkd = $this->{clkd} ;
    $wclkd->pause($freqhz ? (1.0 / ($freqhz * 4)) : undef) ;
    $wclk->pause($freqhz ? (1.0 / ($freqhz * 4)) : undef) ;

    # Build the loop circuit.
    new CONN($wclk, $wclkd) ;
    new NOT($wclkd, $wclk) ;
}


# Maunal advancing of the clock.
sub qtick {
    my $this = shift ;

    my $qticks = $this->{qticks} ;
    my $mod = $qticks % 4 ;

    if ($mod == 0){
        $this->{clk}->power(1) ;
    }
    elsif ($mod == 1){
        $this->{clkd}->power(1) ;
    }
    elsif ($mod == 2){
         $this->{clk}->power(0) ;       
    }
    else {
        # mod == 3
        $this->{clkd}->power(0) ;
    }
}


# Maunal advancing of the clock.
sub tick {
    my $this = shift ;

    my $qticks = $this->{qticks} ;
    my $mod = $qticks % 4 ;

    croak("Can't tick a clock mid-cycle (qtick: $qticks % 4 == $mod)!") if $mod ;

    map { $this->qtick() } (0..3) ;
}


sub _qtick_callback {    
    my $this = shift ;
    my $label = shift ;
    my $s = shift ;

    my $maxqticks = $this->{maxticks} * 4 ;
    if (($maxqticks > -1)&&($this->{qticks} >= $maxqticks)){
        my $maxticks = $maxqticks / 4 ;
        die("HALTING! (Max clock ticks of $maxticks reached)\n") ;
    }

    $this->_trace($label, $s) ;

    $this->{qticks}++ ; 
}


sub _trace {
    my $this = shift ;
    my $label = shift ;
    my $s = shift ;

    my ($ts, $tsm) = Time::HiRes::gettimeofday() ;
    warn sprintf("[$ts.%06d] tick %8.2lf: %-4s %-3s\n", $tsm, $this->{qticks} / 4, $label, ($s ? "on" : "off")) ;
}


return 1 ;