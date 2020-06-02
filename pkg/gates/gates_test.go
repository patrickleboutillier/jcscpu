package gates

import (
	"fmt"
	"math/rand"
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
)

var max_n_tests int = 8

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
		testname := fmt.Sprintf("NAND(%t,%t)=%t", tt.a, tt.b, tt.c)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewNAND(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			tm.Is(t, wc.GetPower(), tt.c, testname)
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
		testname := fmt.Sprintf("NOT(%t)=%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			NewNOT(wa, wb)
			wa.SetPower(tt.a)
			tm.Is(t, wb.GetPower(), tt.b, testname)
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
		testname := fmt.Sprintf("CONN(%t)=%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			NewCONN(wa, wb)
			wa.SetPower(tt.a)
			tm.Is(t, wb.GetPower(), tt.b, testname)
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
		testname := fmt.Sprintf("AND(%t,%t)=%t", tt.a, tt.b, tt.c)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewAND(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			tm.Is(t, wc.GetPower(), tt.c, testname)
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
		testname := fmt.Sprintf("OR(%t,%t)=%t", tt.a, tt.b, tt.c)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewOR(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			tm.Is(t, wc.GetPower(), tt.c, testname)
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
		testname := fmt.Sprintf("XOR(%t,%t)=%t", tt.a, tt.b, tt.c)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewXOR(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			tm.Is(t, wc.GetPower(), tt.c, testname)
		})
	}
}

func TestANDn(t *testing.T) {
	for n := 2; n <= max_n_tests; n++ {
		bis := NewBus(n)
		wo := NewWire()
		NewANDn(bis, wo)

		max := 1 << n
		for j := 0; j < max; j++ {
			x := j
			for _, r := range [2]bool{false, true} {
				if r {
					x = rand.Intn(max)
				}

				res := (x == (max - 1))
				testname := fmt.Sprintf("AND%d(%d)=%t", n, x, res)
				t.Run(testname, func(t *testing.T) {
					bis.SetPower(x)
					tm.Is(t, wo.GetPower(), res, testname)
				})
			}
		}
	}
}

func TestORn(t *testing.T) {
	for n := 2; n <= max_n_tests; n++ {
		bis := NewBus(n)
		wo := NewWire()
		NewORn(bis, wo)

		max := 1 << n
		for j := 0; j < max; j++ {
			x := j
			for _, r := range [2]bool{false, true} {
				if r {
					x = rand.Intn(max)
				}

				res := (x != 0)
				testname := fmt.Sprintf("OR%d(%d)=%t", n, x, res)
				t.Run(testname, func(t *testing.T) {
					bis.SetPower(x)
					tm.Is(t, wo.GetPower(), res, testname)
				})
			}
		}
	}
}

func TestGateErrors(t *testing.T) {
	tm.TPanic(t, func() {
		o := NewORe(NewWire())
		for j := 0; j < OReSize; j++ {
			o.AddWire(NewWire())
		}
		o.AddWire(NewWire())
	})
	tm.TPanic(t, func() {
		NewANDn(NewBus(1), NewWire())
	})
	tm.TPanic(t, func() {
		NewORn(NewBus(1), NewWire())
	})
}
