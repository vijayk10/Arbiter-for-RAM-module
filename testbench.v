module testbench;

reg RST_N=0, CLOCK=0, RD_EN_C1=0, WR_EN_C1=0;
reg [3:0] RDADDR_C1=0, WRADDR_C1=0;
reg [7:0] WRDATA_C1=0, INDATA_C2=0;
reg REQUEST_C2=0, RD_WRITE_BAR_C2=0;
reg [3:0] ADDR_C2 = 0;
wire RST_DONE;
wire [7:0] RDDATA_C1, OUTDATA_C2;
wire ACK_C2;

localparam CLOCK_period = 50;

ram_arbiter dut (.RST_N(RST_N),
.CLOCK(CLOCK),
.RST_DONE(RST_DONE),
.RD_EN_C1(RD_EN_C1),
.WR_EN_C1(WR_EN_C1),
.RDADDR_C1(RDADDR_C1),
.WRADDR_C1( WRADDR_C1),
.WRDATA_C1( WRDATA_C1),
.REQUEST_C2( REQUEST_C2),
.RD_NOT_WRITE_C2( RD_WRITE_BAR_C2),
.ADDR_C2( ADDR_C2),
.DATAIN_C2( INDATA_C2),
.DATAOUT_C2(OUTDATA_C2),
.ACK_C2(ACK_C2),
.RDDATA_C1(RDDATA_C1));


always begin
	#(CLOCK_period/2)
	CLOCK = 0;
	#(CLOCK_period/2)
	CLOCK = 1;
end

always begin
	#100
	
	//////////Test case 1 = Only Client1 wants to write/////////////
//	RST_N = 1;
//	#500
//	WR_EN_C1 = 1;
//	WRADDR_C1 <=4'b1110;
//	WRDATA_C1 <=8'b111001011;
	
	////////Test case2 = Only Client1 wants to read /////////////////
//	RST_N = 1;
//	#500
//	WR_EN_C1 = 1'b1;
//	WRADDR_C1 = 4'b1010;
//	WRDATA_C1 = 8'b10100101;
//	#1700
//	WR_EN_C1 = 1'b0;
//	RD_EN_C1 = 1'b1;
//	RDADDR_C1 = 4'b1010;
	
	/////////Test case3 = Only Client2 wants to write ////////////////
//	RST_N =1'b1;
//	WR_EN_C1 = 1'b0;
//	REQUEST_C2 = 1'b1;
//	RD_WRITE_BAR_C2 = 1'b0;
//	ADDR_C2 =4'b1110;
//	INDATA_C2 =8'b11100011;
	
	//////Test Case4 = Only Client2 wants to read//////////////
//	RST_N = 1;
//	WR_EN_C1 = 0;
//	REQUEST_C2 = 1;
//	RD_WRITE_BAR_C2 = 0;
//	ADDR_C2  = 4'b0110;
//	INDATA_C2 = 8'b10011101;
//	#1700
//	WR_EN_C1 = 0;
//	RD_WRITE_BAR_C2 = 1;
//	ADDR_C2 = 4'b0110;
	
	///////Test case 5 = Client1 wants to read and write in different RAM location at same time
//	RST_N = 1;
//	#500
//	WR_EN_C1 = 1;
//	WRADDR_C1 = 4'b1010;
//	WRDATA_C1 = 8'b10100001;
//	#1700
//	RD_EN_C1 = 1;
//	RDADDR_C1 = 4'b1010;
//	WRADDR_C1 = 4'b1110;
//	WRDATA_C1 = 8'b10111011;
	
	///////////Test Case 6 = Client1 wants to read and write in same RAM location at same time
//	RST_N = 1;
//	#500
//	WR_EN_C1 = 1;
//	WRADDR_C1 = 4'b1000;
//	WRDATA_C1 = 8'b10100011;
//	#1700
//	RD_EN_C1 = 1;
//	RDADDR_C1 = 4'b1000;
//	WRADDR_C1 = 4'b1000;
//	WRDATA_C1 = 8'b10111011;
		
	////////////////Test Case 7 = Client2 wants to read and write in different RAM location at same time. ///
