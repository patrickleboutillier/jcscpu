`include "src/defs.v"


module jclock (input ref_clk, input reset, output reg wclk, output wclke, output wclks) ;
	always @(posedge ref_clk) begin
		if (reset)
			wclk <= 1'b0 ;
		else
			wclk <= ~wclk ;
	end

	reg wclkd ;
	always @(negedge ref_clk) begin
		if (reset)
			wclkd <= 1'b0 ;
		else
			wclkd <= ~wclkd ;
	end

	jor or1(wclk, wclkd, wclke) ;
	jand and1(wclk, wclkd, wclks) ;
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
