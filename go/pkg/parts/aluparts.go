package parts

import (
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
SHIFTR
*/
type ShiftRight struct {
	is, os *g.Bus
	ci, co *g.Wire
}

func NewShiftRight(bis *g.Bus, wci *g.Wire, bos *g.Bus, wco *g.Wire) *ShiftRight {
	this := &ShiftRight{bis, bos, wci, wco}
	g.NewCONN(wci, bos.GetWire(0))
	for j := 1; j < bis.GetSize(); j++ {
		g.NewCONN(bis.GetWire(j-1), bos.GetWire(j))
	}
	g.NewCONN(bis.GetWire(bis.GetSize()-1), wco)
	return this
}

/*
SHIFTL
*/
type ShiftLeft struct {
	is, os *g.Bus
	ci, co *g.Wire
}

func NewShiftLeft(bis *g.Bus, wci *g.Wire, bos *g.Bus, wco *g.Wire) *ShiftRight {
	this := &ShiftRight{bis, bos, wci, wco}
	g.NewCONN(bis.GetWire(0), wco)
	for j := 1; j < bis.GetSize(); j++ {
		g.NewCONN(bis.GetWire(j), bos.GetWire(j-1))
	}
	g.NewCONN(wci, bos.GetWire(bos.GetSize()-1))
	return this
}
