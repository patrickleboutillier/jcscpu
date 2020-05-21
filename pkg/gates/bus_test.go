package gates

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
)

func TestBusPower(t *testing.T) {
	b := NewBus()
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
	b = NewBusN(8)
	tm.Is(t, b.String(), "00000000", "String")
	CheckBusSizes(b, b, "")
}

func TestBusErrors(t *testing.T) {
	tm.TPanic(t, func() {
		b := NewBus()
		b.GetWire(-1)
	})
	tm.TPanic(t, func() {
		b := NewBus()
		b.GetWire(b.GetSize() + 10)
	})
	tm.TPanic(t, func() {
		b := NewBus()
		b.SetPower(-123)
	})
	tm.TPanic(t, func() {
		b := NewBus()
		b.SetPower(a.GetMaxByteValue() + 1)
	})
	tm.TPanic(t, func() {
		b := NewBus()
		b.GetBit(-1)
	})
	tm.TPanic(t, func() {
		b := NewBus()
		b.GetBit(-1)
	})
	tm.TPanic(t, func() {
		b := NewBus()
		b.GetBit(b.GetSize() + 12)
	})
	tm.TPanic(t, func() {
		b1 := NewBusN(4)
		b2 := NewBusN(5)
		CheckBusSizes(b1, b2, "")
	})
	tm.TPanic(t, func() {
		NewBusN(0)
	})
}
