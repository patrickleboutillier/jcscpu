package board

import (
	"bytes"
	"fmt"
	"testing"

	ti "github.com/patrickleboutillier/jcscpu/internal/testinst"
	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
)

var nb_tests_per_ioinst = 256

func TestTTYDevice(t *testing.T) {
	BB := NewBreadboard()
	buffer := new(bytes.Buffer)
	BB.TTYWriter = buffer

	ti.RunRandomINSTTests(t, nb_tests_per_ioinst, 0b0111,
		func(tc ti.INSTTestCase) {
		},
		func(tc ti.INSTTestCase) {
			// First, activate the device (11)
			rb := tc.INST % 4
			tc.INST = 0b01111100 + rb
			tc.IODEV = 0
			BB.SetReg(tc.RB, tc.IODEV)
			doInst(BB)(tc)
			tm.Is(t, BB.IOAdapter.IsActive(tc.IODEV), true, fmt.Sprintf("Adapter %d is active", tc.IODEV))

			// Then, send data to the device (10)
			tc.INST = 0b01111000 + rb
			BB.SetReg(tc.RB, tc.DATA)
			doInst(BB)(tc)

			// We compare using runes, because the binary sequence in tc.DATA can be an invalid
			// UTF-8 sequence
			var expected rune
			tbuf := fmt.Sprintf("%c", rune(tc.DATA))
			fmt.Sscanf(tbuf, "%c", &expected)

			var received rune
			fmt.Fscanf(buffer, "%c", &received)

			tm.Is(t, received, expected, fmt.Sprintf("Rune %d (%c) was grabbed from the bus by device %d", received, received, tc.IODEV))
		},
		func(tc ti.INSTTestCase) {
		},
	)
}

func TestRNGDevice(t *testing.T) {
	BB := NewBreadboard()

	ti.RunRandomINSTTests(t, nb_tests_per_ioinst, 0b0111,
		func(tc ti.INSTTestCase) {
		},
		func(tc ti.INSTTestCase) {
			// First, activate the device (11)
			rb := tc.INST % 4
			tc.INST = 0b01111100 + rb
			tc.IODEV = 1
			BB.SetReg(tc.RB, tc.IODEV)
			doInst(BB)(tc)
			tm.Is(t, BB.IOAdapter.IsActive(tc.IODEV), true, fmt.Sprintf("Adapter %d is active", tc.IODEV))

			// Then, get data from the device (00)
			tc.INST = 0b01110000 + rb
			doInst(BB)(tc)
			tm.Is(t, BB.GetReg(tc.RB).GetPower(), BB.RNGLast, fmt.Sprintf("Byte received equals %d", BB.RNGLast))
		},
		func(tc ti.INSTTestCase) {
		},
	)
}
