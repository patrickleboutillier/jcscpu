package DEVICES ;

use strict ;
use IO::Handle ;


$DEVICES::TTY_OUTPUT = \*STDOUT ;


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
    $BB->get("IO.adapter")->register(0,
        $outdata,
        undef,
        "TTY",
    ) ;
} ;