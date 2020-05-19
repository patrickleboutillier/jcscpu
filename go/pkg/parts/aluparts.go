package parts

import (
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
ADDER
*/
type Adder struct {
	as, bs, cs *g.Bus
	ci, co     *g.Wire
}

func NewAdder(bas *g.Bus, bbs *g.Bus, wci *g.Wire, bcs *g.Bus, wco *g.Wire) *Adder {
	// Build the ADDer circuit
	twci := g.NewWire()
	twco := wco
	for j := 0; j < bas.GetSize(); j++ {
		tw := twci
		if j == (bas.GetSize() - 1) {
			tw = wci
		}
		g.NewADD(bas.GetWire(j), bbs.GetWire(j), tw, bcs.GetWire(j), twco)
		twco = twci
		twci = g.NewWire()
	}
	return &Adder{bas, bbs, bcs, wci, wco}
}

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

/*
NOTTER
*/
type Notter struct {
	is, os *g.Bus
}

func NewNotter(bis *g.Bus, bos *g.Bus) *Notter {
	this := &Notter{bis, bos}
	for j := 0; j < bis.GetSize(); j++ {
		g.NewNOT(bis.GetWire(j), bos.GetWire(j))
	}
	return this
}

/*
ANDDER
*/
type Andder struct {
	as, bs, cs *g.Bus
}

func NewAndder(bas *g.Bus, bbs *g.Bus, bcs *g.Bus) *Andder {
	this := &Andder{bas, bbs, bcs}
	for j := 0; j < bas.GetSize(); j++ {
		g.NewAND(bas.GetWire(j), bbs.GetWire(j), bcs.GetWire(j))
	}
	return this
}

/*
ORRER
*/
type Orrer struct {
	as, bs, cs *g.Bus
}

func NewOrrer(bas *g.Bus, bbs *g.Bus, bcs *g.Bus) *Orrer {
	this := &Orrer{bas, bbs, bcs}
	for j := 0; j < bas.GetSize(); j++ {
		g.NewOR(bas.GetWire(j), bbs.GetWire(j), bcs.GetWire(j))
	}
	return this
}

/*
XORER
*/
type XORer struct {
	as, bs, cs *g.Bus
	eqo, alo   *g.Wire
}

func NewXORer(bas *g.Bus, bbs *g.Bus, bcs *g.Bus, weqo *g.Wire, walo *g.Wire) *XORer {
	// Build the XORer circuit
	weqi := g.WireOn()
	wali := g.WireOff()
	for j := 0; j < bas.GetSize(); j++ {
		teqo := g.NewWire()
		talo := g.NewWire()
		te := teqo
		ta := talo
		if j == (bas.GetSize() - 1) {
			te = weqo
			ta = walo
		}
		g.NewCMP(bas.GetWire(j), bbs.GetWire(j), weqi, wali, bcs.GetWire(j), te, ta)
		weqi = teqo
		wali = talo
	}
	return &XORer{bas, bbs, bcs, weqo, walo}
}

/*
ZERO
*/
type Zero struct {
	is *g.Bus
	z  *g.Wire
}

func NewZero(bis *g.Bus, wz *g.Wire) *Zero {
	// Build the ZERO circuit
	wi := g.NewWire()
	g.NewORn(bis, wi)
	g.NewNOT(wi, wz)
	return &Zero{bis, wz}
}

/*
BUS1
*/
type Bus1 struct {
	is, os *g.Bus
	bit1   *g.Wire
}

func NewBus1(bis *g.Bus, wbit1 *g.Wire, bos *g.Bus) *Bus1 {
	// Build the BUS1 circuit
	wnbit1 := g.NewWire()
	g.NewNOT(wbit1, wnbit1)
	// Foreach AND circuit, connect to the wires.
	for j := 0; j < bis.GetSize(); j++ {
		if j < (bis.GetSize() - 1) {
			g.NewAND(bis.GetWire(j), wnbit1, bos.GetWire(j))
		} else {
			g.NewOR(bis.GetWire(j), wbit1, bos.GetWire(j))
		}
	}
	return &Bus1{bis, bos, wbit1}
}
