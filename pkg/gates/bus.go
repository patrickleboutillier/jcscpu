package gates

import (
	"fmt"

	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
)

type Bus struct {
	n     int
	wires []*Wire
}

func NewBus() *Bus {
	return NewBusN(a.GetArchBits())
}

func NewBusN(n int) *Bus {
	if n < 1 {
		panic(fmt.Errorf("Bus sizes must be >= 1"))
	}
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

// Retrieves the given power values as an int.
// This is used mostly in the test suite.
func (this *Bus) GetPower() int {
	ret := 0
	for j, w := range this.wires {
		if w.GetPower() {
			ret += 1
		} else {
			ret += 0
		}
		if j < (this.n - 1) {
			ret = ret << 1
		}
	}

	return ret
}

func (this *Bus) String() string {
	f := fmt.Sprintf("%%0%db", this.n)
	return fmt.Sprintf(f, this.GetPower())
}

// Assign the given power values (as an int) to the given wires.
// This is used mostly in the test suite.
func (this *Bus) SetPower(vs int) {
	if vs < 0 {
		panic(fmt.Errorf("Power value for bus must be positive"))
	}
	if vs > ((1 << this.n) - 1) {
		panic(fmt.Errorf("Power value %d too large for bus (n is %d)", vs, this.n))
	}

	for j := 0; j < this.n; j++ {
		v := false
		if (vs % 2) == 1 {
			v = true
		}
		this.GetBit(j).SetPower(v)
		vs = vs >> 1
	}
}