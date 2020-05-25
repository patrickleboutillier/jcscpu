package board

import (
	"fmt"
	"math/rand"
	"testing"

	ta "github.com/patrickleboutillier/jcscpu/internal/testalu"
	ti "github.com/patrickleboutillier/jcscpu/internal/testinst"
	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

var nb_tests_per_inst = 256

func TestALUInstuctionsBasic(t *testing.T) {
	BB := NewInstBreadboard("ALU")

	// Testing of ALU instructions.
	// Add contents of R1 and R2, result in R2
	BB.SetReg("R1", 0b01100100) // 100
	BB.SetReg("R2", 0b00110010) // 50
	BB.SetRAM(0b00001000, 0b10000110)
	BB.SetReg("IAR", 0b00001000)
	BB.Inst()
	tm.Is(t, BB.GetReg("R2").GetPower(), 0b10010110, "100 + 50 = 150") // 150

	// Add contents of R1 and R1, result in R1
	BB.SetReg("R1", 0b01100100) // 100
	BB.SetRAM(0b00001000, 0b10000101)
	BB.SetReg("IAR", 0b00001000)
	BB.Inst()
	tm.Is(t, BB.GetReg("R1").GetPower(), 0b11001000, "100 + 100 = 200") // 200

	// Not contents of R0 back in R0
	BB.SetReg("R0", 0b10101010)
	BB.SetRAM(0b00001001, 0b10110000)
	BB.SetReg("IAR", 0b00001001)
	BB.Inst()
	xtra := a.GetMaxByteValue() - 255
	tm.Is(t, BB.GetReg("R0").GetPower(), xtra+0b01010101, "NOT of 10101010 = 01010101")

	// Bug with TMP.e
	BB.SetReg("R3", 0b00111101)
	BB.SetRAM(0b00001010, 0b11001111)
	BB.SetReg("IAR", 0b00001010)
	BB.SetReg("TMP", 0b00010111)
	BB.GetWire("BUS1.bit1").SetPower(false) // Simulate a bit1 reset after inst1 of the stepper.
	BB.Inst()
	tm.Is(t, BB.GetReg("R3").GetPower(), 0b00111101, "AND of 00111101 with itself = 00111101")
}

func TestALUInstructions(t *testing.T) {
	BB := NewInstBreadboard("ALU")
	LogWith(func(msg string) {
		t.Log(msg)
	})

	op := rand.Intn(8)
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 8+op,
		func(tc ti.INSTTestCase) {
			BB.SetReg(tc.RA, tc.DATA)
			BB.SetReg(tc.RB, tc.DATA2)

			// Set CO, let it in the FLAGS reg and thne clear the FLAGS.in
			BB.GetBus("FLAGS.in").SetPower(0)
			BB.GetBus("FLAGS.in").GetWire(0).SetPower(tc.CI)
			BB.GetWire("FLAGS.s").SetPower(true)
			BB.GetWire("FLAGS.s").SetPower(false)
			BB.GetBus("FLAGS.in").SetPower(0)
		},
		doInst(BB),
		func(tc ti.INSTTestCase) {
			if tc.RA == tc.RB {
				// In this case, RA gets overridden with DATA2, so the DATA becomes DATA2
				tc.DATA = tc.DATA2
			}

			atc := ta.NewALUTestCase(tc.DATA, tc.DATA2, tc.CI, op)
			ta.RunALUTest(t, atc, func(res ta.ALUTestCase) ta.ALUTestCase {
				// Initialize fields of tc with the of tc.RB + FLAGS
				if op < 7 {
					res.C = BB.GetReg(tc.RB).GetPower()
				}
				res.CO = BB.GetBus("FLAGS.bus").GetWire(0).GetPower()
				res.ALO = BB.GetBus("FLAGS.bus").GetWire(1).GetPower()
				res.EQO = BB.GetBus("FLAGS.bus").GetWire(2).GetPower()
				res.Z = BB.GetBus("FLAGS.bus").GetWire(3).GetPower()
				return res
			}, func(res ta.ALUTestCase) ta.ALUTestCase {
				return ta.Cmp(ta.GetALUExpectedResult(res))
			})

			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+1, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+1"))
		},
	)
}

