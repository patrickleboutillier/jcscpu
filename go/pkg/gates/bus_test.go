package gates

import (
	"testing"
)

func TestBusPower(t *testing.T) {
	b := NewBus()
	if !b.IsPower("00000000") {
		t.Errorf("GetPower failed")
	}
	if b.GetPowerInt() != 0 {
		t.Errorf("GetPower failed")
	}
	b.SetPower("10101010")
	if !b.IsPower("010101010") {
		t.Errorf("SetPower failed")
	}
	w := b.GetWire(b.GetSize() - 2)
	if !w.GetPower() {
		t.Errorf("GetPower failed")
	}
	w = b.GetWire(b.GetSize() - 1)
	if w.GetPower() {
		t.Errorf("GetPower failed")
	}

	w1 := NewWire()
	w1.SetPower(true)
	w2 := NewWire()
	w3 := NewWire()
	b = WrapBusV(w1, w2, w3)
	w = b.GetWire(0)
	if !w.GetPower() {
		t.Errorf("GetPower failed")
	}
	w = b.GetWire(1)
	if w.GetPower() {
		t.Errorf("GetPower failed")
	}

	wires := b.GetWires()
	w = wires[0]
	if !w.GetPower() {
		t.Errorf("GetPower failed")
	}
	w = wires[1]
	if w.GetPower() {
		t.Errorf("GetPower failed")
	}
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
