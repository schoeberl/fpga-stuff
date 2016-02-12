
module hello_world (CLK_24MHZ, LED);

input CLK_24MHZ;
output [7:0] LED;

parameter CLK_FREQ = 24000000;
parameter BLINK_FREQ = 1;
parameter CNT_MAX = CLK_FREQ/BLINK_FREQ/2-1;

reg [24:0] cnt;
reg blink;

wire clk = CLK_24MHZ;

always @(posedge clk)
begin
  if (cnt==CNT_MAX) begin
    cnt <= 0;
    blink <= ~blink;
  end
  else begin
    cnt <= cnt+1;
  end
end

assign LED = {7'h7f, blink};

endmodule
