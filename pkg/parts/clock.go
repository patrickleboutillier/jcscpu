package parts

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

// A "pure" 'gates' implementation of Clock is very slow since it ends up using endless recursion.
// This implementation uses a loop to be more performant.

/*
CLOCK
*/
type Clock struct {
	clk, clkd, clke, clks *g.Wire
	qticks, maxticks      int
}

func NewClock(wclk *g.Wire, wclke *g.Wire, wclks *g.Wire) *Clock {
	wclkd := g.NewWire()
	g.NewOR(wclk, wclkd, wclke)
	g.NewAND(wclk, wclkd, wclks)

	return &Clock{wclk, wclkd, wclke, wclks, 0, -1}
}

func (this *Clock) Clkd() *g.Wire {
	return this.clkd
}

func (this *Clock) SetMaxTicks(n int) {
	this.maxticks = n
}

func (this *Clock) GetQTicks() int {
	return this.qticks
}

func (this *Clock) GetTicks() int {
	return int(this.qticks / 4)
}

// Stop the clock on the next tick
func (this *Clock) Stop() {
	this.maxticks = this.GetTicks()
}

func (this *Clock) Start() int {
	for (this.maxticks < 0) || (this.GetTicks() < this.maxticks) {
		this.Tick()
	}

	return this.GetTicks()
}

// Manual advancing of the clock.
func (this *Clock) QTick() {
	switch this.qticks % 4 {
	case 0:
		this.clk.SetPower(true)
	case 1:
		this.clkd.SetPower(true)
	case 2:
		this.clk.SetPower(false)
	case 3:
		this.clkd.SetPower(false)
	}
	this.qticks++
}

// Manual advancing of the clock.
func (this *Clock) Tick() {
	if (this.qticks % 4) != 0 {
		panic(fmt.Errorf("Can't tick mid-cycle (qticks: %d)!", this.qticks))
	}

	for j := 0; j < 4; j++ {
		this.QTick()
	}
}

func (this *Clock) String() string {
	return fmt.Sprintf("CLK(@%d.%d[%d]): clk:%s  clkd:%s  clke:%s  clks:%s", this.GetTicks(), (this.qticks % 4), this.qticks,
		this.clk.String(), this.clkd.String(), this.clke.String(), this.clks.String())
}
