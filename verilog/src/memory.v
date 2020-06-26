
module jmemory(input wi, input ws, output wo) ;
	wire wa, wb, wc ;
	
 	jnand nand1(wi, ws, wa) ;
	jnand nand2(wa, ws, wb) ;
	jnand nand3(wa, wc, wo) ;
	jnand nand4(wo, wb, wc) ;
endmodule

