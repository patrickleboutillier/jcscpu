package computer

import (
	"bytes"
	"fmt"
	"testing"

	t8 "github.com/patrickleboutillier/jcscpu/internal/testarch"
	ti "github.com/patrickleboutillier/jcscpu/internal/testinst"
	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
)

var nb_tests_per_ioinst = 256

func TestTTYDevice(t *testing.T) {
	C := NewComputer(t8.GetArchBits(), -1)
	buffer := new(bytes.Buffer)
	C.TTYWriter = buffer

	ti.RunRandomINSTTests(t, nb_tests_per_ioinst, 0b0111,
		func(tc ti.INSTTestCase) {
		},
		func(tc ti.INSTTestCase) {
			// First, activate the device (11)
			rb := tc.INST % 4
			tc.INST = 0b01111100 + rb
			tc.IODEV = 0
			C.BB.SetReg(tc.RB, tc.IODEV)
			doInst(C.BB)(tc)
			tm.Is(t, C.IOAdapter.IsActive(tc.IODEV), true, fmt.Sprintf("Adapter %d is active", tc.IODEV))

			// Then, send data to the device (10)
			tc.INST = 0b01111000 + rb
			C.BB.SetReg(tc.RB, tc.DATA)
			doInst(C.BB)(tc)

			// We compare using runes, because the binary sequence in tc.DATA can be an invalid
			// UTF-8 sequence
			var expected rune
			tbuf := fmt.Sprintf("%c", rune(tc.DATA))
			fmt.Sscanf(tbuf, "%c", &expected)

			var received rune
			fmt.Fscanf(buffer, "%c", &received)

			tm.Is(t, received, expected, fmt.Sprintf("Rune %d (%c) was graC.BBed from the bus by device %d", received, received, tc.IODEV))
		},
		func(tc ti.INSTTestCase) {
		},
	)
}

func TestRNGDevice(t *testing.T) {
	C := NewComputer(t8.GetArchBits(), -1)

	ti.RunRandomINSTTests(t, nb_tests_per_ioinst, 0b0111,
		func(tc ti.INSTTestCase) {
		},
		func(tc ti.INSTTestCase) {
			// First, activate the device (11)
			rb := tc.INST % 4
			tc.INST = 0b01111100 + rb
			tc.IODEV = 1
			C.BB.SetReg(tc.RB, tc.IODEV)
			doInst(C.BB)(tc)
			tm.Is(t, C.IOAdapter.IsActive(tc.IODEV), true, fmt.Sprintf("Adapter %d is active", tc.IODEV))

			// Then, get data from the device (00)
			tc.INST = 0b01110000 + rb
			doInst(C.BB)(tc)
			tm.Is(t, C.BB.GetReg(tc.RB).GetPower(), C.RNGLast, fmt.Sprintf("Byte received equals %d", C.RNGLast))
		},
		func(tc ti.INSTTestCase) {
		},
	)
}
