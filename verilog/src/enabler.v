`define ARCH_BITS 8

module jenabler(input [`ARCH_BITS-1:0] bis, input we, output [`ARCH_BITS-1:0] bos) ;
	genvar j ;
	generate
		for (j = 0; j < `ARCH_BITS; j = j + 1) begin
			jand a(bis[j], we, bos[j]) ;
		end
	endgenerate
endmodule
