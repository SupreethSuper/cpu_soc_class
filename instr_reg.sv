// instruction register and instruction decode (pipelined version)
module instr_reg
  #(
   parameter BITS=32,                   
   parameter REG_WORDS=32,              
   parameter ADDR_LEFT=$clog2(REG_WORDS)-1, 
   parameter OP_BITS=4,                 
   parameter SHIFT_BITS=5,              
   parameter JMP_LEFT=25,               
   parameter IMM_LEFT=BITS/2            
   )
   (
   output logic [ADDR_LEFT:0]    r1_addr,      
   output logic [ADDR_LEFT:0]    r2_addr,      
   output logic [ADDR_LEFT:0]    waddr,        
   output logic [SHIFT_BITS-1:0] shamt,        
   output logic [OP_BITS-1:0]    alu_op,       
   output logic [IMM_LEFT-1:0]   imm,          
   output logic [JMP_LEFT:0]     addr,         
   output logic                  rw_,          
   output logic                  mem_rw_,      
   output logic                  sel_mem,      
   output logic                  alu_imm,      
   output logic                  signed_ext,   
   output logic [3:0]            byte_en,      
   output logic                  halt,         
   output logic                  swap,         
   output logic                  load_link_,   
   output logic                  check_link,   
   output logic                  atomic,       
   output logic                  jmp,          
   output logic                  breq,         
   output logic                  brne,         
   output logic                  jal,          
   output logic                  jreg,         
   output logic                  exception,    

   input                   clk,          
   input                   load_instr,   
   input  [BITS-1:0]       mem_data,     
   input                   rst_,         
   input                   equal,        
   input                   not_equal     
   );

  `include "common.vh"
  `include "instr_reg_params.vh"

   localparam CODE_BITS = 6;          
   localparam FUNC_BITS = 6;          
   localparam OP_LEFT = 31;
   localparam RS_LEFT = 25;
   localparam RT_LEFT = 20;
   localparam RD_LEFT = 15;
   localparam SH_LEFT = 10;
   localparam FU_LEFT = 5;
   localparam NUM_REG_BITS = 5;
   localparam OP_RTYPE = 6'h0;
   localparam OP_JTYPE1 = 6'h2;
   localparam OP_JTYPE2 = 6'h3;
   localparam NOP = 32'h0000_0020;   

   localparam OP_SW = 6'h2B;
   localparam OP_BEQ = 6'h04;
   localparam OP_BNE = 6'h05;
   localparam OP_SC = 6'h38;
   localparam RA_REG = 5'd31;
   localparam OP_SB = 6'h28;
   localparam OP_SH = 6'h29;

   logic [BITS-1:0]         instr;
   logic [CODE_BITS-1:0]    opcode;
   logic [FUNC_BITS-1:0]    funct;
   logic [ADDR_LEFT:0]      rs, rt, rd;
   logic                    rt_is_src;
   logic                    stall;
   logic                    r_type, i_type, j_type;

   //======================================================
   // INSTRUCTION REGISTER
   //======================================================
   always_ff @(posedge clk or negedge rst_) begin
      if (!rst_)
         instr <= NOP;
      else if (!stall && load_instr)
         instr <= mem_data;
   end

   always_ff @(posedge clk)
      if (load_instr)
         $display("Loaded instruction: %h", instr);

   //======================================================
   // FIELD EXTRACTION (COMBINATIONAL)
   //======================================================
   assign opcode    = instr[OP_LEFT -: CODE_BITS];
   assign r_type    = (opcode == OP_RTYPE);
   assign j_type    = (opcode == OP_JTYPE1 || opcode == OP_JTYPE2);
   assign i_type    = (opcode != OP_RTYPE && !j_type);
   assign funct     = (r_type) ? instr[FU_LEFT -: FUNC_BITS] : {FUNC_BITS{1'b0}};
   assign rs        = instr[RS_LEFT -: NUM_REG_BITS];
   assign rt        = instr[RT_LEFT -: NUM_REG_BITS];
   assign rd        = instr[RD_LEFT -: NUM_REG_BITS];
   assign rt_is_src = (r_type || (opcode == OP_SW || opcode == OP_BEQ || opcode == OP_BNE || opcode == OP_SC || opcode == OP_SB || opcode == OP_SH));
   assign addr      = instr[JMP_LEFT:0];
   assign imm       = instr[IMM_LEFT-1:0];
   assign r1_addr   = rs;
   assign r2_addr   = (r_type | rt_is_src) ? rt : '0;
   assign waddr     = (jal) ? RA_REG : (r_type ? rd : rt);
   assign shamt     = (swap) ? SWAP_SET_SHAMT : instr[SH_LEFT -: SHIFT_BITS];

   //======================================================
   // NEXT-STATE DECODE (COMBINATIONAL)
   //======================================================
   logic [OP_BITS-1:0]    next_alu_op;
   logic                  next_rw_, next_mem_rw_, next_sel_mem, next_alu_imm;
   logic                  next_signed_ext, next_swap, next_load_link_, next_check_link;
   logic                  next_atomic, next_jmp, next_breq, next_brne, next_jal;
   logic                  next_jreg, next_exception, next_halt;
   logic [3:0]            next_byte_en;

   always_comb begin
      // defaults
      next_rw_        = ONE;
      next_mem_rw_    = ONE;
      next_alu_op     = ALU_PASS1;
      next_alu_imm    = ZERO;
      next_sel_mem    = ZERO;
      next_signed_ext = ZERO;
      next_byte_en    = 4'hF;
      next_swap       = ZERO;
      next_load_link_ = ONE;
      next_check_link = ZERO;
      next_atomic     = ZERO;
      next_jmp        = ZERO;
      next_breq       = ZERO;
      next_brne       = ZERO;
      next_jal        = ZERO;
      next_jreg       = ZERO;
      next_exception  = ZERO;
      next_halt       = ZERO;
      stall           = ZERO;

      case ({opcode, funct})
         ADD: begin
            next_rw_ = ZERO; next_alu_op = ALU_ADD;
         end
         ADDI, ADDIU: begin
            next_rw_ = ZERO; next_alu_op = ALU_ADD; next_alu_imm = ONE; next_signed_ext = ONE;
         end
         ADDU: begin
            next_rw_ = ZERO; next_alu_op = ALU_ADD;
         end
         AND: begin
            next_rw_ = ZERO; next_alu_op = ALU_AND;
         end
         ANDI: begin
            next_rw_ = ZERO; next_alu_op = ALU_AND; next_alu_imm = ONE;
         end
         BEQ: begin
            next_breq = ONE; stall = equal;
         end
         BNE: begin
            next_brne = ONE; stall = not_equal;
         end
         LW: begin
            next_rw_ = ZERO; next_alu_op = ALU_ADD; next_alu_imm = ONE;
            next_signed_ext = ONE; next_sel_mem = ONE;
         end
         SW: begin
            next_rw_ = ONE; next_mem_rw_ = ZERO;
            next_alu_op = ALU_ADD; next_alu_imm = ONE; next_signed_ext = ONE;
         end
         NOR: begin
            next_rw_ = ZERO; next_alu_op = ALU_NOR;
         end
         OR: begin
            next_rw_ = ZERO; next_alu_op = ALU_OR;
         end
         ORI: begin
            next_rw_ = ZERO; next_alu_op = ALU_OR; next_alu_imm = ONE;
         end
         SLL: begin
            next_rw_ = ZERO; next_alu_op = ALU_SLL;
         end
         SRL: begin
            next_rw_ = ZERO; next_alu_op = ALU_SRL;
         end
         SRA: begin
            next_rw_ = ZERO; next_alu_op = ALU_SRA;
         end
         SUB, SUBU: begin
            next_rw_ = ZERO; next_alu_op = ALU_SUB;
         end
         J: begin
            next_jmp = ONE; stall = ONE;
         end
         JAL: begin
            next_jal = ONE; next_jmp = ONE;
            next_rw_ = ZERO; next_alu_op = ALU_PASS2;
         end
         JR: begin
            next_jreg = ONE; stall = ONE;
         end
         LBU: begin
            next_rw_ = ZERO; next_alu_op = ALU_ADD; next_alu_imm = ONE;
            next_sel_mem = ONE; next_byte_en = 4'b0001;
         end
         LHU: begin
            next_rw_ = ZERO; next_alu_op = ALU_ADD; next_alu_imm = ONE;
            next_sel_mem = ONE; next_byte_en = 4'b0011;
         end
         LL: begin
            next_rw_ = ZERO; next_alu_op = ALU_ADD; next_alu_imm = ONE;
            next_sel_mem = ONE; next_signed_ext = ONE; next_load_link_ = ZERO;
         end
         SC: begin
            next_rw_ = ZERO; next_mem_rw_ = ZERO; next_alu_op = ALU_ADD; next_alu_imm = ONE;
            next_signed_ext = ONE; next_atomic = ONE; next_check_link = ONE;
         end
         LUI: begin
            next_rw_ = ZERO; next_alu_op = ALU_ADD; next_alu_imm = ONE; next_swap = ONE;
         end
         SB: begin
            next_mem_rw_ = ZERO; next_alu_op = ALU_ADD; next_alu_imm = ONE;
            next_signed_ext = ONE; next_byte_en = 4'b0001;
         end
         SH: begin
            next_mem_rw_ = ZERO; next_alu_op = ALU_ADD; next_alu_imm = ONE;
            next_signed_ext = ONE; next_byte_en = 4'b0011;
         end
         SLT: begin
            next_rw_ = ZERO; next_alu_op = ALU_LTS;
         end
         SLTI, SLTIU: begin
            next_rw_ = ZERO; next_alu_op = (opcode == OP_SLTIU) ? ALU_LTU : ALU_LTS;
            next_alu_imm = ONE; next_signed_ext = ONE;
         end
         SLTU: begin
            next_rw_ = ZERO; next_alu_op = ALU_LTU;
         end
         HALT: begin
            next_halt = ONE;
         end
         default: begin
            next_exception = ONE;
         end
      endcase
   end

   //======================================================
   // REGISTER DECODE OUTPUTS (PIPELINED)
   //======================================================
   always_ff @(posedge clk or negedge rst_) begin
      if (!rst_) begin
         rw_        <= ONE;
         mem_rw_    <= ONE;
         alu_op     <= ALU_PASS1;
         alu_imm    <= ZERO;
         sel_mem    <= ZERO;
         signed_ext <= ZERO;
         byte_en    <= 4'hF;
         swap       <= ZERO;
         load_link_ <= ONE;
         check_link <= ZERO;
         atomic     <= ZERO;
         jmp        <= ZERO;
         breq       <= ZERO;
         brne       <= ZERO;
         jal        <= ZERO;
         jreg       <= ZERO;
         exception  <= ZERO;
         halt       <= ZERO;
      end else begin
         rw_        <= next_rw_;
         mem_rw_    <= next_mem_rw_;
         alu_op     <= next_alu_op;
         alu_imm    <= next_alu_imm;
         sel_mem    <= next_sel_mem;
         signed_ext <= next_signed_ext;
         byte_en    <= next_byte_en;
         swap       <= next_swap;
         load_link_ <= next_load_link_;
         check_link <= next_check_link;
         atomic     <= next_atomic;
         jmp        <= next_jmp;
         breq       <= next_breq;
         brne       <= next_brne;
         jal        <= next_jal;
         jreg       <= next_jreg;
         exception  <= next_exception;
         halt       <= next_halt;
      end
   end

endmodule
