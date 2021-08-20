module ram #(
	parameter G_ADDR_WIDTH = 4,
	parameter G_DATA_WIDTH = 8
)(
	input CLOCK, RST_N, RD_EN, WR_EN,
	input [G_ADDR_WIDTH-1 : 0] RD_ADDR, WR_ADDR,
	input [G_DATA_WIDTH-1 : 0] WR_DATA, 
	output reg [G_DATA_WIDTH-1 : 0] RD_DATA
);

localparam DEPTH_RAM = 2**G_ADDR_WIDTH;
reg [G_DATA_WIDTH-1 : 0] memory [0 : DEPTH_RAM-1];
integer count = 0;
reg reset_done;

always @(posedge CLOCK) begin
	if(!RST_N)
		reset_done <= 1'b1;
	else begin
		if ((count <(2**G_ADDR_WIDTH)) && reset_done==1'b1 ) begin
			memory[count] <= 0;
			count <= count + 1;
		end
		else begin
			count <= 0;
			reset_done <= 1'b0;
		end
		
		if (!reset_done) begin
			if (WR_EN)
				memory[WR_ADDR] <= WR_DATA;
			
			if(RD_EN)
				RD_DATA <= memory[RD_ADDR];
		end
	end
end

endmodule 