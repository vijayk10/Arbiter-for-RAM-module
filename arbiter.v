module arbiter #(
	parameter G_ADDR_WIDTH = 4,
	parameter G_DATA_WIDTH = 8,
	parameter G_REGISTERED_DATA = 0)
(
	input RST_N, CLOCK,
	output RST_DONE,
	
	input RD_EN_C1, WR_EN_C1,	//read enable, write enable
	input [G_ADDR_WIDTH-1 : 0] RDADDR_C1, WRADDR_C1,	//read address, write address
	input [G_DATA_WIDTH-1 : 0] WRDATA_C1,
	
	input [G_DATA_WIDTH-1 : 0] DATAIN_C2,
	input REQUEST_C2, RD_NOT_WRITE_C2, 	// request for memory access and read-write_bar
	input [G_ADDR_WIDTH-1 : 0] ADDR_C2, 	// this address is for both read and write one at a time
	
	output [G_DATA_WIDTH-1 : 0] RDDATA_C1,	//data out for client1/user1
	
	output [G_DATA_WIDTH-1 : 0] DATAOUT_C2,	//data out for client2/user2
	output ACK_C2,		// acknowledgement in case of client2, since it will not be given access immediately since priority is more of client1
	
	output RD_EN, WR_EN,
	output [G_ADDR_WIDTH-1 : 0] WR_ADDR, RD_ADDR,
	output [G_DATA_WIDTH-1 : 0] WR_DATA,
	input [G_DATA_WIDTH-1 : 0] RD_DATA
);

reg [G_DATA_WIDTH-1 : 0] TEMP_RD_DATA, TEMP_RD_DATA1, TEMP_RD_DATA2;
reg TEMP_RD_EN, TEMP_WR_EN;
reg [G_ADDR_WIDTH-1 : 0] TEMP_WR_ADDR, TEMP_RD_ADDR;
reg [G_DATA_WIDTH-1 : 0] TEMP_WR_DATA;

localparam [2:0] reset=3'b000, idle=3'b001, client1_read=3'b010, client2_read=3'b011, client1_write=3'b100, client2_write=3'b101; 

reg [2:0] pr_client_read, pr_client_write, nx_client_read, nx_client_write;

reg TEMP_ACK = 0, TEMP_ACK1, TEMP_ACK2, TEMP_WR=0;
wire TEMP_WR1;

wire REGISTERED_DATA = 0;
reg RESET_DONE_REG;

integer COUNT = 0;

reg ADDR_CLASHI=0, ADDR_CLASH=0;

always @(posedge CLOCK, negedge RST_N) begin
	if (!RST_N) begin
		pr_client_read <= reset;
		pr_client_write <= reset;
	end
	else begin
		pr_client_read <= nx_client_read;
		pr_client_write <= nx_client_write;
	end
end

generate
	if (G_REGISTERED_DATA) begin : g1
		assign REGISTERED_DATA = G_REGISTERED_DATA;
	end
endgenerate

always @(pr_client_read,pr_client_write,CLOCK) begin
	if (RST_N & CLOCK) begin
		if (nx_client_read==reset && nx_client_write==reset) begin
			if (COUNT < (2**G_ADDR_WIDTH)) begin
				RESET_DONE_REG <= 1'b0;
				COUNT <= COUNT + 1;
			end
			else begin
				nx_client_read = idle;
				nx_client_write = idle;
				RESET_DONE_REG = 1'b1;
				COUNT = 0;
			end
		end
	end
	else if(!RST_N) begin
		nx_client_read = reset;
		nx_client_write = reset;
	end
	
	if (pr_client_read == idle) begin		// arbiter in idle
		if (!RD_EN_C1) begin
			if (!REQUEST_C2)
				nx_client_read = idle;
			else if (RD_NOT_WRITE_C2)
				nx_client_read = client2_read;
			else if (!RD_NOT_WRITE_C2)
				nx_client_write = client2_write;
		end
		else
			nx_client_read = client1_read;
	end
	
	if (pr_client_write == idle) begin
		if (!WR_EN_C1) begin
			if (!REQUEST_C2)
				nx_client_write = idle;
			else if (!RD_NOT_WRITE_C2)
				nx_client_write = client2_write;
			else if (RD_NOT_WRITE_C2)
				nx_client_read = client2_read;
		end
		else
			nx_client_write = client1_write;
	end
	
	if (pr_client_read == client1_read) begin		// arbiter allow client1
		if (RD_EN_C1)
			nx_client_read = client1_read;
		else begin
			if (!REQUEST_C2)
				nx_client_read = idle;
			else if (RD_NOT_WRITE_C2)
				nx_client_read = client2_read;
			else if (!RD_NOT_WRITE_C2)
				nx_client_read = idle;
		end
	end
	
	if (pr_client_write == client1_write) begin
		if (WR_EN_C1)
			nx_client_write = client1_write;
		else begin
			if (!REQUEST_C2)
				nx_client_write = idle;
			else if (!RD_NOT_WRITE_C2)
				nx_client_write = client2_write;
			else if (RD_NOT_WRITE_C2)
				nx_client_write = idle;
		end
	end
	
	if (pr_client_read == client2_read) begin 	// arbiter allow client2
		if (!RD_EN_C1) begin
			if (REQUEST_C2) begin
				if (RD_NOT_WRITE_C2)
					nx_client_read = client2_read;
				else begin
					nx_client_read = idle;
					nx_client_write = client2_write;
				end
			end
			else
				nx_client_read = idle;
		end
		else
			nx_client_read = client1_read;
	end
	
	if (pr_client_write == client2_write) begin
		if (!WR_EN_C1) begin
			if (REQUEST_C2) begin
				if (!RD_NOT_WRITE_C2)
					nx_client_write = client2_write;
				else begin
					nx_client_write = idle;
					nx_client_read = client2_read;
				end
			end
			else
				nx_client_write = idle;
		end
		else
			nx_client_write = client1_write;
	end
	
