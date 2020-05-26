package board

import (
	"fmt"
	"math/rand"
	"os"
)

func init() {
	iodevHandlers["TTY"] = TTYIODevice
	iodevHandlers["RNG"] = RNGIODevice
}

// TTY: Device 0
// An output-only TTY implementation, just grabs the ASCII code on the bus and prints
// the corresponding character to TTYWriter
func TTYIODevice(BB *Breadboard) {
	BB.TTYWriter = os.Stdout
	BB.IOAdapter.Register(BB, 0, "TTY",
		nil,
		func() {
			byte := BB.GetBus("DATA.bus").GetPower()
			rune := rune(byte)
			fmt.Fprintf(BB.TTYWriter, "%c", rune)
		},
	)
}

// RNG: Device 1
// A Random Number Generator. Places a random byte on the data bus, and saves in in RNGLast for testing purposes
func RNGIODevice(BB *Breadboard) {
	BB.IOAdapter.Register(BB, 1, "RNG",
		func() {
			bus := BB.GetBus("DATA.bus")
			BB.RNGLast = rand.Intn(1 << bus.GetSize())
			bus.SetPower(BB.RNGLast)
		},
		nil,
	)
}

func ROMIODevice(BB *Breadboard) {
	BB.IOAdapter.Register(BB, 2, "ROM",
		func() {
			BB.GetBus("DATA.bus").SetPower(BB.ROM[BB.ROMAddrLast])
		},
		func() {
			BB.ROMAddrLast = BB.GetBus("DATA.bus").GetPower()
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
