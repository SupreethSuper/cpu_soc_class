 module pipe_ex_mem #( 
	parameter BITS=32,                   	 // default number of bits per word
   	parameter REG_WORDS=32,              	 // default number of words in the regfile
   	parameter ADDR_LEFT=$clog2(REG_WORDS)-1 // log base 2 of the number of word
	)
	(
	input             	clk,  // system clock
	input			rst_, // system reset
	input [BITS-1:0]	alu_out,
	input 			atomic_s3,
	input 			sel_mem_s3,
    	input			check_link_s3,
	input			mem_rw_s3,
	input			rw_s3,
	input [ADDR_LEFT:0] 	waddr_s3,
	input 			load_link_s3,
	input [BITS-1:0]	r2_data_s3,
	input [3:0]		byte_en_s3,
	input			halt_s3,

	output logic [BITS-1:0]		alu_out_s4,
	output logic 			atomic_s4,
	output logic 			sel_mem_s4,
    	output logic			check_link_s4,
	output logic			mem_rw_s4,
	output logic			rw_s4,
	output logic [ADDR_LEFT:0] 	waddr_s4,
	output logic 			load_link_s4,
	output logic [BITS-1:0]		r2_data_s4,
	output logic [3:0]		byte_en_s4,
	output logic			halt_s4
	);
        localparam ONE  = 1'b1;
	localparam ZERO = 1'b0;
	
	always @(posedge clk )
		begin
		if(~(rst_))
		begin  //
		rw_s4      	<= ONE;
 		mem_rw_s4   	<= ONE;
    		sel_mem_s4    	<= ZERO;
    		byte_en_s4	<= 4'hF;
    		load_link_s4 	<= ONE;
    		check_link_s4 	<= ZERO;
    		atomic_s4     	<= ZERO;
    		halt_s4    	<= ZERO;
		end
	

		else
		begin
		alu_out_s4      <=	alu_out;
		atomic_s4 	<= 	atomic_s3;
		sel_mem_s4 	<= 	sel_mem_s3;
		check_link_s4 	<= 	check_link_s3;
		mem_rw_s4 	<= 	mem_rw_s3;
		rw_s4 		<=	rw_s3;
		waddr_s4 	<= 	waddr_s3;
		load_link_s4 	<= 	load_link_s3;
		r2_data_s4 	<= 	r2_data_s3;
		byte_en_s4 	<=	byte_en_s3;
		halt_s4		<= 	halt_s3;
		end
		end 
endmodule
