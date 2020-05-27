package board

import (
	"fmt"
	"math/rand"
	"os"
)

func init() {
	iodevHandlers["TTY"] = TTYIODevice
	iodevHandlers["RNG"] = RNGIODevice
	iodevHandlers["ROM"] = ROMIODevice
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

// ROM: Device 2
// A ROM module,
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

// ROMSize: Device 3
// The size of the ROM module
func ROMSizeIODevice(BB *Breadboard) {
	BB.IOAdapter.Register(BB, 3, "ROMSize",
		func() {
			BB.GetBus("DATA.bus").SetPower(len(BB.ROM))
		},
		func() {
		},
	)
}
