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
    $outdata->prehook(sub {
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
$DEVICES::DEVS{'ROM'} = sub {
    my $BB = shift ;

    my @ROM = () ;
    my $ROM_ADDR = 0 ;

    # This file should be the output of a jcsasm program
    open(ROMF, "<$DEVICES::ROM_FILE") or croak("Can't open ROM file '$DEVICES::ROM_FILE': $!") ;
    @ROM = @{$BB->readINSTS(\*ROMF)} ;

    my $outdata = new WIRE() ;
    $outdata->prehook(sub {
        return unless $_[0] ;
        $ROM_ADDR = oct("0b" . $BB->get("DATA.bus")->power()) ;
        # warn "out (write addr) addr:$ROM_ADDR" ;       
    }) ;

    my $indata = new WIRE() ;
    $indata->prehook(sub {
        return unless $_[0] ;
        $BB->get("DATA.bus")->power($ROM[$ROM_ADDR]) ;
        # warn "in (read addr) addr:$ROM_ADDR data:$ROM[$ROM_ADDR]" ;
    }) ;
    
    $BB->get("IO.adapter")->register(ROM(),
        $outdata,
        $indata,
        "ROM",
    ) ;
} ;