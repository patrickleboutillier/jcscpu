package computer

import (
	"fmt"
	"math/rand"
	"testing"

	t8 "github.com/patrickleboutillier/jcscpu/internal/testarch"
	ti "github.com/patrickleboutillier/jcscpu/internal/testinst"
	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	b "github.com/patrickleboutillier/jcscpu/pkg/board"
)

var nb_tests_per_inst = 256

func TestIOInstruction(t *testing.T) {
	C := newVanillaComputer(t8.GetArchBits(), -1)

	received := -1
	sent := -1
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0111,
		func(tc ti.INSTTestCase) {
			if !C.IOAdapter.IsRegistered(tc.IODEV) {
				C.IOAdapter.Register(C.BB, tc.IODEV, fmt.Sprintf("dummy-%d", tc.IODEV),
					func() {
						// Simulate data being placed on the bus by the device
						sent = rand.Intn(C.BB.GetBus("DATA.bus").GetMaxPower())
						C.BB.GetBus("DATA.bus").SetPower(sent)
					},
					func() {
						// Data was made available to our device on the DATA.bus.
						// Let's grab it and put it in a local var.
						received = C.BB.GetBus("DATA.bus").GetPower()
					},
				)
			}
		},
		func(tc ti.INSTTestCase) {
			// First, activate the device (11)
			rb := tc.INST % 4
			tc.INST = 0b01111100 + rb
			C.BB.SetReg(tc.RB, tc.IODEV)
			doInst(C.BB)(tc)
			tm.Is(t, C.IOAdapter.IsActive(tc.IODEV), true, fmt.Sprintf("Adapter %d is active", tc.IODEV))

			// Then, send data to the device (10)
			tc.INST = 0b01111000 + rb
			C.BB.SetReg(tc.RB, tc.DATA)
			doInst(C.BB)(tc)
			tm.Is(t, received, tc.DATA, fmt.Sprintf("Data %d was grabbed from the bus by device %d", received, tc.IODEV))

			// Then, ask for data from the device (00)
			tc.INST = 0b01110000 + rb
			doInst(C.BB)(tc)
			tm.Is(t, C.BB.GetReg(tc.RB).GetPower(), sent, fmt.Sprintf("Data %d was sent to the bus by device %d", sent, tc.IODEV))
		},
		func(tc ti.INSTTestCase) {
		},
	)
}

func doInst(BB *b.Breadboard) ti.INSTDo {
	return func(tc ti.INSTTestCase) {
		BB.SetRAM(tc.IADDR, tc.INST)
		BB.SetRAM(tc.IDADDR, tc.IDATA)
		BB.SetReg("IAR", tc.IADDR)
		BB.Inst()
	}
}
