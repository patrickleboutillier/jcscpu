`include "src/defs.v"


module jmemory(input wi, input ws, output reg wo) ;
	wire wa, wb, wc ;

	/*	
 	jnand nand1(wi, ws, wa) ;
	jnand nand2(wa, ws, wb) ;
	jnand nand3(wa, wc, wo) ;
	jnand nand4(wo, wb, wc) ;
	*/

	always @(*) begin
		if (ws)
			wo <= wi ;
	end
endmodule


module jbyte(input [`ARCH_BITS-1:0] bis, input ws, output [`ARCH_BITS-1:0] bos) ;
	genvar j ;
	generate
		for (j = 0; j < `ARCH_BITS ; j = j + 1) begin
			jmemory mem(bis[j], ws, bos[j]) ;
		end
	endgenerate
endmodule


module jenabler(input [`ARCH_BITS-1:0] bis, input we, inout [`ARCH_BITS-1:0] bos) ;
	genvar j ;
	generate
		for (j = 0; j < `ARCH_BITS ; j = j + 1) begin
			wire out ;
			jand a(bis[j], we, out) ;
			assign bos[j] = (we) ? out : 1'bz ;
		end
	endgenerate
endmodule


module jregister(input [`ARCH_BITS-1:0] bis, input ws, input we, inout [`ARCH_BITS-1:0] bos) ;
	wire [`ARCH_BITS-1:0] bus ;
	jbyte byte(bis, ws, bus) ;
	jenabler enabler(bus, we, bos) ;
endmodule


module jdecoder #(parameter N=2, N2=4) (input [N-1:0] bis, output [N2-1:0] bos) ;
    wire [1:0] wmap[N-1:0] ;

	// Create our wire map
    genvar j ;
    generate
        for (j = 0; j < N ; j = j + 1) begin
			jnot notj(bis[j], wmap[j][0]) ;
			assign wmap[j][1] = bis[j] ;
        end
    endgenerate

    genvar k ;
    generate
        for (j = 0; j < N2 ; j = j + 1) begin
			wire [N-1:0] wos ;
        	for (k = 0; k < N ; k = k + 1) begin
				assign wos[k] = wmap[k][j[k]] ;
			end
			jandN #(N) andNj(wos, bos[j]) ;
        end
    endgenerate
endmodule

