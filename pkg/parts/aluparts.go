package parts

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

/*
ADDER
*/
type ADDer struct {
	as, bs, cs *g.Bus
	ci, co     *g.Wire
}

func NewADDer(bas *g.Bus, bbs *g.Bus, wci *g.Wire, bcs *g.Bus, wco *g.Wire) *ADDer {
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
	return &ADDer{bas, bbs, bcs, wci, wco}
}

func (this *ADDer) String() string {
	return fmt.Sprintf("ADDER: a:%s  b:%s  ci:%s  c:%s  co:%s\n", this.as.String(), this.bs.String(), this.ci.String(),
		this.cs.String(), this.co.String())
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

func (this *ShiftRight) String() string {
	return fmt.Sprintf("SHIFTR: si:%s  i:%s  o:%s  so:%s\n", this.ci.String(), this.is.String(), this.os.String(), this.co.String())
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

func (this *ShiftLeft) String() string {
	return fmt.Sprintf("SHIFTR: i:%s  si:%s  so:%s  o:%s\n", this.is.String(), this.ci.String(), this.co.String(), this.os.String())
}

/*
NOTTER
*/
type NOTter struct {
	is, os *g.Bus
}

func NewNOTter(bis *g.Bus, bos *g.Bus) *NOTter {
	this := &NOTter{bis, bos}
	for j := 0; j < bis.GetSize(); j++ {
		g.NewNOT(bis.GetWire(j), bos.GetWire(j))
	}
	return this
}

func (this *NOTter) String() string {
	return fmt.Sprintf("NOTTER: a:%s  b:%s\n", this.is.String(), this.os.String())
}

/*
ANDDER
*/
type ANDder struct {
	as, bs, cs *g.Bus
}

func NewANDder(bas *g.Bus, bbs *g.Bus, bcs *g.Bus) *ANDder {
	this := &ANDder{bas, bbs, bcs}
	for j := 0; j < bas.GetSize(); j++ {
		g.NewAND(bas.GetWire(j), bbs.GetWire(j), bcs.GetWire(j))
	}
	return this
}

func (this *ANDder) String() string {
	return fmt.Sprintf("ANDDER: a:%s  b:%s  c:%s\n", this.as.String(), this.bs.String(), this.cs.String())
}

/*
ORRER
*/
type ORer struct {
	as, bs, cs *g.Bus
}

func NewORer(bas *g.Bus, bbs *g.Bus, bcs *g.Bus) *ORer {
	this := &ORer{bas, bbs, bcs}
	for j := 0; j < bas.GetSize(); j++ {
		g.NewOR(bas.GetWire(j), bbs.GetWire(j), bcs.GetWire(j))
	}
	return this
}

func (this *ORer) String() string {
	return fmt.Sprintf("ORER: a:%s  b:%s  c:%s\n", this.as.String(), this.bs.String(), this.cs.String())
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

func (this *XORer) String() string {
	return fmt.Sprintf("XORER: a:%s  b:%s  c:%s  eqo:%s  alo:%s\n", this.as.String(), this.bs.String(), this.cs.String(),
		this.eqo.String(), this.alo.String())
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

func (this *Zero) String() string {
	return fmt.Sprintf("ZERO: i:%s  z:%s\n", this.is.String(), this.z.String())
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

func (this *Bus1) String() string {
	return fmt.Sprintf("BUS1:%s/%s", this.is.String(), this.os.String())
}
