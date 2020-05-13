package gate

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
			SetPower(wa, tt.a)
			SetPower(wb, tt.b)
			if GetPower(wc) != tt.c {
				t.Errorf("got %t, expected %t", GetPower(wc), tt.c)
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
			SetPower(wa, tt.a)
			if GetPower(wb) != tt.b {
				t.Errorf("got %t, expected %t", GetPower(wb), tt.b)
			}
		})
	}
}