end

////////////////////////////////

always @(posedge CLOCK) begin
	if (!RST_N) begin
		TEMP_RD_DATA <= 0;
		TEMP_RD_DATA1 <= 0;
		TEMP_RD_DATA2 = 0;
	end
	else begin
		if (nx_client_read == idle) begin
			TEMP_RD_EN <= 1'b0;
			TEMP_RD_ADDR <= 0;
		end
		else if (nx_client_read == client1_read) begin
			TEMP_RD_EN <= RD_EN_C1;
			TEMP_RD_ADDR <= RDADDR_C1;
		end
		else if (nx_client_read == client2_read) begin
			if (!TEMP_ACK) begin
				TEMP_RD_EN <= 1'b1;
				TEMP_RD_ADDR <= ADDR_C2;
				TEMP_ACK <= 1'b1;
			end
		end
		
		if (nx_client_write == idle) begin
			TEMP_WR_EN <= 1'b0;
			TEMP_WR_DATA <= 0;
			TEMP_WR_ADDR <= 0;
		end
		else if (nx_client_write == client1_write) begin
			TEMP_WR_EN <= WR_EN_C1;
			TEMP_WR_DATA <= WRDATA_C1;
			TEMP_WR_ADDR <= WRADDR_C1;
		end
		else if (nx_client_write == client2_write) begin
			if (!TEMP_WR) begin
				TEMP_WR_EN <= 1'b1;
				TEMP_WR_ADDR <= ADDR_C2;
				TEMP_WR_DATA <= DATAIN_C2;
				TEMP_WR <= 1'b1;
			end
		end
		
		/////// addr clash //////
		if (TEMP_RD_EN & TEMP_WR_EN) begin
			if (TEMP_WR_ADDR == TEMP_RD_ADDR) begin
				ADDR_CLASH <= 1'b1;
				TEMP_RD_DATA <= TEMP_WR_DATA;
			end
			else
				ADDR_CLASH <= 1'b0;
		end
		else
			ADDR_CLASH <= 1'b0;
			
		////////////////////////////
		if (TEMP_WR1)
			TEMP_WR <= 1'b0;
		
		TEMP_ACK1 <= TEMP_ACK;
		
		if (TEMP_ACK1) begin
			TEMP_ACK1 <= 1'b0;
			TEMP_ACK <= 1'b0;
		end
		
		ADDR_CLASHI <= ADDR_CLASH;
		TEMP_RD_DATA1 <= TEMP_RD_DATA;
		TEMP_RD_DATA2 <= RD_DATA;
		
	end
end

/////////////////////////
assign RD_EN = TEMP_RD_EN;
assign WR_EN = TEMP_WR_EN;
assign WR_DATA = TEMP_WR_DATA;
assign WR_ADDR = TEMP_WR_ADDR;
assign RD_ADDR = TEMP_RD_ADDR;

assign TEMP_WR1 = TEMP_WR;
assign ACK_C2 = (TEMP_ACK1 | TEMP_WR1) ? 1'b1 : 1'b0;
assign RST_DONE = RESET_DONE_REG;

assign DATAOUT_C2 = (!ADDR_CLASH) ? RD_DATA : TEMP_RD_DATA;

assign RDDATA_C1 = (REGISTERED_DATA ==0 && ADDR_CLASH==1'b0 ) ? RD_DATA :
						  (REGISTERED_DATA ==0 && ADDR_CLASH==1'b1 ) ? TEMP_RD_DATA :
						  (REGISTERED_DATA ==1 && ADDR_CLASHI==1'b0 ) ? TEMP_RD_DATA2 :
						  (REGISTERED_DATA ==1 && ADDR_CLASHI==1'b1 ) ? TEMP_RD_DATA1 : RDDATA_C1;

endmodule 