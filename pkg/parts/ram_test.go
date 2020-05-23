package parts

import (
	"fmt"
	"math/rand"
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

var nb_ram_tests int = 1024

func TestRAMInit(t *testing.T) {
	ba := g.NewBus()
	wsa := g.NewWire()
	bio := g.NewBus()
	ws := g.NewWire()
	we := g.NewWire()
	NewRAM(ba, wsa, bio, ws, we)
}

func TestRAMBasic(t *testing.T) {
	ba := g.NewBus()
	wsa := g.NewWire()
	bio := g.NewBus()
	ws := g.NewWire()
	we := g.NewWire()
	NewRAM(ba, wsa, bio, ws, we)

	// First, setup an address on the MAR input bus and let it in the MAR
	addr1 := 0b10101010
	ba.SetPower(addr1)
	wsa.SetPower(true)
	wsa.SetPower(false)

	// Then setup some data on the I/O bus and store it.
	data1 := 0b00011110
	bio.SetPower(data1)
	ws.SetPower(true)
	ws.SetPower(false)

	// Now if we turn on the e, we should get our data back on the bus.
	we.SetPower(true)
	tm.Is(t, bio.GetPower(), data1, "data1 is on the bus")
	we.SetPower(false)

	// Now, setup a different on the MAR input bus and let it in the MAR
	addr2 := 0b11101011
	ba.SetPower(addr2)
	wsa.SetPower(true)
	wsa.SetPower(false)

	// Then setup some data on the I/O bus and store it.
	data2 := 0b01111000
	bio.SetPower(data2)
	ws.SetPower(true)
	ws.SetPower(false)

	// Now if we turn on the e, we should get our data back on the bus.
	we.SetPower(true)
	tm.Is(t, bio.GetPower(), data2, "data2 is on the bus")
	we.SetPower(false)

	// Now, get back the data from the first address
	ba.SetPower(addr1)
	wsa.SetPower(true)
	wsa.SetPower(false)

	// Now if we tune on the e, we should get our data back on the bus.
	we.SetPower(true)
	tm.Is(t, bio.GetPower(), data1, "data1 is on the bus")
	we.SetPower(false)
}

func TestRAMMaker(t *testing.T) {
	ba := g.NewBus()
	wsa := g.NewWire()
	bio := g.NewBus()
	ws := g.NewWire()
	we := g.NewWire()
	RAM := NewRAM(ba, wsa, bio, ws, we)

	xs := make([]int, nb_ram_tests, nb_ram_tests)
	for j := 0; j < nb_ram_tests; j++ {
		x := rand.Intn(a.GetMaxByteValue())
		xs[j] = x
		addr := x
		data := a.GetMaxByteValue() - x
		testname := fmt.Sprintf("Value %d properly stored in RAM[%d]", data, addr)
		t.Run(testname, func(t *testing.T) {
			// Set addr on addr bus
			ba.SetPower(addr)
			wsa.SetPower(true)
			wsa.SetPower(false)
			// Then setup some data on the I/O bus and store it.
			bio.SetPower(data)
			ws.SetPower(true)
			ws.SetPower(false)
			tm.Is(t, RAM.GetCellPower(addr), data, testname)
		})
	}

	for _, x := range xs {
		addr := x
		data := a.GetMaxByteValue() - x
		testname := fmt.Sprintf("Value %d properly retreived from RAM[%d]", data, addr)
		t.Run(testname, func(t *testing.T) {
			ba.SetPower(addr)
			wsa.SetPower(true)
			wsa.SetPower(false)

			// Clear the IO bus before enabling.
			// In the final setup this will not be necessary as each instruction will start with a clean bus.
			bio.SetPower(0)

			// Now if we turn on the e, we should get our data back on the bus.
			we.SetPower(true)
			tm.Is(t, bio.GetPower(), data, testname)
			we.SetPower(false)
		})
	}
}

/*



sub make_ram_test {
    random = shift

    foreach t (@ts){
        addr = sprintf("%08b", t)
        ba.GetPower(addr)
        wsa.GetPower(1)
        wsa.GetPower(0)

        # Clear the IO bus before enabling.
        # In the final setup this will not be necessary as each instruction will start with a clean bus.
        bio.GetPower("00000000")

        # Now if we turn on the e, we should get our data back on the bus.
        we.GetPower(1)
        data = join('', scalar(reverse(addr)))
        is(bio.GetPower(), data)
        we.GetPower(0)
    }
}


*/
