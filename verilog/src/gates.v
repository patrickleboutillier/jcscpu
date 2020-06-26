
module jnand(input wa, input wb, output wc) ;
	nand x(wc, wa, wb) ;
endmodule

module jnot(input wa, output wb) ;
	jnand x(wa, wa, wb) ;
endmodule

module jand(input wa, input wb, output wc) ;
	wire w ;
	jnand x(wa, wb, w) ;
	jnot y(w, wc) ;
endmodule

module jor(input wa, input wb, output wc) ;
	wire wic, wid ;
	jnot n1 (wa, wic) ;
	jnot n2 (wb, wid) ;
	jnand x(wic, wid, wc) ;
endmodule

module jconn(input wa, output wb) ;
	jand x(wa, wa, wb) ;
endmodule

/*
XOR

type XOR struct {
	a, b, c *Wire
}

func NewXOR(wa *Wire, wb *Wire, wc *Wire) *XOR {
	this := &XOR{wa, wb, wc}
	wic := NewWire()
	wid := NewWire()
	wie := NewWire()
	wif := NewWire()
	NewNOT(wa, wic)
	NewNOT(wb, wid)
	NewNAND(wic, wb, wie)
	NewNAND(wa, wid, wif)
	NewNAND(wie, wif, wc)
	return this
}

/*
ANDn

type ANDn struct {
	n  int
	is *Bus
	o  *Wire
}

func NewANDn(bis *Bus, wo *Wire) *ANDn {
	n := bis.GetSize()
	this := &ANDn{n, bis, wo}

	if n < 2 {
		log.Panicf("Invalid ANDn number of inputs %d", n)
	}

	var o *Wire
	if n == 2 {
		o = wo
	} else {
		o = NewWire()
	}
	last := NewAND(bis.GetWire(0), bis.GetWire(1), o)
	for j := 0; j < (n - 2); j++ {
		var o *Wire
		if n == (j + 3) {
			o = wo
		} else {
			o = NewWire()
		}
		next := NewAND(last.c, bis.GetWire(j+2), o)
		last = next
	}

	return this
}

/*
ORn

type ORn struct {
	n  int
	is *Bus
	o  *Wire
}

func NewORn(bis *Bus, wo *Wire) *ORn {
	n := bis.GetSize()
	this := &ORn{n, bis, wo}

	if n < 2 {
		log.Panicf("Invalid ORn number of inputs %d", n)
	}

	var o *Wire
	if n == 2 {
		o = wo
	} else {
		o = NewWire()
	}
	last := NewOR(bis.GetWire(0), bis.GetWire(1), o)
	for j := 0; j < (n - 2); j++ {
		if n == (j + 3) {
			o = wo
		} else {
			o = NewWire()
		}
		next := NewOR(last.c, bis.GetWire(j+2), o)
		last = next
	}

	return this
}

/*
ORe

type ORe struct {
	orn *ORn
	o   *Wire
	n   int
}

var OReSize int = 12

func NewORe(wo *Wire) *ORe {
	return &ORe{NewORn(NewBus(OReSize), wo), wo, 0}
}

func (this *ORe) AddWire(w *Wire) {
	if this.n >= OReSize {
		log.Panicf("Elastic OR has reached maximum capacity of OReSize")
	}
	NewCONN(w, this.orn.is.GetWire(this.n))
	this.n++
}

/*
ADD

type ADD struct {
	a, b, c, ci, co *Wire
}

func NewADD(wa *Wire, wb *Wire, wci *Wire, wc *Wire, wco *Wire) *ADD {
	wi := NewWire()
	wcoa := NewWire()
	wcob := NewWire()
	NewXOR(wa, wb, wi)
	NewXOR(wi, wci, wc)
	NewAND(wci, wi, wcoa)
	NewAND(wa, wb, wcob)
	NewOR(wcoa, wcob, wco)
	return &ADD{wa, wb, wc, wci, wco}
}

/*
CMP

type CMP struct {
	a, b, c, eqi, ali, eqo, alo *Wire
}

func NewCMP(wa *Wire, wb *Wire, weqi *Wire, wali *Wire, wc *Wire, weqo *Wire, walo *Wire) *CMP {
	w23 := NewWire()
	w45 := NewWire()
	NewXOR(wa, wb, wc)
	NewNOT(wc, w23)
	NewAND(weqi, w23, weqo)
	NewANDn(WrapBusV(weqi, wa, wc), w45)
	NewOR(wali, w45, walo)
	return &CMP{wa, wb, wc, weqi, wali, weqo, walo}
}
*/