func TestLDInstruction(t *testing.T) {
	BB := NewInstBreadboard("LDST")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0000,
		func(tc ti.INSTTestCase) {
			BB.SetRAM(tc.ADDR, tc.DATA)
			BB.SetReg(tc.RA, tc.ADDR)
		},
		doInst(BB),
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg(tc.RB).GetPower(), tc.DATA, fmt.Sprintf("%d copied from RAM@%d (via %s) to %s", tc.DATA, tc.ADDR, tc.RA, tc.RB))
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+1, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+1"))
		},
	)
}

func TestSTInstruction(t *testing.T) {
	BB := NewInstBreadboard("LDST")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0001,
		func(tc ti.INSTTestCase) {
			BB.SetReg(tc.RB, tc.DATA)
			BB.SetReg(tc.RA, tc.ADDR)
		},
		doInst(BB),
		func(tc ti.INSTTestCase) {
			data := tc.DATA
			if tc.RA == tc.RB {
				// In this case, RB gets overridden with the address, so the data becomes the address
				data = tc.ADDR
			}
			tm.Is(t, BB.RAM.GetCellPower(tc.ADDR), data, fmt.Sprintf("%d stored from %s to RAM@%d (via %s)", data, tc.RB, tc.ADDR, tc.RA))
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+1, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+1"))
		},
	)
}

func TestDATAInstruction(t *testing.T) {
	BB := NewInstBreadboard("DATA")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0010,
		func(tc ti.INSTTestCase) {
		},
		doInst(BB),
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg(tc.RB).GetPower(), tc.IDATA, fmt.Sprintf("%d copied from program (RAM@%d) to %s", tc.IDATA, tc.IDADDR, tc.RB))
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+2, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+2"))
		},
	)
}

func TestJMPRInstruction(t *testing.T) {
	BB := NewInstBreadboard("JUMP")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0011,
		func(tc ti.INSTTestCase) {
			BB.SetReg(tc.RB, tc.ADDR)
		},
		doInst(BB),
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.ADDR, fmt.Sprintf("IAR is now %d", tc.ADDR))
		},
	)
}

func TestJMPInstruction(t *testing.T) {
	BB := NewInstBreadboard("JUMP")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0100,
		func(tc ti.INSTTestCase) {
		},
		doInst(BB),
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IDATA, fmt.Sprintf("IAR is now %d", tc.IDATA))
		},
	)
}

func TestJMPIFInstruction(t *testing.T) {
	BB := NewInstBreadboard("JUMP")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0101,
		func(tc ti.INSTTestCase) {
			BB.GetBus("FLAGS.in").SetPower(tc.FLAGS << 4)
			BB.GetWire("FLAGS.s").SetPower(true)
			BB.GetWire("FLAGS.s").SetPower(false)
			// Reset bus once flags are set in the reg
			BB.GetBus("FLAGS.in").SetPower(0)
		},
		doInst(BB),
		func(tc ti.INSTTestCase) {
			// Decide if we should have jumped or not. If any of the bits of FLAGS and IFLAGS are both on, we jump
			jump := (tc.FLAGS & tc.IFLAGS) > 0
			if jump {
				tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IDATA, fmt.Sprintf("IAR is now %d", tc.IDATA))
			} else {
				tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+2, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+2"))
			}
		},
	)
}

