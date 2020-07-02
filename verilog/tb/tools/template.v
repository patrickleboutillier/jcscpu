
	reg [0:`INLEN-1] in ;
	wire [0:`OUTLEN-1] out ;

	reg [31:0] tv, errors ; // bookkeeping variables
	reg [0:`OUTLEN+`INLEN-1] tvs[0:`NBLINES-1] ; // array of testvectors

	initial begin // Will execute at the beginning once
		$readmemb(`TVFILE, tvs) ; // Read vectors
		tv = 0; errors = 0; // Initialize
		reset = 1; #97; reset = 0; 
	end

	// generate test clock
	reg tclk ;
	always begin 
		tclk = 1; #10; tclk = 0; #10; // 20ns period
	end

	// generate system clock
	always begin
		sclk = 1 ;
		#5 ;
		sclk = 0 ;
		#20 ;
		sclk = 1 ;
		#15 ; // 40ns period
	end

	// apply test vectors on rising edge of tclk
	reg [0:`OUTLEN-1] expected ;
	always @(posedge tclk) begin
		#1; {in[0:`INLEN-1], expected[0:`OUTLEN-1]} = tvs[tv] ;
	end

	// check results on falling edge of tclk
	reg [3*8:0] bang ;
	always @(negedge tclk)
		if (~reset) begin
			if (`VERBOSE == 1) begin
				$display("inputs = %b, outputs = %b (%b expected)", 
					in[0:`INLEN-1], out[0:`OUTLEN-1], expected[0:`OUTLEN-1]) ;
			end
			if (out[0:`OUTLEN-1] !== expected[0:`OUTLEN-1]) begin
				$display("Error: line = %d, inputs = %b, outputs = %b (%b expected)", tv+1, 
					in[0:`INLEN-1], out[0:`OUTLEN-1], expected[0:`OUTLEN-1]) ;
				errors = errors + 1 ;
			end

			// increment array index and read next testvector
			tv = tv + 1 ;
			if (tvs[tv][0] === 1'bx) begin
				bang = (errors == 0) ? "" : "!!!" ;
				$display("%d/%d tests completed with %d errors %s", tv, `NBLINES, errors, bang) ;
				$finish; // End simulation
			end
		end
endmodule
