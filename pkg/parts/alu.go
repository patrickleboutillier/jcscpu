package parts

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

/*
ALU
*/
type ALU struct {
	as, bs, ops, cs     *g.Bus
	ci, co, eqo, alo, z *g.Wire
}

func NewALU(bas *g.Bus, bbs *g.Bus, wci *g.Wire, bops *g.Bus, bcs *g.Bus, wco *g.Wire, weqo *g.Wire, walo *g.Wire, wz *g.Wire) *ALU {
	// Build the ALU circuit
	bdec := g.NewBus(8)
	NewDecoder(bops, bdec)
	bdec.GetWire(7).SetPower(false)
	bdec.GetWire(7).SetTerminal()

	bxor := g.NewBus(bas.GetSize())
	NewXORer(bas, bbs, bxor, weqo, walo)
	NewEnabler(bxor, bdec.GetWire(6), bcs)

	bor := g.NewBus(bas.GetSize())
	NewORer(bas, bbs, bor)
	NewEnabler(bor, bdec.GetWire(5), bcs)

	band := g.NewBus(bas.GetSize())
	NewANDder(bas, bbs, band)
	NewEnabler(band, bdec.GetWire(4), bcs)

	bnot := g.NewBus(bas.GetSize())
	NewNOTter(bas, bnot)
	NewEnabler(bnot, bdec.GetWire(3), bcs)

	bshl := g.NewBus(bas.GetSize())
	woshl := g.NewWire()
	NewShiftLeft(bas, wci, bshl, woshl)
	g.NewAND(woshl, bdec.GetWire(2), wco)
	NewEnabler(bshl, bdec.GetWire(2), bcs)

	bshr := g.NewBus(bas.GetSize())
	woshr := g.NewWire()
	NewShiftRight(bas, wci, bshr, woshr)
	g.NewAND(woshr, bdec.GetWire(1), wco)
	NewEnabler(bshr, bdec.GetWire(1), bcs)

	add := NewADDer(bas, bbs, wci, g.NewBus(bas.GetSize()), g.NewWire())
	g.NewAND(add.co, bdec.GetWire(0), wco)
	NewEnabler(add.cs, bdec.GetWire(0), bcs)

	NewZero(bcs, wz)

	return &ALU{bas, bbs, bops, bcs, wci, wco, weqo, walo, wz}
}

func (this *ALU) String() string {
	str := fmt.Sprintf("ALU: op:%s  a:%s  b:%s  ci:%s  c:%s  co:%s  eqo:%s  alo:%s  z:%s",
		this.ops.String(), this.as.String(), this.bs.String(), this.ci.String(),
		this.cs.String(), this.co.String(), this.eqo.String(), this.alo.String(), this.z.String())
	return str
}
