package DEVICES ;

use strict ;
use IO::Handle ;
use Carp ;


# A rude implementation of IO Devices that hook up the IO and data busses.
# These implementations are really hackish, just a way to complete the loop to be able
# to have the computer communicate with the outside world.

# An output-only TTY implementation, just grabs the ASCII code on the bus and prints
# the corresponding character to STDOUT (or elsewhere if $DEVICES::TTY_OUTPUT was changed) 
$DEVICES::TTY_OUTPUT = \*STDOUT ;
sub TTY { return 1 } ;
$DEVICES::DEVS{'TTY'} = sub {
    my $BB = shift ;

    my $outdata = new WIRE() ;
    $outdata->posthook(sub {
        return unless $_[0] ;
        my $byte = $BB->get("DATA.bus")->power() ;
        my $dec = oct("0b$byte") ;
        my $char = chr($dec) ;
        print $DEVICES::TTY_OUTPUT "$char" ;
        $DEVICES::TTY_OUTPUT->flush() ;
    }) ;
    $BB->get("IO.adapter")->register(TTY(),
        $outdata,
        undef,
        "TTY",
    ) ;
} ;


# A simulation of a Read-Only Memory module. This is where the program to be run lives.
# It is backed by a file, and uses callback/hook on wires to perform the actions.
# A protection is in place against multiple calls in a single tick, as the STEPPER implementation
# is not perfect and can trigger some resets.
$DEVICES::ROM_FILE = "ROM.txt" ;
sub ROM { return 0 } ;
my @ROM = () ;
my $ROM_ADDR = 0 ;
my $in_ticks = 0 ;
my $out_inst = 0 ;
my $init = 0 ;
$DEVICES::DEVS{'ROM'} = sub {
    my $BB = shift ;

    # This file should be the output of a jcsasm program
    open(ROMF, "<$DEVICES::ROM_FILE") or croak("Can't open ROM file '$DEVICES::ROM_FILE': $!") ;
    while (<ROMF>){
        my $line = $_ ;
        chomp($line) ;
        $line =~ s/[^[:print:]]//g ; 
        next unless $line =~ /^([01]{8})\b/ ;
        my $inst = $1 ;
        push @ROM, $inst ;
    }

    my $outdata = new WIRE() ;
    $outdata->posthook(sub {
        return unless $_[0] ;
        my $qticks = $BB->get("CLK")->qticks() ;
        my $ticks = $BB->get("CLK")->ticks() ;
        my $step = $BB->get("STP")->step() ;
        my $inst = int($ticks / 24) ;
        # return if $out_inst == $inst ;
        my $addr = oct("0b" . $BB->get("DATA.bus")->power()) ;
        if ($addr == 0){
            if ($init){
                return ;
            }
            $init = 1 ;
        }

        $ROM_ADDR = $addr ;
        warn "out (write addr) addr:$ROM_ADDR inst:$inst step:$step ticks:$ticks qticks:$qticks " . ($qticks % 4) ;
        
        $out_inst = $inst ;
    }) ;
    my $indata = new WIRE() ;
    $indata->posthook(sub {
        return unless $_[0] ;
        my $ticks = $BB->get("CLK")->ticks() ;
        my $step = $BB->get("STP")->step() ;
        $BB->get("DATA.bus")->power($ROM[$ROM_ADDR]) ;
        # warn "in (read addr) addr:$ROM_ADDR step:$step ticks:$ticks" ;
    }) ;
    $BB->get("IO.adapter")->register(ROM(),
        $outdata,
        $indata,
        "ROM",
    ) ;
} ;