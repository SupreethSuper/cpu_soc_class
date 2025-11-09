module pipe_id_ex 
       #(
   parameter BITS=32,                   // default number of bits per word
   parameter REG_WORDS=32,              // default number of words in the regfile
   parameter ADDR_LEFT=$clog2(REG_WORDS)-1, // log base 2 of the number of words
                                        // which is # of bits needed to address
                                        // the memory for read and write
   parameter OP_BITS=4,                 // bits needed to define operations
   parameter SHIFT_BITS=5,              // bits needed to define shift amount
   parameter JMP_LEFT=25,               // left bit of the jump target
   parameter IMM_LEFT=BITS/2            // number of bits in immediate field
	)
	(
	input             	clk,  // system clock
	input			rst_, // system reset
 	input 			atomic,
	input 			sel_mem,
    	input			check_link,
	input			mem_rw_,
	input			rw_,
	input [ADDR_LEFT:0] 	waddr_,
	input 			load_link_,
	input [BITS-1:0]	r2_data,
	input [BITS-1:0]	r1_data,
	input			alu_imm,
	input [BITS-1:0]	sign_ext_imm,
	input [SHIFT_BITS-1:0]	shamt,
	input [OP_BITS-1:0] 	alu_op,
	input [3:0]		byte_en,
	input			halt_s2,
	input [ADDR_LEFT : 0] r1_addr,
	input [ADDR_LEFT : 0] r2_addr,

	output logic 			atomic_s3,
	output logic 			sel_mem_s3,
    	output logic			check_link_s3,
	output logic			mem_rw_s3,
	output logic			rw_s3,
	output logic [ADDR_LEFT:0] 	waddr_s3,
	output logic 			load_link_s3,
	output logic [BITS-1:0]		r2_data_s3,
	output logic [BITS-1:0]		r1_data_s3,
	output logic			alu_imm_s3,
	output logic [BITS-1:0]		sign_ext_imm_s3,
	output logic [SHIFT_BITS-1:0]	shamt_s3,
	output logic [OP_BITS-1:0] 	alu_op_s3,
	output logic [3:0]		byte_en_s3,
	output logic			halt_s3,
	output logic [ADDR_LEFT : 0] r1_addr_s3,
	output logic [ADDR_LEFT : 0] r2_addr_s3

	);
	localparam ONE  = 1'b1;
	localparam ZERO = 1'b0;
	always @(posedge clk )
		if(~(rst_))
		begin  //
		rw_s3      	<= ONE;
 		mem_rw_s3   	<= ONE;
    		alu_op_s3     	<= 4'h0;
    		alu_imm_s3    	<= ZERO;
    		sel_mem_s3    	<= ZERO;
    		byte_en_s3	<= 4'hF;
    		load_link_s3 	<= ONE;
    		check_link_s3 	<= ZERO;
    		atomic_s3     	<= ZERO;
    		halt_s3    	<= ZERO;
		end

		else
		begin
		atomic_s3 	<= 	atomic;
		sel_mem_s3 	<= 	sel_mem;
		check_link_s3 	<= 	check_link;
		mem_rw_s3 	<= 	mem_rw_;
		rw_s3 		<=	rw_;
		waddr_s3 	<= 	waddr_;
		load_link_s3 	<= 	load_link_;
		r2_data_s3 	<= 	r2_data;
		r1_data_s3 	<=	r1_data;
		alu_imm_s3	<= 	alu_imm;
		sign_ext_imm_s3 <= 	sign_ext_imm;
		shamt_s3 	<= 	shamt;
		alu_op_s3 	<= 	alu_op;
		byte_en_s3 	<=	byte_en;
		halt_s3		<= 	halt_s2;
		r1_addr_s3     <= r1_addr;
		r2_addr_s3     <= r2_addr;
		end

endmodule
