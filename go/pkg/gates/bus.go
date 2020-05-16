package gates

import (
	"fmt"
	"regexp"
	"strconv"

	a "github.com/patrickleboutillier/jcscpu/go/pkg/arch"
)

type Bus struct {
	n     int
	wires []*Wire
}

func NewBus() *Bus {
	return NewBusN(a.GetArchBits())
}

func NewBusN(n int) *Bus {
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

func (this *Bus) GetSize() int {
	return this.n
}

func CheckBusSizes(b1, b2 *Bus, msg string) {
	n1 := b1.GetSize()
	n2 := b2.GetSize()
	if n1 != n2 {
		panic(fmt.Errorf("Bus sizes (%d, %d) different for %s", n1, n2, msg))
	}
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

func (this *Bus) GetBit(n int) *Wire {
	if (n < 0) || (n >= this.n) {
		panic(fmt.Errorf("Invalid bit index %d (n is %d)", n, this.n))
	}

	return this.wires[(this.n-1)-n]
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

func (this *Bus) GetPowerInt() int {
	s := this.GetPower()
	i, _ := strconv.ParseInt(s, 2, 32)
	return int(i)
}

// Used for testing. If string is too short, it will be left padded with 0s.
func (this *Bus) IsPower(vs string) bool {
	if m, _ := regexp.MatchString(fmt.Sprintf("^[01]+$"), vs); !m {
		panic(fmt.Errorf("Invalid bus power string '%s' (n is %d)", vs, this.n))
	}

	i, _ := strconv.ParseInt(vs, 2, 32)
	return int(i) == this.GetPowerInt()
}

// Assign the given power values (as a string) to the given wires.
// This is used mostly in the test suite.
func (this *Bus) SetPower(vs string) {
	// Pad vs if it is to short.
	f := fmt.Sprintf("%%0%ds", this.n)
	vs = fmt.Sprintf(f, vs)
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

func (this *Bus) SetPowerInt(n int) {
	s := fmt.Sprintf(fmt.Sprintf("%%0%db", this.n), n)
	this.SetPower(s)
}
