module pipe_mem_wb #(
	parameter BITS=32,                   	 // default number of bits per word
   	parameter REG_WORDS=32,              	 // default number of words in the regfile
   	parameter ADDR_LEFT=$clog2(REG_WORDS)-1 // log base 2 of the number of word
	)
	(
	input             	clk,  // system clock
	input			rst_, // system reset
	input [BITS-1:0]	alu_out_s4,
	input 			atomic_s4,
	input 			link_rw_,
	input [BITS-1:0]	d_mem_rdata,
	input 			sel_mem_s4,
	input			rw_s4,
	input [ADDR_LEFT:0] 	waddr_s4,
	input [3:0]		byte_en_s4,
	input			halt_s4,	

	output logic [BITS-1:0]		alu_out_s5, 			
	output logic 			atomic_s5,
	output logic 			sel_mem_s5,
    	output logic [BITS-1:0]		d_mem_rdata_s5,
	output logic			link_rw_s5,
	output logic			rw_s5,
	output logic [ADDR_LEFT:0] 	waddr_s5,
	output logic [3:0]		byte_en_s5,
	output logic			halt_s5
	);
	localparam ONE  = 1'b1;
	localparam ZERO = 1'b0;

always @(posedge clk )
		begin
		if(~(rst_))
		begin  //
    		sel_mem_s5    	<= ZERO;
    		byte_en_s5	<= 4'hF;
    		atomic_s5     	<= ZERO;
    		halt_s5    	<= ZERO;
		end
	

		else
		begin
		alu_out_s5      <=	alu_out_s4;
		atomic_s5 	<= 	atomic_s4;
		sel_mem_s5 	<= 	sel_mem_s4;
		d_mem_rdata_s5  <=	d_mem_rdata;
		link_rw_s5      <=      link_rw_;
		rw_s5 		<=	rw_s4;
		waddr_s5 	<= 	waddr_s4;
		byte_en_s5 	<=	byte_en_s4;
		halt_s5		<= 	halt_s4;
		end
		end
endmodule
