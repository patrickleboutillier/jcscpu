
module demo ;

	wire mode_btn_src, mode_btn_deb ;
	wire [27:0] leds ;

	debounce mode_deb(clk, mode_btn_src, mode_btn_deb) ;

	// Word display
	reg [31:0] word ;
	display w(word, leds) ;

	reg cnt = 0 ;
	reg max = 1 ;
	always @(posedge mode_btn_deb) begin
		case(cnt)
			0: word = " and" ;
			1: word = " not" ;
		endcase
		cnt = cnt + 1 ;
		if (cnt > max)
			cnt = 0 ;
	end
endmodule
