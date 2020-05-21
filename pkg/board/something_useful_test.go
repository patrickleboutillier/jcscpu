package board

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
)

func TestSomethingUseful(t *testing.T) {
	BB := NewVanillaBreadboard()

	tm.Is(t, 0b00010100, 20, "00010100=20")
	tm.Is(t, 0b00010110, 22, "00010110=22")
	tm.Is(t, 0b00101010, 42, "00101010=42")

	// First time, manually
	reset(t, BB)
	cycle1(t, BB)
	cycle2(t, BB)
	cycle3(t, BB)

	// Second time, manually
	reset(t, BB)
	cycle1(t, BB)
	cycle2(t, BB)
	cycle3(t, BB)

	// Third time, using the stepper (manually)
	reset(t, BB)
	BB.GetBus("STP.bus").GetWire(0).AddPrehook(func(v bool) {
		if v {
			cycle1(t, BB)
		}
	})
	BB.GetBus("STP.bus").GetWire(1).AddPrehook(func(v bool) {
		if v {
			cycle2(t, BB)
		}
	})
	BB.GetBus("STP.bus").GetWire(2).AddPrehook(func(v bool) {
		if v {
			cycle3(t, BB)
		}
	})
	BB.GetBus("STP.bus").GetWire(3).AddPrehook(func(v bool) {
		if v {
			tm.Is(t, BB.STP.GetStep(), 4, "Step 4 does nothing!")
		}
	})
	BB.GetBus("STP.bus").GetWire(4).AddPrehook(func(v bool) {
		if v {
			tm.Is(t, BB.STP.GetStep(), 5, "Step 4 does nothing!")
		}
	})
	BB.GetBus("STP.bus").GetWire(5).AddPrehook(func(v bool) {
		if v {
			tm.Is(t, BB.STP.GetStep(), 6, "Step 4 does nothing!")
		}
	})
	BB.GetBus("STP.bus").GetWire(6).AddPrehook(func(v bool) {
		if v && (BB.CLK.GetTicks() > 0) {
			tm.Is(t, BB.STP.GetStep(), 6, "Stepper reset!")
		}
	})

	BB.CLK.Tick()
	BB.CLK.Tick()
	BB.CLK.Tick()
	tm.Is(t, BB.STP.GetStep(), 3, "Stepper is at step 3")

	// Fourth time, using the stepper (automatically)
	tm.Is(t, BB.CLK.GetTicks(), 3, "Clock has done 3 ticks")
	reset(t, BB)
	BB.CLK.SetMaxTicks(BB.CLK.GetTicks() + 6)
	BB.CLK.Start()
	tm.Is(t, BB.CLK.GetTicks(), 9, "Clock is at 10 ticks")
	tm.Is(t, BB.STP.GetStep(), 3, "Stepper is at step 4")
}

func reset(t *testing.T, BB *Breadboard) {
	// Put a number on the data bus, say 20.
	BB.GetBus("DATA.bus").SetPower(0b00010100)
	// Let in go into R0.
	BB.GetWire("R0.s").SetPower(true)
	BB.GetWire("R0.s").SetPower(false)
	// Put a different number on the data bus, say 22.
	BB.GetBus("DATA.bus").SetPower(0b00010110)
	// Let in go into R1.
	BB.GetWire("R1.s").SetPower(true)
	BB.GetWire("R1.s").SetPower(false)
	tm.Is(t, BB.GetReg("R0").GetPower(), 0b00010100, "R0 contains 00010100 (20)")
	tm.Is(t, BB.GetReg("R1").GetPower(), 0b00010110, "R1 contains 00010110 (22)")
}

func cycle1(t *testing.T, BB *Breadboard) {
	BB.GetWire("R1.e").SetPower(true)
	BB.GetWire("TMP.s").SetPower(true)
	BB.GetWire("TMP.s").SetPower(false)
	BB.GetWire("R1.e").SetPower(false)
	tm.Is(t, BB.GetReg("TMP").GetPower(), 0b00010110, "cycle1: TMP contains 00010110 (22)")
}

func cycle2(t *testing.T, BB *Breadboard) {
	BB.GetWire("R0.e").SetPower(true)
	BB.GetBus("ALU.op").SetPower(0b000)
	t.Log(BB.ALU.String())
	t.Log(BB.GetReg("ACC"))
	BB.GetWire("ACC.s").SetPower(true)
	BB.GetWire("ACC.s").SetPower(false)
	BB.GetWire("R0.e").SetPower(false)
	tm.Is(t, BB.GetReg("ACC").GetPower(), 0b00101010, "cycle2: ACC contains 00101010 (42)")
}

func cycle3(t *testing.T, BB *Breadboard) {
	BB.GetWire("ACC.e").SetPower(true)
	BB.GetWire("R0.s").SetPower(true)
	BB.GetWire("R0.s").SetPower(false)
	BB.GetWire("ACC.e").SetPower(false)
	tm.Is(t, BB.GetReg("R0").GetPower(), 0b00101010, "cycle3: R0 contains 00101010 (42)")
}
