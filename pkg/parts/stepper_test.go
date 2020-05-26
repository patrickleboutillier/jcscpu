package parts

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

var max_clock_ticks = 256

func TestStepperManual(t *testing.T) {
	// First we need a clock
	wclk := g.NewWire()
	wclke := g.NewWire()
	wclks := g.NewWire()
	C := NewClock(wclk, wclke, wclks)

	// First we make the stepper advance manually.
	bsteps := g.NewBus(7)
	S := NewStepper(wclk, bsteps)

	type tc struct {
		p, s int
	}

	tm.Is(t, tc{bsteps.GetPower(), S.GetStep()}, tc{0b0000000, 0}, "initial state, step 0")
	C.Tick()
	tm.Is(t, tc{bsteps.GetPower(), S.GetStep()}, tc{0b1000000, 1}, "step 1")
	C.Tick()
	tm.Is(t, tc{bsteps.GetPower(), S.GetStep()}, tc{0b0100000, 2}, "step 2")
	C.Tick()
	tm.Is(t, tc{bsteps.GetPower(), S.GetStep()}, tc{0b0010000, 3}, "step 3")
	C.Tick()
	tm.Is(t, tc{bsteps.GetPower(), S.GetStep()}, tc{0b0001000, 4}, "step 4")
	C.Tick()
	tm.Is(t, tc{bsteps.GetPower(), S.GetStep()}, tc{0b0000100, 5}, "step 5")
	C.Tick()
	tm.Is(t, tc{bsteps.GetPower(), S.GetStep()}, tc{0b0000010, 6}, "step 6")
	C.Tick()
	tm.Is(t, tc{bsteps.GetPower(), S.GetStep()}, tc{0b1000000, 1}, "step 1, auto reset")
}

func TestStepperAuto(t *testing.T) {
	// Now with an automatic clock
	wclk := g.NewWire()
	wclke := g.NewWire()
	wclks := g.NewWire()
	C := NewClock(wclk, wclke, wclks)
	C.SetMaxTicks(256)

	// First we make the stepper advance manually.
	bsteps := g.NewBus(7)
	S := NewStepper(wclk, bsteps)

	tm.Is(t, C.GetQTicks(), 0, "Starting test at qtick 0")
	tm.Is(t, C.GetTicks(), 0, "Starting test at tick 0")
	tm.Is(t, bsteps.GetPower(), 0b0000000, "initial state, step 7")
	// Get out of step 7 by doing one click.
	C.Tick()

	wclk.AddPrehook(func(v bool) {
		if v {
			// Since ticks() has already been incremented to the next tick by the clock prehook,
			// subtract 1 from it.
			tmod6 := (C.GetTicks() - 1) % 6
			tm.Is(t, S.GetStep(), tmod6+1, "Step is t") // steps 1-6

			// Check the matching power value
			p := 1 << (7 - S.GetStep())
			tm.Is(t, bsteps.GetPower(), p, "Proper step should be set ("+bsteps.String()+")")
		}
	})

	n := C.Start()
	tm.Is(t, n, 256, "Clock did 256 ticks")
	tm.Is(t, C.GetTicks(), 256, "Clock did 256 ticks")
	tm.Is(t, C.GetQTicks(), 1024, "Clock did 1024 qticks")
}
