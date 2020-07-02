`include "src/defs.v"


module jRAM #(parameter N=8) (input [`ARCH_BITS-1:0] bas, input wsa, inout [`ARCH_BITS-1:0] bio, input ws, input we) ;
	wire [`ARCH_BITS-1:0] busd ;
	reg on = 1 ;
	jregister MAR(bas, wsa, on, busd) ;

	/*
	localparam n = N / 2 ;
	localparam n2 = 1 << n ;
	wire [n2-1:0] wxs, wys ;
	jdecoder #(n, n2) decx(busd[n-1:0], wxs) ;
	jdecoder #(n, n2) decy(busd[N-1:n], wys) ;

	genvar x, y ;
	generate
		for (x = 0 ; x < n2 ; x = x + 1) begin
			for (y = 0 ; y < n2 ; y = y + 1) begin
				wire wxo, wso, weo ;
				jand and1(wxs[x], wys[y], wxo) ;
				jand and2(wxo, ws, wso) ;
				jand and3(wxo, we, weo) ;

				jregister regxy(bio, wso, weo, bio) ;
			end
		end
	endgenerate
	*/

	reg [`ARCH_BITS-1:0] RAM[0:(1<<`ARCH_BITS)-1] ;
	assign bio = (we) ? RAM[busd] : {`ARCH_BITS{1'bz}} ;
	always @(ws) begin
		if (ws)
			RAM[busd] = bio ;
	end
endmodule

/*
func NewRAMClassic(bas *g.Bus, wsa *g.Wire, bio *g.Bus, ws *g.Wire, we *g.Wire) *RAM {
	// Build the RAM circuit
	on := g.WireOn()
	busd := g.NewBus(bas.GetSize())
	mar := NewRegister(bas, wsa, on, busd, "MAR")

	n := bas.GetSize() / 2
	n2 := 1 << n
	wxs := g.NewBus(n2)
	wys := g.NewBus(n2)
	NewDecoder(g.WrapBus(busd.GetWires()[0:n]), wxs)
	NewDecoder(g.WrapBus(busd.GetWires()[n:busd.GetSize()]), wys)

	// Now we create the circuit
	cells := make([]*Register, n2*n2, n2*n2)
	for x := 0; x < n2; x++ {
		for y := 0; y < n2; y++ {
			// Create the subcircuit to be used at each location
			wxo := g.NewWire()
			wso := g.NewWire()
			weo := g.NewWire()
			g.NewAND(wxs.GetWire(x), wys.GetWire(y), wxo)
			g.NewAND(wxo, ws, wso)
			g.NewAND(wxo, we, weo)
			idx := (x * n2) + y

			cells[idx] = NewRegister(bio, wso, weo, bio, fmt.Sprintf("RAM[%d]", idx))
		}
	}

	this := &RAM{bas, bio, wsa, ws, we, mar, cells, n2 * n2, false, -1, nil}

	return this
}
*/
