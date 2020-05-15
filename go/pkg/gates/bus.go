package gates

import (
	"fmt"
	"regexp"
)

type Bus struct {
	n     int
	wires []*Wire
}

func NewBus8() *Bus {
	return NewBus(8)
}

func NewBus(n int) *Bus {
	ws := make([]*Wire, n, n)
	for j := 0; j < n; j++ {
		ws[j] = NewWire()
	}
	return WrapBus(ws)
}

func WrapBus(wires []*Wire) *Bus {
	n := len(wires)
	dst := make([]*Wire, n, n)
	copy(dst, wires)
	return &Bus{n, dst}
}

func WrapBusV(wires ...*Wire) *Bus {
	n := len(wires)
	dst := make([]*Wire, n, n)
	copy(dst, wires)
	return &Bus{n, dst}
}

func (this *Bus) GetWires() []*Wire {
	return this.wires
}

func (this *Bus) GetWire(n int) *Wire {
	if (n < 0) || (n >= this.n) {
		panic(fmt.Errorf("Invalid wire index %d (n is %d)", n, this.n))
	}

	return this.wires[n]
}

// Retrieves the given power values (as a string).
// This is used mostly in the test suite.
func (this *Bus) GetPower() string {
	ret := ""
	for _, w := range this.wires {
		if w.GetPower() {
			ret += "1"
		} else {
			ret += "0"
		}
	}
	return ret
}

// Assign the given power values (as a string) to the given wires.
// This is used mostly in the test suite.
func (this *Bus) SetPower(vs string) {
	if m, _ := regexp.MatchString(fmt.Sprintf("^[01]{%d}$", this.n), vs); !m {
		panic(fmt.Errorf("Invalid bus power string '%s' (n is %d)", vs, this.n))
	}
	for j, c := range vs {
		var v bool = false
		if c == '1' {
			v = true
		}
		this.wires[j].SetPower(v)
	}
}
