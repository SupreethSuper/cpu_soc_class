//======================================================
// Top-level CPU module
//======================================================
module cpu4 (
   output logic halt,        // halt signal to end simulation
   output logic exception,   // exception interrupt signal

   input        clk,         // system clock
   input        rst_         // system reset
);

   `include "cpu_params.vh"

   //---------------------------------------------------
   // Declarations
   //---------------------------------------------------
   logic [BITS-1:0]        pc_addr;       
   logic [BITS-1:0]        i_mem_rdata;   
   logic [BITS-1:0]        d_mem_rdata;   
   logic [BITS-1:0]        r1_data;       
   logic [BITS-1:0]        r2_data;       
   logic [BITS-1:0]        alu_out;       
   logic [BITS-1:0]        alu_in_1;      
   logic [BITS-1:0]        alu_in_2;      
   logic [REG_ADDR_LEFT:0] r1_addr;       
   logic [REG_ADDR_LEFT:0] r2_addr;       
   logic [REG_ADDR_LEFT:0] waddr;         
   logic [SHIFT_BITS-1:0]  shamt;         
   logic [OP_BITS-1:0]     alu_op;        
   logic [IMM_LEFT-1:0]    imm;           
   logic [JMP_LEFT:0]      addr;          
   logic                   rw_;           
   logic                   mem_rw_;       
   logic                   sel_mem;       
   logic                   alu_imm;       
   logic [BITS-1:0]        reg_wdata;     
   logic [BITS-1:0]        sign_ext_imm;  
   logic                   signed_ext;    
   logic [3:0]             byte_en;       
   logic                   swap;          
   logic                   load_link_;    
   logic                   check_link;    
   logic                   atomic;        
   logic                   jmp;           
   logic                   equal;         
   logic                   breq;          
   logic                   not_equal;     
   logic                   brne;          
   logic                   jal;           
   logic                   jreg;          

   logic [BITS-1:0]        link_addr;
   logic                   link_valid;
   logic                   link_rw_;
   logic                   use_mem_rw_;
   logic                   addr_m;

   // Pipeline registers
   logic                   halt_s2;
   logic                   atomic_s3, sel_mem_s3, check_link_s3, mem_rw_s3, rw_s3;
   logic [REG_ADDR_LEFT:0] waddr_s3;
   logic                   load_link_s3;
   logic [BITS-1:0]        r2_data_s3, r1_data_s3, sign_ext_imm_s3;
   logic                   alu_imm_s3;
   logic [SHIFT_BITS-1:0]  shamt_s3;
   logic [OP_BITS-1:0]     alu_op_s3;
   logic [3:0]             byte_en_s3;
   logic                   halt_s3;

   logic [BITS-1:0]        alu_out_s4;
   logic                   atomic_s4, sel_mem_s4, check_link_s4, mem_rw_s4, rw_s4;
   logic [REG_ADDR_LEFT:0] waddr_s4;
   logic                   load_link_s4;
   logic [BITS-1:0]        r2_data_s4;
   logic [3:0]             byte_en_s4;
   logic                   halt_s4;

   logic [BITS-1:0]        alu_out_s5;
   logic                   atomic_s5, sel_mem_s5, link_rw_s5, rw_s5;
   logic [BITS-1:0]        d_mem_rdata_s5;
   logic [REG_ADDR_LEFT:0] waddr_s5;
   logic [3:0]             byte_en_s5;
   logic                   halt_s5;


   //---------------------------------------------------
   // Link handling logic
   //---------------------------------------------------
   assign addr_m       = (alu_out == link_addr);
   assign use_mem_rw_  = (mem_rw_ & ~check_link) | (check_link & ~(link_valid & addr_m)); 
   assign link_rw_     = check_link ? ~(link_valid & addr_m) : 1'b1; 

   always_ff @(posedge clk or negedge rst_) begin
      if (~rst_) begin
         link_addr  <= {BITS{1'b0}};
         link_valid <= 1'b0;
      end
      else if (~load_link_) begin
         link_addr  <= alu_out;
         link_valid <= 1'b1;
      end
      else if (check_link) begin
         link_valid <= 1'b0;
      end
      else if (link_valid && !use_mem_rw_ && addr_m && !check_link) begin
         link_valid <= 1'b0;
      end
   end


   //---------------------------------------------------
   // Program Counter
   //---------------------------------------------------
   pc #(
      .BITS(BITS)
   ) pc (
      .pc_addr(pc_addr),
      .clk(clk),
      .addr(addr),
      .rst_(rst_),
      .jmp(jmp),
      .load_instr(1'b1),
      .sign_ext_imm(sign_ext_imm),
      .equal(equal),
      .not_equal(not_equal),
      .breq(breq),
      .brne(brne),
      .jreg(jreg),
      .r1_data(r1_data)
   );


   //---------------------------------------------------
   // Instruction Memory
   //---------------------------------------------------
   memory #(
      .BASE_ADDR(I_MEM_BASE_ADDR),
      .BITS(BITS),
      .WORDS(I_MEM_WORDS)
   ) i_memory (
      .rdata(i_mem_rdata),
      .clk(clk),
      .wdata(32'b0),
      .rw_(1'b1),
      .addr(pc_addr),
      .byte_en(4'b0)
   );


   //---------------------------------------------------
   // Instruction Register & Decoder
   //---------------------------------------------------
   instr_reg #(
      .BITS(BITS),
      .REG_WORDS(REG_WORDS),
      .OP_BITS(OP_BITS),
      .SHIFT_BITS(SHIFT_BITS),
      .JMP_LEFT(JMP_LEFT)
   ) instr_reg (
      .r1_addr(r1_addr),
      .r2_addr(r2_addr),
      .waddr(waddr),
      .jal(jal),
      .jreg(jreg),
      .exception(exception),
      .shamt(shamt),
      .alu_op(alu_op),
      .imm(imm),
      .addr(addr),
      .rw_(rw_),
      .sel_mem(sel_mem),
      .alu_imm(alu_imm),
      .signed_ext(signed_ext),
      .byte_en(byte_en),
      .halt(halt_s2),
      .clk(clk),
      .load_instr(1'b1),
      .mem_rw_(mem_rw_),
      .swap(swap),
      .load_link_(load_link_),
      .check_link(check_link),
      .atomic(atomic),
      .jmp(jmp),
      .breq(breq),
      .equal(equal),
      .brne(brne),
      .not_equal(not_equal),
      .mem_data(i_mem_rdata),
      .rst_(rst_)
   );




   //---------------------------------------------------
   // Register Write Data Selection
   //---------------------------------------------------
   assign reg_wdata =
         (sel_mem) ? d_mem_rdata :
         (atomic)  ? {{{(BITS-1){1'b0}}, ~link_rw_}} :
         (swap)    ? {alu_out[15:0], alu_out[31:16]} :
                     alu_out;


   //---------------------------------------------------
   // Register File
   //---------------------------------------------------
   regfile #(
      .WORDS(REG_WORDS),
      .BITS(BITS)
   ) regfile (
      .r1_data(r1_data),
      .r2_data(r2_data),
      .clk(clk),
      .rst_(rst_),
      .rw_(rw_),
      .wdata(reg_wdata),
      .waddr(waddr),
      .r1_addr(r1_addr),
      .r2_addr(r2_addr),
      .byte_en(byte_en)
   );


   //---------------------------------------------------
   // ALU Inputs and Sign Extension
   //---------------------------------------------------
   assign sign_ext_imm = signed_ext
                       ? {{(BITS-IMM_LEFT){imm[IMM_LEFT-1]}}, imm}
                       : {{(BITS-IMM_LEFT){1'b0}}, imm};

   assign alu_in_1 = r1_data;
   assign alu_in_2 = (jal) ? (pc_addr + 1'b1)
                    : (alu_imm) ? sign_ext_imm
                    : r2_data;


   //---------------------------------------------------
   // ALU
   //---------------------------------------------------
   alu #(
      .NUM_BITS(BITS),
      .OP_BITS(OP_BITS),
      .SHIFT_BITS(SHIFT_BITS)
   ) alu (
      .alu_out(alu_out),
      .equal(equal),
      .not_equal(not_equal),
      .data1(alu_in_1),
      .data2(alu_in_2),
      .alu_op(alu_op),
      .shamt(shamt)
   );


   //---------------------------------------------------
   // Data Memory
   //---------------------------------------------------
   memory #(
      .BASE_ADDR(D_MEM_BASE_ADDR),
      .BITS(BITS),
      .WORDS(D_MEM_WORDS)
   ) d_memory (
      .rdata(d_mem_rdata),
      .clk(clk),
      .wdata(r2_data),
      .rw_(use_mem_rw_),
      .addr(alu_out),
      .byte_en(byte_en)
   );


   //---------------------------------------------------
   // Pipeline Stages
   //---------------------------------------------------

   // Stage 3: ID/EX
   pipe_id_ex #(
      .BITS(BITS),
      .REG_WORDS(REG_WORDS),
      .OP_BITS(OP_BITS),
      .SHIFT_BITS(SHIFT_BITS),
      .JMP_LEFT(JMP_LEFT)
   ) pipe_id_ex (
      .clk(clk),
      .rst_(rst_),
      .atomic(atomic),
      .sel_mem(sel_mem),
      .check_link(check_link),
      .mem_rw_(mem_rw_),
      .rw_(rw_),
      .waddr_(waddr),
      .load_link_(load_link_),
      .r2_data(r2_data),
      .r1_data(r1_data),
      .alu_imm(alu_imm),
      .sign_ext_imm(sign_ext_imm),
      .shamt(shamt),
      .alu_op(alu_op),
      .byte_en(byte_en),
      .halt_s2(halt_s2),

      .atomic_s3(atomic_s3),
      .sel_mem_s3(sel_mem_s3),
      .check_link_s3(check_link_s3),
      .mem_rw_s3(mem_rw_s3),
      .rw_s3(rw_s3),
      .waddr_s3(waddr_s3),
      .load_link_s3(load_link_s3),
      .r2_data_s3(r2_data_s3),
      .r1_data_s3(r1_data_s3),
      .alu_imm_s3(alu_imm_s3),
      .sign_ext_imm_s3(sign_ext_imm_s3),
      .shamt_s3(shamt_s3),
      .alu_op_s3(alu_op_s3),
      .byte_en_s3(byte_en_s3),
      .halt_s3(halt_s3)
   );


   // Stage 4: EX/MEM
   pipe_ex_mem #(
      .BITS(BITS),
      .REG_WORDS(REG_WORDS)
   ) pipe_ex_mem (
      .clk(clk),
      .rst_(rst_),
      .alu_out(alu_out),
      .atomic_s3(atomic_s3),
      .sel_mem_s3(sel_mem_s3),
      .check_link_s3(check_link_s3),
      .mem_rw_s3(mem_rw_s3),
      .rw_s3(rw_s3),
      .waddr_s3(waddr_s3),
      .load_link_s3(load_link_s3),
      .r2_data_s3(r2_data_s3),
      .byte_en_s3(byte_en_s3),
      .halt_s3(halt_s3),

      .alu_out_s4(alu_out_s4),
      .atomic_s4(atomic_s4),
      .sel_mem_s4(sel_mem_s4),
      .check_link_s4(check_link_s4),
      .mem_rw_s4(mem_rw_s4),
      .rw_s4(rw_s4),
      .waddr_s4(waddr_s4),
      .load_link_s4(load_link_s4),
      .r2_data_s4(r2_data_s4),
      .byte_en_s4(byte_en_s4),
      .halt_s4(halt_s4)
   );


   // Stage 5: MEM/WB
   pipe_mem_wb #(
      .BITS(BITS),
      .REG_WORDS(REG_WORDS)
   ) pipe_mem_wb (
      .clk(clk),
      .rst_(rst_),
      .alu_out_s4(alu_out_s4),
      .atomic_s4(atomic_s4),
      .sel_mem_s4(sel_mem_s4),
      .d_mem_rdata(d_mem_rdata),
      .link_rw_(link_rw_),
      .rw_s4(rw_s4),
      .waddr_s4(waddr_s4),
      .byte_en_s4(byte_en_s4),
      .halt_s4(halt_s4),

      .alu_out_s5(alu_out_s5),
      .atomic_s5(atomic_s5),
      .sel_mem_s5(sel_mem_s5),
      .link_rw_s5(link_rw_s5),
      .d_mem_rdata_s5(d_mem_rdata_s5),
      .rw_s5(rw_s5),
      .waddr_s5(waddr_s5),
      .byte_en_s5(byte_en_s5),
      .halt_s5(halt_s5)
   );

// Forwarding unit
forward forward_unit (
    .r1_addr_s3 (r1_addr_s3),   // from pipe_id_ex
    .r2_addr_s3 (r2_addr_s3),   // from pipe_id_ex
    .rw_s4      (rw_s4),        // write enable from EX/MEM or MEM/WB
    .waddr_s4   (waddr_s4)      // destination register of stage 4
);


   //---------------------------------------------------
   // Final Halt
   //---------------------------------------------------
   assign halt = halt_s5;

endmodule
