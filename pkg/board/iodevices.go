package board

import (
	"fmt"
	"io"
	"os"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

func init() {
	iodevHandlers["TTY"] = TTYIODevice
}

// TTY: Device 0
// An output-only TTY implementation, just grabs the ASCII code on the bus and prints
// the corresponding character to TTYWriter
var TTYWriter io.Writer = os.Stdout

func TTYIODevice(BB *Breadboard) {
	BB.IOAdapter.Register(BB, 0, "TTY",
		nil,
		func(bus *g.Bus) {
			byte := BB.GetBus("DATA.bus").GetPower()
			rune := rune(byte)
			fmt.Fprintf(TTYWriter, "%c", rune)
		},
	)
}

/*
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
        return unless (($BB->get("CLK")->ticks() % 6) == 4) ;
        $BB->get("DATA.bus")->power($ROM[$ROM_ADDR]) ;
        # warn "in (read addr) addr:$ROM_ADDR data:$ROM[$ROM_ADDR]" ;
    }) ;

    $BB->get("IO.adapter")->register(ROM(),
        $outdata,
        $indata,
        "ROM",
    ) ;
} ;


# A Random Number Generator. Places a random byte on the data bus.
$DEVICES::RNG_LAST = undef ;
sub RNG { return 2 } ;
$DEVICES::DEVS{'RNG'} = sub {
    my $BB = shift ;

    my $indata = new WIRE() ;
    $indata->prehook(sub {
        return unless $_[0] ;
        return unless (($BB->get("CLK")->ticks() % 6) == 4) ;
        $DEVICES::RNG_LAST = sprintf("%08b", int(rand(256))) ;
        # warn "RNG spewed $DEVICES::RNG_LAST" ;
        $BB->get("DATA.bus")->power($DEVICES::RNG_LAST) ;
    }) ;
    $BB->get("IO.adapter")->register(RNG(),
        undef,
        $indata,
        "RNG",
    ) ;
} ;
*/
