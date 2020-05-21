package parts

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

func TestClockBasic(t *testing.T) {
	wclk := g.NewWire()
	wclke := g.NewWire()
	wclks := g.NewWire()
	C := NewClock(wclk, wclke, wclks)
	C.SetMaxTicks(2)
	tm.Is(t, C.GetQTicks(), 0, "Clock starts with 0 completed QTicks")
	tm.Is(t, C.GetTicks(), 0, "Clock starts with 0 completed ticks")

	n := C.Start()
	tm.Is(t, n, 2, "Clock stopped after max (2) ticks")
	tm.Is(t, C.GetQTicks(), 8, "Clock did 8 QTicks")
	tm.Is(t, C.GetTicks(), 2, "Clock did 2 ticks")

	wclk = g.NewWire()
	wclke = g.NewWire()
	wclks = g.NewWire()
	C = NewClock(wclk, wclke, wclks)
	for j := 0; j < (2 * 4); j++ {
		C.QTick()
	}
	tm.Is(t, C.GetQTicks(), 8, "Clock did 8 QTicks manually using QTick()")

	wclk = g.NewWire()
	wclke = g.NewWire()
	wclks = g.NewWire()
	C = NewClock(wclk, wclke, wclks)
	C.Tick()
	C.Tick()

	tm.Is(t, C.GetQTicks(), 8, "Clock did 8 QTicks")
	for j := 0; j < 4; j++ {
		C.QTick()
	}
	tm.Is(t, C.GetQTicks(), 12, "Clock did 12 QTicks")
	C.QTick()
	tm.Is(t, C.GetQTicks(), 13, "Clock did 13 QTicks")
}

func TestClockPrecise(t *testing.T) {
	wclk := g.NewWire()
	wclke := g.NewWire()
	wclks := g.NewWire()
	C := NewClock(wclk, wclke, wclks)

	C.QTick()
	tm.Is(t, wclk.GetPower(), true, "clk on")
	tm.Is(t, C.clkd.GetPower(), false, "clkd off")
	tm.Is(t, wclke.GetPower(), true, "clke on")
	tm.Is(t, wclks.GetPower(), false, "clks off")
	C.QTick()
	tm.Is(t, wclk.GetPower(), true, "clk on")
	tm.Is(t, C.clkd.GetPower(), true, "clkd on")
	tm.Is(t, wclke.GetPower(), true, "clke on")
	tm.Is(t, wclks.GetPower(), true, "clks on")
	C.QTick()
	tm.Is(t, wclk.GetPower(), false, "clk off")
	tm.Is(t, C.clkd.GetPower(), true, "clkd on")
	tm.Is(t, wclke.GetPower(), true, "clke on")
	tm.Is(t, wclks.GetPower(), false, "clks off")
	C.QTick()
	tm.Is(t, wclk.GetPower(), false, "clk off")
	tm.Is(t, C.clkd.GetPower(), false, "clkd off")
	tm.Is(t, wclke.GetPower(), false, "clke off")
	tm.Is(t, wclks.GetPower(), false, "clks off")
	C.QTick()
	tm.Is(t, wclk.GetPower(), true, "clk on")
	tm.Is(t, C.clkd.GetPower(), false, "clkd off")
	tm.Is(t, wclke.GetPower(), true, "clke on")
	tm.Is(t, wclks.GetPower(), false, "clks off")
}

func TestClockErrors(t *testing.T) {
	tm.TPanic(t, func() {
		wclk := g.NewWire()
		wclke := g.NewWire()
		wclks := g.NewWire()
		C := NewClock(wclk, wclke, wclks)
		C.QTick()
		C.Tick()
	})
}
