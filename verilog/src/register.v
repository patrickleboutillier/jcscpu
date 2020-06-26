`include "src/defs.v"

module jregister(input [`ARCH_BITS-1:0] bis, input ws, input we, output [`ARCH_BITS-1:0] bos) ;
	wire [`ARCH_BITS-1:0] bus ;
	jbyte byte(bis, ws, bus) ;
	jenabler enabler(bus, we, bos) ;
endmodule
