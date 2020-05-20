package parts

import (
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
MEMORY
*/
type Memory struct {
	i, s, o, m *g.Wire
	name       string
}

func NewNamedMemory(wi *g.Wire, ws *g.Wire, wo *g.Wire, name string) *Memory {
	wa := g.NewWire()
	wb := g.NewWire()
	wc := g.NewWire()
	// Setting power to 1 here is required to have an initial value of 0 in the memory!
	wc.SetPower(true)
	this := &Memory{wi, ws, wo, wc, name}

	g.NewNAND(wi, ws, wa)
	g.NewNAND(wa, ws, wb)
	g.NewNAND(wa, wc, wo)
	g.NewNAND(wo, wb, wc)

	return this
}

func NewMemory(wi *g.Wire, ws *g.Wire, wo *g.Wire) *Memory {
	return NewNamedMemory(wi, ws, wo, "")
}

func (this *Memory) GetM() bool {
	return !this.m.GetPower()
}
