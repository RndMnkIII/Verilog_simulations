// Purpose: Synchronous 4-bit up/down binary counter
// Western: 74sn169
//Setup time: 20ns, Hold time: 0ns
//FIXED module by factoring out the rco signal from the posedge clk event
module ttl_74169
(
  input clk,
  input direction, // 1 = Up, 0 = Down
  input load_n,    // 1 = Count, 0 = Load
  input ent_n,
  input enp_n,
  input [3:0] P,

  output rco_n,    // Ripple Carry-out (RCO)
  output [3:0] Q   // 4-bit output
);

localparam counter_74169_delay = 15; // Min propagation delay from datasheet
localparam rco_74169_delay = 10;

//reg rco = 1'b0;
reg [3:0] count = 0;

always @(posedge clk) begin
  if (~load_n)
  begin
    count <= #counter_74169_delay P;
    //rco <= #rco_74169_delay 1'b1; //1'b1
  end
  else if (~ent_n & ~enp_n) // Count only if both enable signals are active (low)
  begin
    if (direction)
    begin
      // Counting up
      count <= #counter_74169_delay count + 1;
      //rco <= #rco_74169_delay ~count[0] & count[1] & count[2] & count[3] & ~ent_n;    // Counted till 14 ('b1110) and active (low) ent_n
    end
    else
    begin
      // Counting down
      count <= #counter_74169_delay count - 1;
      //rco <= #rco_74169_delay ~(~count[0] | count[1] | count[2] | count[3]) & ~ent_n; // Counted till 1 ('b0001) and active (low) ent_n
    end
  end
end

assign Q = count;
//assign rco_n = ~rco;
assign #rco_74169_delay rco_n = !load_n ? 1'b0: ~((&count) & ~ent_n); 

endmodule