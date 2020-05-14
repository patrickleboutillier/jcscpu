package gates

import (
	"fmt"
	"testing"
)

func TestNAND(t *testing.T) {
	var tests = []struct {
		a, b, c bool
	}{
		{false, false, true},
		{false, true, true},
		{true, false, true},
		{true, true, false},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewNAND(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			if wc.GetPower() != tt.c {
				t.Errorf("got %t, expected %t", wc.GetPower(), tt.c)
			}
		})
	}
}

func TestNOT(t *testing.T) {
	var tests = []struct {
		a, b bool
	}{
		{false, true},
		{true, false},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			NewNOT(wa, wb)
			wa.SetPower(tt.a)
			if wb.GetPower() != tt.b {
				t.Errorf("got %t, expected %t", wb.GetPower(), tt.b)
			}
		})
	}
}

func TestCONN(t *testing.T) {
	var tests = []struct {
		a, b bool
	}{
		{false, false},
		{true, true},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			NewCONN(wa, wb)
			wa.SetPower(tt.a)
			if wb.GetPower() != tt.b {
				t.Errorf("got %t, expected %t", wb.GetPower(), tt.b)
			}
		})
	}
}

func TestAND(t *testing.T) {
	var tests = []struct {
		a, b, c bool
	}{
		{false, false, false},
		{false, true, false},
		{true, false, false},
		{true, true, true},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewAND(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			if wc.GetPower() != tt.c {
				t.Errorf("got %t, expected %t", wc.GetPower(), tt.c)
			}
		})
	}
}

func TestOR(t *testing.T) {
	var tests = []struct {
		a, b, c bool
	}{
		{false, false, false},
		{false, true, true},
		{true, false, true},
		{true, true, true},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewOR(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			if wc.GetPower() != tt.c {
				t.Errorf("got %t, expected %t", wc.GetPower(), tt.c)
			}
		})
	}
}

func TestXOR(t *testing.T) {
	var tests = []struct {
		a, b, c bool
	}{
		{false, false, false},
		{false, true, true},
		{true, false, true},
		{true, true, false},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewXOR(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			if wc.GetPower() != tt.c {
				t.Errorf("got %t, expected %t", wc.GetPower(), tt.c)
			}
		})
	}
}
