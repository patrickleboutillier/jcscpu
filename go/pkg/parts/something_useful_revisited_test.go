package parts

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

func TestSomethingUsefulRevisited(t *testing.T) {
	BB := NewVanillaBreadboard()

	// Add our extra connections to the Harness
	steps := BB.GetBus("STP.bus")
	clke := BB.GetWire("CLK.clke")
	g.NewAND(clke, steps.GetWire(5), BB.GetWire("ACC.e"))
	g.NewAND(clke, steps.GetWire(4), BB.GetWire("R0.e"))
	g.NewAND(clke, steps.GetWire(3), BB.GetWire("R1.e"))
	clks := BB.GetWire("CLK.clks")
	g.NewAND(clks, steps.GetWire(3), BB.GetWire("TMP.s"))
	g.NewAND(clks, steps.GetWire(4), BB.GetWire("ACC.s"))
	g.NewAND(clks, steps.GetWire(5), BB.GetWire("R0.s"))

	tm.Is(t, 0b00010100, 20, "00010100=20")
	tm.Is(t, 0b00010110, 22, "00010110=22")
	tm.Is(t, 0b00101010, 42, "00101010=42")

	// Initialize registers with vaues.
	reset2(t, BB)

	// Since we are hooked on steps 4-5-6, the first 3 ticks do nothing...
	BB.Ticks(4)
	tm.Is(t, BB.GetReg("TMP").GetPower(), 0b00010110, "TMP contains 00010110 (22)")
	BB.Tick()
	tm.Is(t, BB.GetReg("ACC").GetPower(), 0b00101010, "ACC contains 00101010 (42)")
	BB.Tick()
	tm.Is(t, BB.GetReg("R0").GetPower(), 0b00101010, "R0 contains 00101010 (42)")
}

func reset2(t *testing.T, BB *Breadboard) {
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
