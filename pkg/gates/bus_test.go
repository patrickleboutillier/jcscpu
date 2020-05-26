package gates

import (
	"testing"

	t8 "github.com/patrickleboutillier/jcscpu/internal/testarch"
	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
)

func TestBusPower(t *testing.T) {
	b := NewBus(t8.GetArchBits())
	tm.Is(t, b.GetPower(), 0b00000000, "GetPower failed")
	b.SetPower(0b10101010)
	tm.Is(t, b.GetPower(), 0b10101010, "SetPower failed")
	w := b.GetBit(1)
	tm.Is(t, w.GetPower(), true, "GetPower failed")
	w = b.GetBit(0)
	tm.Is(t, w.GetPower(), false, "GetPower failed")

	w1 := NewWire()
	w1.SetPower(true)
	w2 := NewWire()
	w3 := NewWire()
	b = WrapBusV(w1, w2, w3)
	w = b.GetWire(0)
	tm.Is(t, w.GetPower(), true, "GetPower failed")
	w = b.GetWire(1)
	tm.Is(t, w.GetPower(), false, "GetPower failed")

	wires := b.GetWires()
	w = wires[0]
	tm.Is(t, w.GetPower(), true, "GetPower failed")
	w = wires[1]
	tm.Is(t, w.GetPower(), false, "GetPower failed")

	// Other stuff
	b = NewBus(8)
	tm.Is(t, b.String(), "00000000", "String")
	CheckBusSizes(b, b, "")
}

func TestBusErrors(t *testing.T) {
	tm.TPanic(t, func() {
		b := NewBus(t8.GetArchBits())
		b.GetWire(-1)
	})
	tm.TPanic(t, func() {
		b := NewBus(t8.GetArchBits())
		b.GetWire(b.GetSize() + 10)
	})
	tm.TPanic(t, func() {
		b := NewBus(t8.GetArchBits())
		b.SetPower(-123)
	})
	tm.TPanic(t, func() {
		b := NewBus(t8.GetArchBits())
		b.SetPower(t8.GetMaxByteValue() + 1)
	})
	tm.TPanic(t, func() {
		b := NewBus(t8.GetArchBits())
		b.GetBit(-1)
	})
	tm.TPanic(t, func() {
		b := NewBus(t8.GetArchBits())
		b.GetBit(-1)
	})
	tm.TPanic(t, func() {
		b := NewBus(t8.GetArchBits())
		b.GetBit(b.GetSize() + 12)
	})
	tm.TPanic(t, func() {
		b1 := NewBus(4)
		b2 := NewBus(5)
		CheckBusSizes(b1, b2, "")
	})
	tm.TPanic(t, func() {
		NewBus(0)
	})
}
