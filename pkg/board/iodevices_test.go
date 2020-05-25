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
	TTYWriter = buffer

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
			buf := make([]byte, 4)
			rune, _, _ := buffer.ReadRune()
			BB.Log(buf)
			received := int(rune)
			tm.Is(t, received, tc.DATA, fmt.Sprintf("Data %d was grabbed from the bus by device %d", received, tc.IODEV))
		},
		func(tc ti.INSTTestCase) {
		},
	)
}

/*

sub make_tty_test {
    # Generate a random register
    my $rb = int rand(4) ;
    my $iaddr = sprintf("%08b", int rand(256)) ;
    my $data = sprintf("%08b", int rand(256)) ;

    # First, activate the device
    my $iinst = sprintf("011111%02b", $rb) ;
    $BB->setREG("R$rb", sprintf("%08b", DEVICES::TTY())) ;
    $BB->setRAM($iaddr, $iinst) ;
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;
    is($BB->get("IO.adapter")->active(DEVICES::TTY()), 1, "TTY is active") ;

    # Then, send data to the device
    my $iinst = sprintf("011110%02b", $rb) ;
    $BB->setREG("R$rb", $data) ;
    $BB->setRAM($iaddr, $iinst) ;
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;
    my $char = undef ;
    my $nb = sysread(\*READ, $char, 1) ;
    is($nb, 1, "One byte returned by sysread") ;
    is(ord($char), oct("0b$data"), "Byte written ($data) was received through the pipe") ;
}

*/
