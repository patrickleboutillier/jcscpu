package board

import (
	"fmt"
	"math/rand"
	"testing"

	ta "github.com/patrickleboutillier/jcscpu/internal/testalu"
	t8 "github.com/patrickleboutillier/jcscpu/internal/testarch"
	ti "github.com/patrickleboutillier/jcscpu/internal/testinst"
	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
)

var nb_tests_per_inst = 256

func TestALUInstuctionsBasic(t *testing.T) {
	BB := newInstBreadboard(t8.GetArchBits(), "ALU")

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
	xtra := BB.GetBus("DATA.bus").GetMaxPower() - 255
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
	BB := newInstBreadboard(t8.GetArchBits(), "ALU")
	BB.LogWith(func(msg string) {
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
	BB := newInstBreadboard(t8.GetArchBits(), "LDST")
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
	BB := newInstBreadboard(t8.GetArchBits(), "LDST")
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
	BB := newInstBreadboard(t8.GetArchBits(), "DATA")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0010,
		func(tc ti.INSTTestCase) {
		},
		func(tc ti.INSTTestCase) {
			// Make sure instruction is a DATA (001000XX)
			tc.INST = 0b11110011 & tc.INST
			doInst(BB)(tc)
		},
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg(tc.RB).GetPower(), tc.IDATA, fmt.Sprintf("%d copied from program (RAM@%d) to %s", tc.IDATA, tc.IDADDR, tc.RB))
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+2, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+2"))
		},
	)
}

func TestPTRInstruction(t *testing.T) {
	BB := newInstBreadboard(t8.GetArchBits(), "DATA")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0010,
		func(tc ti.INSTTestCase) {
		},
		func(tc ti.INSTTestCase) {
			// Make sure instruction is a PTR (001001XX)
			tc.INST = 0b00100100 // (0b11110011 & tc.INST) + 4
			doInst(BB)(tc)
		},
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg("PTR").GetPower(), tc.IDATA, fmt.Sprintf("%d copied to PTR", tc.IDATA))
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+2, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+2"))
		},
	)
}

func TestPTRLDInstruction(t *testing.T) {
	BB := newInstBreadboard(t8.GetArchBits(), "DATA")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0010,
		func(tc ti.INSTTestCase) {
			BB.SetRAM(tc.ADDR, tc.DATA)
			BB.SetReg("PTR", tc.ADDR)
		},
		func(tc ti.INSTTestCase) {
			// Make sure instruction is a MLD (001010XX)
			tc.INST = (0b11110011 & tc.INST) + 8
			doInst(BB)(tc)
		},
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg(tc.RB).GetPower(), tc.DATA, fmt.Sprintf("%d loaded from RAM@PTR to %s", tc.DATA, tc.RB))
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+1, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+1"))
		},
	)
}

func TestPTRSTInstruction(t *testing.T) {
	BB := newInstBreadboard(t8.GetArchBits(), "DATA")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0010,
		func(tc ti.INSTTestCase) {
			BB.SetReg(tc.RB, tc.DATA)
			BB.SetReg("PTR", tc.ADDR)
		},
		func(tc ti.INSTTestCase) {
			// Make sure instruction is a MST (001011XX)
			tc.INST = (0b11110011 & tc.INST) + 12
			doInst(BB)(tc)
		},
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.RAM.GetCellPower(tc.ADDR), tc.DATA, fmt.Sprintf("%d stored to RAM@PTR from %s", tc.DATA, tc.RB))
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+1, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+1"))
		},
	)
}

func TestJMPRInstruction(t *testing.T) {
	BB := newInstBreadboard(t8.GetArchBits(), "JUMP")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0011,
		func(tc ti.INSTTestCase) {
			BB.SetReg(tc.RB, tc.ADDR)
		},
		func(tc ti.INSTTestCase) {
			// Make sure instruction is a JMPR (001100XX)
			tc.INST = 0b11110011 & tc.INST
			doInst(BB)(tc)
		},
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.ADDR, fmt.Sprintf("IAR is now %d", tc.ADDR))
		},
	)
}

func TestPTRRInstruction(t *testing.T) {
	BB := newInstBreadboard(t8.GetArchBits(), "JUMP")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0011,
		func(tc ti.INSTTestCase) {
			BB.SetReg(tc.RB, tc.ADDR)
		},
		func(tc ti.INSTTestCase) {
			// Make sure instruction is a PTRR (001101XX)
			tc.INST = (0b11110011 & tc.INST) + 4
			doInst(BB)(tc)
		},
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg("PTR").GetPower(), tc.ADDR, fmt.Sprintf("PTR is now %d", tc.ADDR))
		},
	)
}

func TestJMPInstruction(t *testing.T) {
	BB := newInstBreadboard(t8.GetArchBits(), "JUMP")
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
	BB := newInstBreadboard(t8.GetArchBits(), "JUMP")
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
	BB := newInstBreadboard(t8.GetArchBits(), "CLF")
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

func doInst(BB *Breadboard) ti.INSTDo {
	return func(tc ti.INSTTestCase) {
		BB.SetRAM(tc.IADDR, tc.INST)
		BB.SetRAM(tc.IDADDR, tc.IDATA)
		BB.SetReg("IAR", tc.IADDR)
		BB.Inst()
	}
}
