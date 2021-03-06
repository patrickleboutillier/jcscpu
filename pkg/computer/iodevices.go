package computer

import (
	"fmt"
	"math/rand"
	"os"
)

func init() {
	iodevHandlers["TTY"] = TTYIODevice
	iodevHandlers["RNG"] = RNGIODevice
	iodevHandlers["ROM"] = ROMIODevice
	iodevHandlers["ROMSize"] = ROMSizeIODevice
}

// TTY: Device 0
// An output-only TTY implementation, just grabs the ASCII code on the bus and prints
// the corresponding character to TTYWriter
func TTYIODevice(C *Computer) {
	C.TTYWriter = os.Stdout
	C.IOAdapter.Register(C.BB, 0, "TTY",
		nil,
		func() {
			byte := C.BB.GetBus("DATA.bus").GetPower()
			rune := rune(byte)
			fmt.Fprintf(C.TTYWriter, "%c", rune)
		},
	)
}

// RNG: Device 1
// A Random Number Generator. Places a random byte on the data bus, and saves in in RNGLast for testing purposes
func RNGIODevice(C *Computer) {
	C.IOAdapter.Register(C.BB, 1, "RNG",
		func() {
			bus := C.BB.GetBus("DATA.bus")
			C.RNGLast = rand.Intn(1 << bus.GetSize())
			bus.SetPower(C.RNGLast)
		},
		nil,
	)
}

// ROM: Device 2
// A ROM module,
func ROMIODevice(C *Computer) {
	C.IOAdapter.Register(C.BB, 2, "ROM",
		func() {
			C.BB.GetBus("DATA.bus").SetPower(C.ROM[C.ROMAddrLast])
		},
		func() {
			C.ROMAddrLast = C.BB.GetBus("DATA.bus").GetPower()
		},
	)
}

// ROMSize: Device 3
// The size of the ROM module
func ROMSizeIODevice(C *Computer) {
	C.IOAdapter.Register(C.BB, 3, "ROMSize",
		func() {
			C.BB.GetBus("DATA.bus").SetPower(len(C.ROM))
		},
		func() {
		},
	)
}