func TestCLFInstruction(t *testing.T) {
	BB := NewInstBreadboard("CLF")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0110,
		func(tc ti.INSTTestCase) {
			// Inject the flags in the FLAG reg input
			BB.GetBus("FLAGS.in").SetPower(tc.FLAGS << 4)
			BB.GetWire("FLAGS.s").SetPower(true)
			BB.GetWire("FLAGS.s").SetPower(false)
			// Reset bus once flags are set in the reg
			BB.GetBus("FLAGS.in").SetPower(0)
		},
		func(tc ti.INSTTestCase) {
			// Make sure instruction is a CLF (01100000)
			tc.INST = 0b01100000
			doInst(BB)(tc)
		},
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg("FLAGS").GetPower(), 0b00000000, "FLAGS reset")
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+1, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+1"))
		},
	)
}

func TestIOInstruction(t *testing.T) {
	BB := NewInstBreadboard("IO")

	received := -1
	sent := -1
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0110,
		func(tc ti.INSTTestCase) {
			if !BB.IOAdapter.IsRegistered(tc.IODEV) {
				BB.IOAdapter.Register(BB, tc.IODEV, fmt.Sprintf("dummy-%d", tc.IODEV),
					func(bus *g.Bus) {
						// Simulate data being placed on the bus by the device
						sent = rand.Intn(a.GetMaxByteValue())
						bus.SetPower(sent)
					},
					func(bus *g.Bus) {
						// Data was made available to our device on the DATA.bus.
						// Let's grab it and put it in a local var.
						received = bus.GetPower()
					},
				)
			}
		},
		func(tc ti.INSTTestCase) {
			// First, activate the device (11)
			rb := tc.INST % 4
			tc.INST = 0b01111100 + rb
			BB.SetReg(tc.RB, tc.IODEV)
			doInst(BB)(tc)
			tm.Is(t, BB.IOAdapter.IsActive(tc.IODEV), true, fmt.Sprintf("Adapter %d is active", tc.IODEV))

			// Then, send data to the device (10)
			tc.INST = 0b01111000 + rb
			BB.SetReg(tc.RB, tc.DATA)
			doInst(BB)(tc)
			tm.Is(t, received, tc.DATA, fmt.Sprintf("Data %d was grabbed from the bus by device %d", received, tc.IODEV))

			// Then, ask for data from the device (00)
			tc.INST = 0b01110000 + rb
			doInst(BB)(tc)
			tm.Is(t, BB.GetReg(tc.RB).GetPower(), sent, fmt.Sprintf("Data %d was grabbed from the bus by device %d", received, tc.IODEV))
		},
		func(tc ti.INSTTestCase) {
		},
	)
}

func doInst(BB *Breadboard) ti.INSTDo {
	return func(tc ti.INSTTestCase) {
		BB.SetRAM(tc.IADDR, tc.INST)
		BB.SetRAM(tc.IDADDR, tc.IDATA)
		BB.SetReg("IAR", tc.IADDR)
		BB.Inst()
	}
}

/*
sub make_io_test {


    # First, activate the device (11)
    my $iinst = sprintf("011111%02b", $rb) ;
    #warn "inst: $iinst" ;
    $BB->setREG("R$rb", sprintf("%08b", $n)) ;
    $BB->setRAM($iaddr, $iinst) ;
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;
    is($BB->get("IO.adapter")->active($n), 1, "Adapter is active") ;
    #warn $BB->show() ;

    # Then, send data to the device (10)
    my $iinst = sprintf("011110%02b", $rb) ;
    #warn "inst: $iinst, data=$data" ;
    $BB->setREG("R$rb", $data) ;
    $BB->setRAM($iaddr, $iinst) ;
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;
    is($outpower, $data, "Data $data is was grabbed from the bus by device $n") ;
    #warn $BB->show() ;

    # Then, ask for data from the device (00)
    my $iinst = sprintf("011100%02b", $rb) ;
    # warn "inst: $iinst" ;
    $BB->setRAM($iaddr, $iinst) ;
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;
    # warn $BB->show() ;

    is($BB->get("R$rb")->power(), $gendata, "Data $data is was grabbed from the bus by device $n") ;
    #warn $BB->show() ;
}
*/
