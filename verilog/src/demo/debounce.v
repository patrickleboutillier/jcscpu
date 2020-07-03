module debounce (input clk, input pbi, output pbo);
 
  parameter DEBOUNCE_LIMIT = 1000000 ;  // 10 ms at 100 MHz
   
  reg [19:0] count = 0 ;
  reg state = 1'b0 ;
 
  always @(posedge clk) begin
    // Switch input is different than internal switch value, so an input is
    // changing.  Increase the counter until it is stable for enough time.  
    if (pbi !== state && count < DEBOUNCE_LIMIT)
      count <= count + 1 ;
 
    // End of counter reached, switch is stable, register it, reset counter
    else if (count == DEBOUNCE_LIMIT) begin
      state <= pbi;
      count <= 0 ;
    end 
 
    // Switches are the same state, reset the counter
    else
      count <= 0 ;
  end
 
  // Assign internal register to output (debounced!)
  assign pbo = state ;
endmodule
