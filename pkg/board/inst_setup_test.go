package board

import (
	"fmt"
	"math/rand"
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
)

func TestInstProc(t *testing.T) {
	BB := NewInstProcBreadboard()

	// Place some fake instructions in RAM
	BB.GetBus("DATA.bus").SetPower(0b00000100)
	BB.GetWire("RAM.MAR.s").SetPower(true)
	BB.GetWire("RAM.MAR.s").SetPower(false)
	BB.GetBus("DATA.bus").SetPower(0b10101010)
	BB.GetWire("RAM.s").SetPower(true)
	BB.GetWire("RAM.s").SetPower(false)
	tm.Is(t, BB.RAM.GetCellPower(0b00000100), 0b10101010, "RAM set correctly at 00000100")
	BB.GetBus("DATA.bus").SetPower(0b00000101)
	BB.GetWire("RAM.MAR.s").SetPower(true)
	BB.GetWire("RAM.MAR.s").SetPower(false)
	BB.GetBus("DATA.bus").SetPower(0b01010101)
	BB.GetWire("RAM.s").SetPower(true)
	BB.GetWire("RAM.s").SetPower(false)
	tm.Is(t, BB.RAM.GetCellPower(0b00000101), 0b01010101, "RAM set correctly at 00000101")
	BB.GetBus("DATA.bus").SetPower(0b00000110)
	BB.GetWire("RAM.MAR.s").SetPower(true)
	BB.GetWire("RAM.MAR.s").SetPower(false)
	BB.GetBus("DATA.bus").SetPower(0b11110000)
	BB.GetWire("RAM.s").SetPower(true)
	BB.GetWire("RAM.s").SetPower(false)
	tm.Is(t, BB.RAM.GetCellPower(0b00000110), 0b11110000, "RAM set correctly at 00000110")

	// Set the IAR to our start address
	BB.GetBus("DATA.bus").SetPower(0b00000100)
	BB.GetWire("IAR.s").SetPower(true)
	BB.GetWire("IAR.s").SetPower(false)
	tm.Is(t, BB.GetReg("IAR").GetPower(), 0b00000100, "IAR set correctly")

	BB.Tick()
	tm.Is(t, BB.GetReg("RAM.MAR").GetPower(), 0b00000100, "RAM.MAR contains previous contents of IAR")
	tm.Is(t, BB.GetReg("ACC").GetPower(), 0b00000101, "ACC contains previous contents of IAR + 1")
	BB.Tick()
	tm.Is(t, BB.GetReg("IR").GetPower(), 0b10101010, "IR contains our first fake instruction")
	tm.Is(t, BB.GetReg("ACC").GetPower(), 0b00000101, "ACC still contains previous contents of IAR + 1")
	BB.Tick()
	tm.Is(t, BB.GetReg("IAR").GetPower(), 0b00000101, "IAR contains the address our our next instruction")
}

func TestInstImplInstDec(t *testing.T) {
	BB := NewInstImplBreadboard()

	// What we need to test here is that:
	// 1- Bits 0-3 of the IR setup the proper instruction in the instruction decoder.

	for j := 0; j < 32; j++ {
		x := j
		if j > 15 {
			x = rand.Intn(8)
		}

		var res int
		// x >= 8 is an ALU instruction and does not use INST.bus
		if x >= 8 {
			res = 0
		} else {
			res = 1 << (7 - x)
		}
		p := x << 4
		testname := fmt.Sprintf("IR:%dXXXX -> INST.bus:%d", x, res)
		t.Run(testname, func(t *testing.T) {
			BB.GetBus("DATA.bus").SetPower(p)
			BB.GetWire("IR.s").SetPower(true)
			BB.GetWire("IR.s").SetPower(false)
			tm.Is(t, BB.GetReg("IR").GetPower(), p, "IR properly set to x")

			tm.Is(t, BB.GetBus("INST.bus").GetPower(), res, testname)
		})
	}
}

func TestInstImplRegDec(t *testing.T) {
	BB := NewInstImplBreadboard()

	// What we need to test here is that:
	// 2- Bits 4-7 of the IR setup the proper register (s) to be enabled or set

	rmap := []string{"R0", "R1", "R2", "R3"}
	for j := 0; j < 32; j++ {
		x := j
		if j > 15 {
			x = rand.Intn(8)
		}

		b45 := x / 4
		b67 := x % 4
		testname := "REGA/B.e.s properly set"
		t.Run(testname, func(t *testing.T) {
			BB.GetBus("DATA.bus").SetPower(x)
			BB.GetWire("IR.s").SetPower(true)
			BB.GetWire("IR.s").SetPower(false)
			tm.Is(t, BB.GetReg("IR").GetPower(), x, "IR properly set to x")

			BB.GetWire("CLK.clke").SetPower(true)
			BB.GetWire("REGA.e").SetPower(true)
			BB.GetWire("REGB.e").SetPower(true)
			for i, r := range rmap {
				tm.Is(t, BB.GetWire(fmt.Sprintf("%s.e", r)).GetPower(), ((i == b45) || (i == b67)), testname)
			}
			BB.GetWire("CLK.clke").SetPower(false)
			BB.GetWire("REGA.e").SetPower(false)
			BB.GetWire("REGB.e").SetPower(false)

			BB.GetWire("CLK.clks").SetPower(true)
			BB.GetWire("REGB.s").SetPower(true)
			for i, r := range rmap {
				tm.Is(t, BB.GetWire(fmt.Sprintf("%s.s", r)).GetPower(), (i == b67), testname)
			}
			BB.GetWire("CLK.clks").SetPower(false)
			BB.GetWire("REGB.s").SetPower(false)
		})
	}
}
