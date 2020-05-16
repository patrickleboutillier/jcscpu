package gates

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
)

func TestBusPower(t *testing.T) {
	b := NewBus()
	tm.Ok(t, b.IsPower("00000000"), "GetPower failed")
	tm.IsInt(t, b.GetPowerInt(), 0, "GetPower failed")
	b.SetPower("10101010")
	tm.Ok(t, b.IsPower("010101010"), "SetPower failed")
	w := b.GetBit(1)
	tm.IsBool(t, w.GetPower(), true, "GetPower failed")
	w = b.GetBit(0)
	tm.IsBool(t, w.GetPower(), false, "GetPower failed")

	w1 := NewWire()
	w1.SetPower(true)
	w2 := NewWire()
	w3 := NewWire()
	b = WrapBusV(w1, w2, w3)
	w = b.GetWire(0)
	tm.IsBool(t, w.GetPower(), true, "GetPower failed")
	w = b.GetWire(1)
	tm.IsBool(t, w.GetPower(), false, "GetPower failed")

	wires := b.GetWires()
	w = wires[0]
	tm.IsBool(t, w.GetPower(), true, "GetPower failed")
	w = wires[1]
	tm.IsBool(t, w.GetPower(), false, "GetPower failed")
}

func TestBusErrors(t *testing.T) {
	f := func() {
		b := NewBus()
		b.GetWire(-1)
	}
	tpanic(t, f)
	f = func() {
		b := NewBus()
		b.GetWire(b.GetSize() + 10)
	}
	tpanic(t, f)
	f = func() {
		b := NewBus()
		b.SetPower("123")
	}
	tpanic(t, f)
}
