package gates

import (
	"testing"
)

func TestWirePower(t *testing.T) {
	w := NewWire()
	if w.GetPower() {
		t.Errorf("power should be initialized at false")
	}
	w.SetPower(true)
	if !w.GetPower() {
		t.Errorf("power should have been set to true")
	}
	w.SetPower(false)
	if w.GetPower() {
		t.Errorf("power should have been set to false")
	}
}

func TestWirePrehooks(t *testing.T) {
	n := 0
	w := NewWire()
	w.AddPrehook(func(v bool) { n++ })
	w.SetPower(false)
	if n != 1 {
		t.Errorf("prehook not called")
	}
}

func TestWireTerminal(t *testing.T) {
	w := NewWire()
	w.SetTerminal()
	w.SetPower(true)
	if w.GetPower() {
		t.Errorf("terminal didn't freeze the wire")
	}
	w = On()
	w.SetPower(false)
	if !w.GetPower() {
		t.Errorf("terminal didn't freeze the wire")
	}
	w = Off()
	w.SetPower(true)
	if w.GetPower() {
		t.Errorf("terminal didn't freeze the wire")
	}
}

func TestWireSoft(t *testing.T) {
	w := NewWire()
	w.SetPowerSoft(true)
	if !w.GetPower() {
		t.Errorf("SetPowerSoft failed")
	}
}
