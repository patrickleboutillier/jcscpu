
module jnand(input wa, input wb, output wc) ;
	nand x(wc, wa, wb) ;
endmodule

module jnot(input wa, output wb) ;
	jnand x(wa, wa, wb) ;
endmodule

module jand(input wa, input wb, output wc) ;
	wire w ;
	jnand x(wa, wb, w) ;
	jnot y (w, wc) ;
endmodule

module gates_test() ;
	reg a ;
	reg b ;
	wire got ;

	jnand x(a, b, got) ;

	// generate clock
	reg clk ;
	always // no sensitivity list, so it always executes
		begin
			clk = 1; #5; clk = 0; #5; // 10ns period
		end

	reg reset ;
	reg [31:0] tv, errors ; 			// bookkeeping variables
	reg [3:0] tvs[0:1024] ; // array of testvectors
	initial // Will execute at the beginning once
		begin
			$readmemb("src/nand.tv", tvs, 0, 3) ; // Read vectors
			tv = 0; errors = 0; // Initialize
			reset = 1; #27; reset = 0; // Apply reset wait
		end

	// apply test vectors on rising edge of clk
	always @(posedge clk)
		begin
			#1; {a, b, expected} = tvs[tv] ;
		end

	// check results on falling edge of clk
	reg expected ;
	always @(negedge clk)
		if (~reset) // skip during reset
			begin
				if (got !== expected)
					begin
						$display("Error: inputs = %b, outputs = %b (%b expected)", {a, b}, got, expected) ;
						errors = errors + 1 ;
					end

					// increment array index and read next testvector
					tv = tv + 1 ;
					if (tvs[tv] === 4'bx)
						begin
							$display("%d tests completed with %d errors", tv, errors);
							$finish; // End simulation
						end
				end
endmodule


/*
type CONN struct {
	a, b *Wire
}

func NewCONN(wa *Wire, wb *Wire) *CONN {
	this := &CONN{wa, wb}
	NewAND(wa, wa, wb)
	return this
}

/*
AND
type AND struct {
	a, b, c *Wire
}

func NewAND(wa *Wire, wb *Wire, wc *Wire) *AND {
	this := &AND{wa, wb, wc}
	w := NewWire()
	NewNAND(wa, wb, w)
	NewNOT(w, wc)
	return this
}

func (this *AND) String() string {
	return fmt.Sprintf("AND[%s/%s/%s]", this.a.String(), this.b.String(), this.c.String())
}

/*
OR

type OR struct {
	a, b, c *Wire
}

func NewOR(wa *Wire, wb *Wire, wc *Wire) *OR {
	this := &OR{wa, wb, wc}
	wic := NewWire()
	wid := NewWire()
	NewNOT(wa, wic)
	NewNOT(wb, wid)
	NewNAND(wic, wid, wc)
	return this
}

func (this *OR) String() string {
	return fmt.Sprintf(" OR[%s/%s/%s]", this.a.String(), this.b.String(), this.c.String())
}

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
