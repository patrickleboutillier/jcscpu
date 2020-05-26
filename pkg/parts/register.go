package parts

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
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
	bus := g.NewBus(n)
	this := &Register{bis, bus, bos, ws, we, name}

	NewByte(bis, ws, bus)
	NewEnabler(bus, we, bos)

	return this
}

func (this *Register) GetPower() int {
	return this.bus.GetPower()
}

func (this *Register) String() string {
	return fmt.Sprintf("%s:%s/%s/%s", this.name, this.s.String(), this.bus.String(), this.e.String())
}
