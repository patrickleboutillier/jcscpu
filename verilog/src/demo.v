
module demo ;

	wire next_btn ;
	wire [27:0] leds ;

	// Word display
	reg [31:0] word ;
	display w(word, leds) ;

	reg cnt = 0 ;
	reg max = 1 ;
	always @(posedge next_btn) begin
		case(cnt)
			0: word = " and" ;
			1: word = " not" ;
		endcase
		cnt = cnt + 1 ;
		if (cnt > max)
			cnt = 0 ;
	end
endmodule