//	RST_N = 1;
//	WR_EN_C1 = 0;
//	RD_EN_C1 = 0;
//	REQUEST_C2 = 1;
//	RD_WRITE_BAR_C2 = 0;
//	ADDR_C2  = 4'b1010;
//	INDATA_C2 = 8'b11100011;
//	#1700
//	RD_WRITE_BAR_C2 = 0;
//	ADDR_C2 = 4'b1001;
//	INDATA_C2 = 8'b00100011;
//	RD_WRITE_BAR_C2 = 1;
//	ADDR_C2 = 4'b1010;
	
	////////Test Case 8 = Client2 wants to read and write in same RAM location at same time. ////////
//	RST_N = 1;
//	WR_EN_C1 = 0;
//	RD_EN_C1 = 0;
//	REQUEST_C2 = 1;
//	RD_WRITE_BAR_C2 = 0;
//	ADDR_C2 = 4'b0101;
//	INDATA_C2 = 8'b00100011;
//	#1700
//	RD_WRITE_BAR_C2 = 1;
//	ADDR_C2 = 4'b0101;
//	RD_WRITE_BAR_C2 = 0;
//	ADDR_C2 = 4'b0101;
//	INDATA_C2 = 8'b00111011;
	
	///////Test Case 9 = Client1 wants to write and client2 wants to read in same RAM location at same time ////
//	RST_N = 1;
//	WR_EN_C1 = 0;
//	REQUEST_C2 = 1;
//	RD_WRITE_BAR_C2 = 0;
//	ADDR_C2 = 4'b1111;
//	INDATA_C2 = 8'b11100011;
//	#1700
//	WR_EN_C1 = 1;
//	RD_EN_C1 = 0;
//	WRADDR_C1 = 4'b1111;
//	WRDATA_C1 = 8'b10111011;
//	REQUEST_C2 = 1;
//	RD_WRITE_BAR_C2 = 1;
//	ADDR_C2 = 4'b1111;
	
	////////Test Case 10 = Client1 wants to read and Client2 wants to write in same RAM location at same time ///
//	RST_N = 1;
//	WR_EN_C1 = 1;
//	RD_EN_C1 = 0;
//	WRADDR_C1 = 4'b1001;
//	WRDATA_C1 = 8'b10101111;
//	#1700
//	RD_EN_C1 = 1;
//	WR_EN_C1 = 0;
//	RDADDR_C1 = 4'b1001;
//	REQUEST_C2 = 1;
//	RD_WRITE_BAR_C2 = 0;
//	ADDR_C2 = 4'b1001;
//	INDATA_C2 = 8'b10111011;
	
	///////Test Case 11 = Client1 wants to read and Client2 wants to read in different RAM location at same time.
//	RST_N = 1;
//	WR_EN_C1 = 1;
//	RD_EN_C1 = 0;
//	WRADDR_C1 = 4'b1001;
//	WRDATA_C1 = 8'b10101111;
//	#1700
//	RD_EN_C1 = 1;
//	WR_EN_C1 = 0;
//	RDADDR_C1 = 4'b1001;
//	REQUEST_C2 = 1;
//	RD_WRITE_BAR_C2 = 1;
//	ADDR_C2 = 4'b0010;
	
	//////Test Case 12 = Client1 wants to read and write in the same RAM location and Client2 also wants to read in the RAM location where Client1 has written at same time//
	RST_N = 1;
	WR_EN_C1 = 1;
	RD_EN_C1 = 0;
	WRADDR_C1 = 4'b1001;
	WRDATA_C1 = 8'b10101111;
	#1700
	RD_EN_C1 = 1;
	RDADDR_C1 = 4'b1001;
	WRADDR_C1 = 4'b1001;
	WRDATA_C1 = 8'b10100011;
	REQUEST_C2 = 1;
	RD_WRITE_BAR_C2 = 1;
	ADDR_C2 = 4'b1001;
	
	
	#500
	$finish;
end

endmodule 