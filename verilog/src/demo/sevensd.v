`include "src/defs.v"


module sevensd(input [7:0] char, output [6:0] leds) ;
always @(*) begin
	case(char)
		"0": leds = 7'b0000001; // "0"  
		"1": leds = 7'b1001111; // "1" 
		"2": leds = 7'b0010010; // "2" 
		"3": leds = 7'b0000110; // "3" 
		"4": leds = 7'b1001100; // "4" 
		"5": leds = 7'b0100100; // "5" 
		"6": leds = 7'b0100000; // "6" 
		"7": leds = 7'b0001111; // "7" 
		"8": leds = 7'b0000000; // "8"  
		"9": leds = 7'b0000100; // "9" 
		default: leds = 7'b1111111; // " "
	 endcase
end
endmodule

module display(input [(4*8)-1:0] word, output [(4*7)-1:0] leds) ;
	genvar j ;
	generate
		for (j = 3 ; j <= 0 ; j = j - 1) begin
			sevensd c(word[(j*8)+7:j*8], leds[(j*8)+6:j*7]) ;
		end
	endgenerate
endmodule
