`include "src/defs.v"


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


module jxor(input wa, input wb, output wc) ;
	wire wic, wid, wie, wif ;
	jnot not1(wa, wic) ;
	jnot not2(wb, wid) ;
	jnand nand1(wic, wb, wie) ;
	jnand nand2(wa, wid, wif) ;
	jnand nand3(wie, wif, wc) ;
endmodule


module jadd(input wa, input wb, input wci, output wc, output wco) ;
	wire wi, wcoa, wcob ;
	jxor xor1(wa, wb, wi) ;
	jxor xor2(wi, wci, wc) ;
	jand and1(wci, wi, wcoa) ;
	jand and2(wa, wb, wcob) ;
	jor or1(wcoa, wcob, wco) ;
endmodule


module jconn(input wa, output wb) ;
	jand x(wa, wa, wb) ;
endmodule


module jbuf(input wa, output wb) ;
	jconn x(wa, wb) ;
endmodule


module jandN #(parameter N=2) (input [N-1:0] bis, output wo) ;
	wire [N-2:0] os ;
	
	jand and0(bis[0], bis[1], os[0]) ;

	genvar j ;
	generate
		for (j = 0; j < (N - 2); j = j + 1) begin
			jand andj(os[j], bis[j+2], os[j+1]) ;
		end
	endgenerate

	assign wo = os[N-2] ;
endmodule


module jorN #(parameter N=2) (input [N-1:0] bis, output wo) ;
	wire [N-2:0] os ;
	
	jor or0(bis[0], bis[1], os[0]) ;

	genvar j ;
	generate
		for (j = 0; j < (N - 2); j = j + 1) begin
			jor orj(os[j], bis[j+2], os[j+1]) ;
		end
	endgenerate

	assign wo = os[N-2] ;
endmodule


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
