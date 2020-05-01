package CLOCK ;

use strict ;
use Time::HiRes ;
use Gates ;
use Carp ;

# NOTE: Each tick of this clock calls itself recursively. A more performant lopp-based clock may be required on the future...
# This allowed the implementation to be faithful to the book. A loop could easily be used instead


$CLOCK::DEBUG = 0 ;
$CLOCK::MODE = 'loop' ;


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
        qticks => -1,
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

    return $this->{qticks} + 1 ;
}


sub ticks {
    my $this = shift ;

    my $qt = $this->qticks() ;
    
    return int($qt / 4) ;
}


sub start(){
    my $this = shift ;
    my $freqhz = shift || 0 ;
    my $maxticks = shift ;

    $this->{maxticks} = $maxticks if defined($maxticks) ;

    # Close the circuit to start the clock
    my $wclk = $this->{clk} ;
    my $wclkd = $this->{clkd} ;
    $wclkd->pause($freqhz ? (1.0 / ($freqhz * 4)) : undef) ;
    $wclk->pause($freqhz ? (1.0 / ($freqhz * 4)) : undef) ;

    # Build the loop circuit.
    if ($CLOCK::MODE eq 'gates'){
        new CONN($wclk, $wclkd) ;
        new NOT($wclkd, $wclk) ;
    }
    else {
        while (1){
            $this->tick() ;
        }
    }
}


# Maunal advancing of the clock.
sub qtick {
    my $this = shift ;

    my $qticks = $this->{qticks} ;
    my $mod = $qticks % 4 ;

    if ($mod == 3){
        $this->{clk}->power(1) ;
    }
    elsif ($mod == 0){
        $this->{clkd}->power(1) ;
    }
    elsif ($mod == 1){
         $this->{clk}->power(0) ;       
    }
    else {
        # $mod == 2
        $this->{clkd}->power(0) ;
    }
}


# Maunal advancing of the clock.
sub tick {
    my $this = shift ;

    my $qticks = $this->{qticks} ;
    my $mod = $qticks % 4 ;

    croak("Can't tick a clock mid-cycle (qticks: $qticks)!") if $mod != 3 ;

    map { $this->qtick() } (0..3) ;
}


sub _qtick_callback {    
    my $this = shift ;
    my $label = shift ;
    my $s = shift ;

    my $maxqticks = $this->{maxticks} * 4 ;
    if (($maxqticks > -1)&&(($this->{qticks} + 1) >= $maxqticks)){
        my $maxticks = $maxqticks / 4 ;
        die("HALTING! (Max clock ticks of $maxticks reached)\n") ;
    }

    $this->{qticks}++ ; 

    $this->_trace($label, $s) ;
}


sub _trace {
    my $this = shift ;
    my $label = shift ;
    my $s = shift ;

    my ($ts, $tsm) = Time::HiRes::gettimeofday() ;
    if ($CLOCK::DEBUG){
        warn sprintf("[$ts.%06d] tick %8.2lf: %-4s %-3s\n", $tsm, $this->{qticks} / 4, $label, ($s ? "on" : "off")) ;
    }
}


sub show {
    my $this = shift ;

    my $qt = $this->qticks() ;
    my $t = int($qt / 4) ;
    my $q = $qt % 4 ;

    my $clk = $this->{clk}->power() ;
    my $clkd = $this->{clkd}->power() ;
    my $clke = $this->{clke}->power() ;
    my $clks = $this->{clks}->power() ;
    return "CLK:$t.$q ($qt) (clk:$clk  clkd:$clkd  clke:$clke  clks:$clks)\n" ;
}


return 1 ;