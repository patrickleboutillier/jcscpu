package parts

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

/*
STEPPER
*/
type Stepper struct {
	clk, rst *g.Wire
	os       *g.Bus
	s1       *g.OR
	s26      []*g.AND
	s7       *g.Wire
	ms       []*Memory
}

func NewStepper(wclk *g.Wire, bos *g.Bus) *Stepper {
	wrst := g.NewWire()
	wnrm1 := g.NewWire()
	g.NewNOT(wrst, wnrm1)
	wnco1 := g.NewWire()
	g.NewNOT(wclk, wnco1)
	wmsn := g.NewWire()
	g.NewOR(wrst, wnco1, wmsn)
	wmsnn := g.NewWire()
	g.NewOR(wrst, wclk, wmsnn)

	// M1
	wn12b := g.NewWire()
	s1 := g.NewOR(wrst, wn12b, bos.GetWire(0))
	wm112 := g.NewWire()
	m1 := NewNamedMemory(wnrm1, wmsn, wm112, " 1")

	// M12
	wn12a := g.NewWire()
	g.NewNOT(wn12a, wn12b)
	m12 := NewNamedMemory(wm112, wmsnn, wn12a, "12")

	// M2
	wn23b := g.NewWire()
	s2 := g.NewAND(wn12a, wn23b, bos.GetWire(1))
	wm223 := g.NewWire()
	m2 := NewNamedMemory(wn12a, wmsn, wm223, " 2")

	// M23
	wn23a := g.NewWire()
	g.NewNOT(wn23a, wn23b)
	m23 := NewNamedMemory(wm223, wmsnn, wn23a, "23")

	// M3
	wn34b := g.NewWire()
	s3 := g.NewAND(wn23a, wn34b, bos.GetWire(2))
	wm334 := g.NewWire()
	m3 := NewNamedMemory(wn23a, wmsn, wm334, " 3")

	// M34
	wn34a := g.NewWire()
	g.NewNOT(wn34a, wn34b)
	m34 := NewNamedMemory(wm334, wmsnn, wn34a, "34")

	// M4
	wn45b := g.NewWire()
	s4 := g.NewAND(wn34a, wn45b, bos.GetWire(3))
	wm445 := g.NewWire()
	m4 := NewNamedMemory(wn34a, wmsn, wm445, " 4")

	// M45
	wn45a := g.NewWire()
	g.NewNOT(wn45a, wn45b)
	m45 := NewNamedMemory(wm445, wmsnn, wn45a, "45")

	// M5
	wn56b := g.NewWire()
	s5 := g.NewAND(wn45a, wn56b, bos.GetWire(4))
	wm556 := g.NewWire()
	m5 := NewNamedMemory(wn45a, wmsn, wm556, " 5")

	// M56
	wn56a := g.NewWire()
	g.NewNOT(wn56a, wn56b)
	m56 := NewNamedMemory(wm556, wmsnn, wn56a, "56")

	// M6
	wn67b := g.NewWire()
	s6 := g.NewAND(wn56a, wn67b, bos.GetWire(5))
	wm667 := g.NewWire()
	m6 := NewNamedMemory(wn56a, wmsn, wm667, " 6")

	// M67
	g.NewNOT(bos.GetWire(6), wn67b)
	m67 := NewNamedMemory(wm667, wmsnn, bos.GetWire(6), "67")
	s7 := bos.GetWire(6)

	// Hook to forward signals to the s inputs to ensure they arrive before the i inputs.
	wclk.AddPrehook(func(v bool) {
		wmsn.SetPowerSoft(!v)
		wmsnn.SetPowerSoft(v)
	})

	wrst.AddPrehook(func(v bool) {
		if v {
			wmsn.SetPowerSoft(v)
			wmsnn.SetPowerSoft(v)
		} else {
			wmsn.SetPowerSoft(!wclk.GetPower())
			wmsnn.SetPowerSoft(wclk.GetPower())
		}
	})

	// In it's current design. the stepper goes to setup 1 as soon as it's powered on.
	// We don't want that. We want the stepper to be in a state where the first clock tick
	// will *bring it* to step 1.
	// To do this, we fake 6 ticks, and turn off (softly) the power on step 7.
	// But we have to simulate the ticks without touching wclk, which make the clock tick!
	// We need to signal the wmsn and wmsnn Wire directly.
	for j := 0; j < 6; j++ {
		wmsn.SetPower(false)
		wmsnn.SetPower(true)
		wmsn.SetPower(true)
		wmsnn.SetPower(false)
	}
	bos.GetWire(6).SetPowerSoft(false)

	// Finally, loop step 7 to the reset Wire.
	g.NewCONN(bos.GetWire(6), wrst)

	s26 := []*g.AND{s2, s3, s4, s5, s6}
	ms := []*Memory{m1, m12, m2, m23, m3, m34, m4, m45, m5, m56, m6, m67}

	return &Stepper{wclk, wrst, bos, s1, s26, s7, ms}
}

// Steps starting at 1, like in the book.
func (this *Stepper) GetStep() int {
	for j := 0; j < 7; j++ {
		if this.os.GetWire(j).GetPower() {
			return (j + 1)
		}
	}

	// When stepper has NOT yet been through a tick.
	return 0
}

func (this *Stepper) String() string {
	str := fmt.Sprintf("STEPPER(%d): rst:%s  clk:%s  steps:%s\n  ", this.GetStep(), this.rst.String(), this.clk.String(), this.os.String())
	str += "  " + this.s1.String() + "                "
	for _, s := range this.s26 {
		str += "  " + s.String() + "                "
	}
	str += "  " + this.s7.String()
	str += "\n  "
	for _, m := range this.ms {
		str += m.String() + "  "
	}
	str += "\n"

	return str
}
