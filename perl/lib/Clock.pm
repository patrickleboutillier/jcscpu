package CLOCK ;

use strict ;
use Time::HiRes ;
use Gates ;
use Carp ;


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
        qticks => 0,
        maxticks => $maxticks,
        name => $name,
        pause => 0,
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


sub ticks {
    my $this = shift ;

    my $qt = $this->qticks() ;

    return int($qt / 4) ;
}


sub start {
    my $this = shift ;
    my $freqhz = shift || 0 ;
    my $maxticks = shift ;

    $this->{maxticks} = $maxticks if defined($maxticks) ;

    my $wclk = $this->{clk} ;
    my $wclkd = $this->{clkd} ;
    $this->{pause} = ($freqhz ? (1.0 / ($freqhz * 4)) : 0) ;

    # Close the circuit to start the clock
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


# Manual advancing of the clock.
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
        # $mod == 3
        $this->{clkd}->power(0) ;
    }
}


# Maunal advancing of the clock.
sub tick {
    my $this = shift ;
    my $nb = shift || 1 ;

    my $qticks = $this->{qticks} ;
    my $mod = $qticks % 4 ;
    croak("Can't tick mid-cycle (qticks: $qticks)!") if $mod ;

    for (my $j = 0 ; $j < $nb ; $j++){
        map { $this->qtick() } (0..3) ;
    }
}


sub _qtick_callback {    
    my $this = shift ;
    my $label = shift ;
    my $s = shift ;


    if ($this->{pause}){
        Time::HiRes::sleep($this->{pause}) ;
    }

    my $maxticks = $this->{maxticks} ;
    if (($maxticks >= 0)&&($this->ticks() >= $maxticks)){
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
        print STDERR sprintf("# [$ts.%06d] tick %8.2lf/$this->{maxticks}: %-4s %-3s\n", $tsm, $this->{qticks} / 4, $label, ($s ? "on" : "off")) ;
    }
}


sub show {
    my $this = shift ;

    my $qt = $this->qticks() ;
    my $t = $this->ticks() ;
    my $q = $qt % 4 ;

    my $clk = $this->{clk}->power() ;
    my $clkd = $this->{clkd}->power() ;
    my $clke = $this->{clke}->power() ;
    my $clks = $this->{clks}->power() ;
    return "CLK(\@$t.$q\[$qt]): clk:$clk  clkd:$clkd  clke:$clke  clks:$clks\n" ;
}


1 ;