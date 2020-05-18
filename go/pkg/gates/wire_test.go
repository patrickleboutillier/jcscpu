package gates

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
)

func TestWirePower(t *testing.T) {
	w := NewWire()
	tm.Is(t, w.GetPower(), false, "power initialized at false")
	w.SetPower(true)
	tm.Is(t, w.GetPower(), true, "power set to true")
	w.SetPower(false)
	tm.Is(t, w.GetPower(), false, "power set to false")
}

func TestWirePrehooks(t *testing.T) {
	n := 0
	w := NewWire()
	w.AddPrehook(func(v bool) { n++ })
	w.SetPower(false)
	tm.Is(t, n, 1, "prehook called")
}

func TestWireTerminal(t *testing.T) {
	w := NewWire()
	w.SetTerminal()
	w.SetPower(true)
	tm.Is(t, w.GetPower(), false, "terminal froze the wire")
	w = On()
	w.SetPower(false)
	tm.Is(t, w.GetPower(), true, "terminal froze the wire")
	w = Off()
	w.SetPower(true)
	tm.Is(t, w.GetPower(), false, "terminal froze the wire")
}

func TestWireSoft(t *testing.T) {
	w := NewWire()
	w.SetPowerSoft(true)
	tm.Is(t, w.GetPower(), true, "SetPowerSoft")
}
