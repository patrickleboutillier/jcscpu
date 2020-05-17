package parts

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
REGISTER
*/
type Register struct {
	is, bus, os *g.Bus
	s, e        *g.Wire
	name        string
}

func NewRegister(bis *g.Bus, ws *g.Wire, we *g.Wire, bos *g.Bus, name string) *Register {
	g.CheckBusSizes(bis, bos, "Register input and output buses")
	n := bis.GetSize()
	bus := g.NewBusN(n)
	this := &Register{bis, bus, bos, ws, we, name}

	NewByte(bis, ws, bus)
	NewEnabler(bus, we, bos)

	return this
}

func (this *Register) GetPower() string {
	return this.bus.GetPower()
}

func (this *Register) String() string {
	return fmt.Sprintf("%s:%c/%s/%c", this.name, this.s.GetPowerChar(), this.bus.GetPower(), this.e.GetPowerChar())
}
