// the top level cpu 
module cpu3
   (
   output logic      halt,      // halt signal to end simulation
   output logic      exception, // the exception interupt signal

   input             clk,  // system clock
   input             rst_  // system reset
   );

   `include "cpu_params.vh"



   logic [BITS-1:0]            pc_addr;      // current address
   logic [BITS-1:0]            i_mem_rdata;  // instruction memory read data
   logic [BITS-1:0]            d_mem_rdata;  // data memory read data
   logic [BITS-1:0]            r1_data;      // register file read data 1
   logic [BITS-1:0]            r2_data;      // register file read data 2
   logic [BITS-1:0]            alu_out;      // alu output
   logic [BITS-1:0]            alu_in_1;     // alu input 1
   logic [BITS-1:0]            alu_in_2;     // alu input 2
   logic [REG_ADDR_LEFT:0]     r1_addr;      // register file read addr 1
   logic [REG_ADDR_LEFT:0]     r2_addr;      // register file read addr 2
   logic [REG_ADDR_LEFT:0]     waddr;        // register file write addr
   logic [SHIFT_BITS-1:0]      shamt;        // shift amount
   logic [OP_BITS-1:0]         alu_op;       // alu operation
   logic [IMM_LEFT-1:0]        imm;          // immediate data
   logic [JMP_LEFT:0]          addr;         // jump address to program counter
   logic                       rw_;          // register file read write signal
   logic                       mem_rw_;      // data memory read write signal
   logic                       sel_mem;      // select the output from the memory
   logic                       alu_imm;      // use immediate data for the alu
   logic [BITS-1:0]            reg_wdata;    // data to write to the register file
   logic [BITS-1:0]            sign_ext_imm; // immediate data that has been sign extended
   logic                       signed_ext;   // whether or not to extend the sign bit
   logic [ 3:0]                byte_en;      // byte enables

   //logic                       swap;         // swap low 16 bits to high 16 bits
   logic                       load_link_;   // load the link register
   logic                       check_link;   // check if link register is same as address
   logic                       atomic;       // force value to 0 or 1 for atomic operation
   logic                       jmp;          // doing a jump
   logic                       equal;        // values were equal for branches
   logic                       breq;         // doing a branch on equal
   logic                       not_equal;    // values were not equal for branches
   logic                       brne;         // doing o branch o not equal
   logic                       jal;          // doing a jump and link
   logic                       jreg;         // jumping to an address in a register

   

   logic [BITS-1:0] link_addr;
   logic link_valid;
   logic link_rw_;
   logic use_mem_rw_;
   logic addr_m;
   localparam REPL_BITS = BITS - 1;

   assign addr_m = (alu_out == link_addr);
   assign use_mem_rw_ = (mem_rw_ & ~ check_link) | (check_link & ~(link_valid & addr_m));	
   assign link_rw_ = check_link ? ~(link_valid & addr_m) : 1'b1; 

   always_ff @(posedge clk or negedge rst_) begin
	if (~rst_) begin
	   link_addr <= {BITS{1'b0}};
	   link_valid <= 1'b0;
	end
	
	else if (~load_link_) begin
	   link_addr <= alu_out;
	   link_valid <= 1'b1;
	end

	else if (check_link) begin
	   link_valid <= 1'b0;
	end

	else if (link_valid && !use_mem_rw_ && addr_m && !check_link) begin
	   link_valid <= 1'b0;
	end
   end

   // the program counter
   // which instruction to read from the instruction memory
   pc #(.BITS(BITS) ) pc (
          .pc_addr(pc_addr), .clk(clk), .addr(addr), .rst_(rst_),
          .jmp(jmp), .load_instr(1'b1), .sign_ext_imm(sign_ext_imm),
          .equal(equal), .not_equal(not_equal), .breq(breq), .brne(brne),
          .jreg(jreg), .r1_data(r1_data) );

   // the instruction memory
   // holds the program
   // NOTE: not currently enabling writes to the instruction memory
   memory #( .BASE_ADDR(I_MEM_BASE_ADDR), .BITS(BITS), .WORDS(I_MEM_WORDS) ) i_memory(
       .rdata(i_mem_rdata), .clk(clk), .wdata(32'b0), .rw_(1'b1),
       .addr(pc_addr), .byte_en(4'b0) );

   // the instruction register - includes instruction decode
   // gets instruction to execute and decodes it, telling the rest of the design what to do
   instr_reg #( .BITS(BITS), .REG_WORDS(REG_WORDS), .OP_BITS(OP_BITS),
                .SHIFT_BITS(SHIFT_BITS), .JMP_LEFT(JMP_LEFT) ) instr_reg (
       .r1_addr(r1_addr), .r2_addr(r2_addr), .waddr(waddr),
       .jal(jal), .jreg(jreg), .exception(exception),
       .shamt(shamt), .alu_op(alu_op), .imm(imm), .addr(addr),
       .rw_(rw_), .sel_mem(sel_mem), .alu_imm(alu_imm),
       .signed_ext(signed_ext), .byte_en(byte_en), .halt(halt),
       .clk(clk), .load_instr(1'b1), .mem_rw_(mem_rw_),
       .load_link_(load_link_), .check_link(check_link),
       .atomic(atomic), .jmp(jmp), .breq(breq), .equal(equal), 
       .brne(brne), .not_equal(not_equal),
       .mem_data(i_mem_rdata), .rst_(rst_) );

   // select the data to write to the register file:

assign reg_wdata = (sel_mem) ? 
                      d_mem_rdata :
                      (atomic) ?
                          ({{REPL_BITS{1'b0}}, ~link_rw_}) :
                          alu_out;



   // the register file
   // holds the 32 registers that you can read or write
   regfile #( .WORDS(REG_WORDS), .BITS(BITS) ) regfile(
       .r1_data(r1_data), .r2_data(r2_data), .clk(clk), .rst_(rst_),
       .rw_(rw_), .wdata(reg_wdata), .waddr(waddr),
       .r1_addr(r1_addr), .r2_addr(r2_addr), .byte_en(byte_en) ); 

   //assign sign_ext_imm = '0; // do sign extension
   assign sign_ext_imm = signed_ext ? {{(BITS-IMM_LEFT){imm[IMM_LEFT-1]}}, imm} : {{(BITS-IMM_LEFT){1'b0}}, imm};

   //assign alu_in_1     = '0; 
   assign alu_in_1 = r1_data;

   //assign alu_in_2     = '0; 
  
 assign alu_in_2 = (jal) ? (pc_addr + 1'b1) :
                   (alu_imm) ? sign_ext_imm :
                   r2_data;

   // the alu
   // does the math
   alu #( .NUM_BITS(BITS), .OP_BITS(OP_BITS), .SHIFT_BITS(SHIFT_BITS) ) alu (
       .alu_out(alu_out), 
       .data1(alu_in_1), .data2(alu_in_2), 
       .alu_op(alu_op), .shamt(shamt) );

   // the data memory
   // the data is stored or read
   memory #( .BASE_ADDR(D_MEM_BASE_ADDR), .BITS(BITS), .WORDS(D_MEM_WORDS) ) d_memory (
        .rdata(d_mem_rdata), .clk(clk), .wdata(r2_data),
        .rw_(use_mem_rw_), .addr(alu_out), .byte_en(byte_en) );

pipe_id_ex pipe_id_ex_inst (
   .clk(clk),
   .rst_(rst_),
   .atomic(atomic),
   .sel_mem(sel_mem),
   .check_link(check_link),
   .mem_rw_(mem_rw_),
   .rw_(rw_),
   .waddr(waddr),
   .load_link_(load_link_),
   .r1_data(r1_data),
   .r2_data(r2_data),
   .alu_imm(alu_imm),
   .sign_ext_imm(sign_ext_imm),
   .shamt(shamt),
   .alu_op(alu_op),
   .byte_en(byte_en),
   .halt_s2(halt),

   .atomic_s3(atomic_s3),
   .sel_mem_s3(sel_mem_s3),
   .check_link_s3(check_link_s3),
   .mem_rw_s3(mem_rw_s3),
   .rw_s3(rw_s3),
   .waddr_s3(waddr_s3),
   .load_link_s3(load_link_s3),
   .r1_data_s3(r1_data_s3),
   .r2_data_s3(r2_data_s3),
   .alu_imm_s3(alu_imm_s3),
   .sign_ext_imm_s3(sign_ext_imm_s3),
   .shamt_s3(shamt_s3),
   .alu_op_s3(alu_op_s3),
   .byte_en_s3(byte_en_s3),
   .halt_s3(halt_s3)
);

pipe_ex_mem pipe_ex_mem_inst (
    .clk(clk),
    .rst_(rst_),
    .atomic_s3(atomic_s3),
    .sel_mem_s3(sel_mem_s3),
    .check_link_s3(check_link_s3),
    .mem_rw_s3(mem_rw_s3),
    .rw_s3(rw_s3),
    .waddr_s3(waddr_s3),
    .load_link_s3(load_link_s3),
    .r1_data_s3(r1_data_s3),
    .r2_data_s3(r2_data_s3),
    .alu_imm_s3(alu_imm_s3),
    .sign_ext_imm_s3(sign_ext_imm_s3),
    .shamt_s3(shamt_s3),
    .alu_op_s3(alu_op_s3),
    .byte_en_s3(byte_en_s3),
    .halt_s3(halt_s3),
    .alu_out(alu_out),

    .atomic_s4(atomic_s4),
    .sel_mem_s4(sel_mem_s4),
    .check_link_s4(check_link_s4),
    .mem_rw_s4(mem_rw_s4),
    .rw_s4(rw_s4),
    .waddr_s4(waddr_s4),
    .load_link_s4(load_link_s4),
    .r1_data_s4(r1_data_s4),
    .r2_data_s4(r2_data_s4),
    .alu_imm_s4(alu_imm_s4),
    .sign_ext_imm_s4(sign_ext_imm_s4),
    .shamt_s4(shamt_s4),
    .alu_op_s4(alu_op_s4),
    .byte_en_s4(byte_en_s4),
    .halt_s4(halt_s4),
    .alu_out_s4(alu_out_s4)
);

// ==============================================
// MEM → WB Pipeline Register
// ==============================================
pipe_mem_wb #(
    .BITS(BITS),
    .REG_WORDS(REG_WORDS),
    .ADDR_LEFT(REG_ADDR_LEFT),
    .OP_BITS(OP_BITS),
    .SHIFT_BITS(SHIFT_BITS),
    .JMP_LEFT(JMP_LEFT),
    .IMM_LEFT(IMM_LEFT),
    .ALU_OP_PARAM(ALU_OP_PARAM)
) MEM_WB (
    .clk(clk),
    .rst_(rst_),

    // ---------- Input: MEM Stage (S4) ----------
    .atomic_s4(atomic_s4),
    .sel_mem_s4(sel_mem_s4),
    .check_link_s4(check_link_s4),
    .mem_rw_s4(mem_rw_s4),
    .rw_s4(rw_s4),
    .waddr_s4(waddr_s4),
    .load_link_s4(load_link_s4),
    .r2_data_s4(r2_data_s4),
    .r1_data_s4(r1_data_s4),
    .alu_imm_s4(alu_imm_s4),
    .sign_ext_imm_s4(sign_ext_imm_s4),
    .shamt_s4(shamt_s4),
    .alu_op_s4(alu_op_s4),
    .byte_en_s4(byte_en_s4),
    .halt_s4(halt_s4),
    .alu_out_s4(alu_out_s4),

    // ---------- Output: WB Stage (S5) ----------
    .atomic_s5(atomic_s5),
    .sel_mem_s5(sel_mem_s5),
    .check_link_s5(check_link_s5),
    .mem_rw_s5(mem_rw_s5),
    .rw_s5(rw_s5),
    .waddr_s5(waddr_s5),
    .load_link_s5(load_link_s5),
    .r2_data_s5(r2_data_s5),
    .r1_data_s5(r1_data_s5),
    .alu_imm_s5(alu_imm_s5),
    .sign_ext_imm_s5(sign_ext_imm_s5),
    .shamt_s5(shamt_s5),
    .alu_op_s5(alu_op_s5),
    .byte_en_s5(byte_en_s5),
    .halt_s5(halt_s5),
    .alu_out_s5(alu_out_s5)
);

// ====================================================================
// EQUALITY MODULE - Added to enable fast branch resolution
// Compares register file outputs r1_data and r2_data
// Moved from instruction register as per lecture requirement
// ====================================================================
equality #(.NUM_BITS(BITS)) equality_inst (
    .data1(r1_data),
    .data2(r2_data),
    .equal(equal),
    .not_equal(not_equal)
);




endmodule
