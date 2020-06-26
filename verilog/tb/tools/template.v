
	reg [0:`INLEN-1] in ;
	wire [0:`OUTLEN-1] out ;

	reg reset ;
	reg [31:0] tv, errors ; // bookkeeping variables
	reg [`OUTLEN+`INLEN-1:0] tvs[0:`NBLINES-1] ; // array of testvectors
	initial // Will execute at the beginning once
		begin
			$readmemb(`TVFILE, tvs) ; // Read vectors
			tv = 0; errors = 0; // Initialize
			reset = 1; #27; reset = 0; 
		end

	// generate clock
	reg clk ;
	always // no sensitivity list, so it always executes
		begin
			clk = 1; #5; clk = 0; #5; // 10ns period
		end

	reg [0:`OUTLEN-1] expected ;
	// apply test vectors on rising edge of clk
	always @(posedge clk)
		begin
			#1; {in[0:`INLEN-1], expected[0:`OUTLEN-1]} = tvs[tv] ;
		end

	// check results on falling edge of clk
	reg [3*8:0] bang ;
	always @(negedge clk)
		if (~reset)
			begin
				// $display("inputs = %b, outputs = %b (%b expected)", 
				//	in[0:`INLEN-1], out[0:`OUTLEN-1], expected[0:`OUTLEN-1]) ;
				if (out[0:`OUTLEN-1] !== expected[0:`OUTLEN-1])
					begin
						$display("Error: line = %d, inputs = %b, outputs = %b (%b expected)", tv+1, 
							in[0:`INLEN-1], out[0:`OUTLEN-1], expected[0:`OUTLEN-1]) ;
						errors = errors + 1 ;
					end

					// increment array index and read next testvector
					tv = tv + 1 ;
					if (tvs[tv][0] === 1'bx)
						begin
							bang = (errors == 0) ? "" : "!!!" ;
							$display("%d tests completed with %d errors %s", tv, errors, bang) ;
							$finish; // End simulation
						end
			end
endmodule