package board

import (
	"fmt"
	"log"
)

func (this *Breadboard) Tick() {
	this.CLK.Tick()
}

func (this *Breadboard) Ticks(n int) {
	if n <= 0 {
		log.Panicf("Number of ticks must be >= 1, not %d", n)
	}
	for j := 0; j < n; j++ {
		this.Tick()
	}
}

func (this *Breadboard) Step() {
	this.Tick()
}

func (this *Breadboard) Steps(n int) {
	this.Ticks(n)
}

func (this *Breadboard) Inst() {
	cur := this.STP.GetStep()
	if (cur != 0) && (cur != 6) {
		log.Panicf("Can't Inst mid-instruction (step: %d)", cur)
	}

	this.Ticks(6)
}

func (this *Breadboard) Insts(n int) {
	if n <= 0 {
		log.Panicf("Number of insts must be >= 1, not %d", n)
	}

	for j := 0; j < n; j++ {
		this.Inst()
	}
}

func (this *Breadboard) Start() {
	this.CLK.Start()
}

// Replace logger with a new function
func (this *Breadboard) LogWith(f func(msg string)) {
	this.logWith = f
}

func (this *Breadboard) Debug() {
	msg := this.String()
	if this.ExtraDebug != nil {
		msg += this.ExtraDebug()
	}
	this.Log(msg)
}

func (this *Breadboard) DebugInst() {
	this.debug = 1
}

func (this *Breadboard) DebugTick() {
	this.debug = 2
}

func (this *Breadboard) DebugQTick() {
	this.debug = 3
}

func (this *Breadboard) _debug(n int) {
	if n == 0 {
		this.DebugOff()
	} else {
		this.debug = n
	}
}

func (this *Breadboard) DebugOff() {
	// Final state.
	this.Debug()
	this.debug = 0
}

func (this *Breadboard) Dump() {
	n := this.GetBus("DATA.bus").GetMaxPower()
	for j := 0; j <= n; j++ {
		s := fmt.Sprintf("RAM[%d] = %08b", j, this.RAM.GetCellPower(j))
		this.Log(s)
	}
}

func HALT() int {
	return 0b01100001
}

// Send a debug something to the debug writer
func (this *Breadboard) Log(l interface{}) {
	this.logWith(fmt.Sprintf("%+v", l))
}

func (this *Breadboard) SetReg(reg string, data int) {
	this.GetBus("DATA.bus").SetPower(data)
	f := fmt.Sprintf("%s.s", reg)
	this.GetWire(f).SetPower(true)
	this.GetWire(f).SetPower(false)
}

func (this *Breadboard) SetRAM(addr int, data int) {
	this.GetBus("DATA.bus").SetPower(addr)
	this.GetWire("RAM.MAR.s").SetPower(true)
	this.GetWire("RAM.MAR.s").SetPower(false)
	this.GetBus("DATA.bus").SetPower(data)
	this.GetWire("RAM.s").SetPower(true)
	this.GetWire("RAM.s").SetPower(false)
}

func (this *Breadboard) SetRAMBlock(offset int, data []int) {
	for i, d := range data {
		this.SetRAM(offset+i, d)
	}
}

// Place the instructions in RAM, starting at position 0, and Start() the computer.
// A HALT instruction is appeneded at the end to make sure the computer stops when the program is over.
func (this *Breadboard) Run(insts []int) {
	insts = append(insts, HALT())
	this.SetRAMBlock(0, insts)

	// Important to reset the DATA.bus after loading RAM as it will leave data there
	// that will mess up the rest of the instruction loading.
	this.GetBus("DATA.bus").SetPower(0)

	this.Start()
}
