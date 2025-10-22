// instruction register and instruction decode
module instr_reg
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

   output logic [ADDR_LEFT:0]    r1_addr,      // reg file read address 1
   output logic [ADDR_LEFT:0]    r2_addr,      // reg file read address 2
   output logic [ADDR_LEFT:0]    waddr,        // reg file write address
   output logic [SHIFT_BITS-1:0] shamt,        // shift amount for alu
   output logic [OP_BITS-1:0]    alu_op,       // alu operation
   output logic [IMM_LEFT-1:0]   imm,          // use immediate value
   output logic [JMP_LEFT:0]     addr,         // jump address
   output logic                  rw_,          // register file read/write
   output logic                  mem_rw_,      // data memory read/write
   output logic                  sel_mem,      // use data from memory
   output logic                  alu_imm,      // use immediate data for alu
   output logic                  signed_ext,   // do sign extension
   output logic [ 3:0]           byte_en,      // byte enables
   output logic                  halt,         // stop the program
   //swap set as comment, and set out as logic
   //output logic                  swap,         // swap low 16 bits to high 16 bits
   output logic                  load_link_,   // load link register
   output logic                  check_link,   // check if link register same as addr
   output logic                  atomic,       // atomic operation
   output logic                  jmp,          // jump
   output logic                  breq,         // branch on equal
   output logic                  brne,         // branch on not equal
   output logic                  jal,          // jump and link
   output logic                  jreg,         // jump to register value
   output logic                  exception,    // take exception

   input                   clk,          // system clock
   input                   load_instr,   // if 1 load register
   input  [BITS-1:0]       mem_data,     // instruction from instruction memory
   input                   rst_,         // system reset
   input                   equal,        // alu inputs were equal for branches
   input                   not_equal     // alu inputs were not equal for branches
   );

  `include "common.vh"
  `include "instr_reg_params.vh"

   localparam CODE_BITS = 6;          // instruction op code bits
   localparam FUNC_BITS = 6;          // instruction function bits
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
   localparam SWAP_SET_SHAMT = 16;

  // Instruction register
   logic [BITS-1:0]         instr;             // see above!
   logic [CODE_BITS-1:0]    opcode;
   logic [FUNC_BITS-1:0]    funct;
   logic [ADDR_LEFT:0]      rs;
   logic [ADDR_LEFT:0]      rt;
   logic [ADDR_LEFT:0]      rd;
   logic                    rt_is_src;
   logic                    stall;
   logic                    swap;


   // Constants used inside ALU and PC
  localparam logic ZERO = 1'b0;
  localparam logic ONE  = 1'b1;


  localparam OP_SW = 6'h2B;
  localparam OP_BEQ = 6'h04;
  localparam OP_BNE = 6'h05;
  localparam OP_SC = 6'h38;
  localparam RA_REG = 5'd31;
  localparam OP_SB = 6'h28;
  localparam OP_SH = 6'h29;
  logic r_type, i_type, j_type;
// Check reset, if not in reset load data
  always_ff @(posedge clk or negedge rst_) begin

    if (!rst_)
      instr <= NOP; 

    else if (stall)
      instr <= NOP;

    else if (load_instr)
      instr <= mem_data;

  end


always @ ( * )         // here for debugging
       $display("instruction reg is %h",instr);

// Assign respective values for the parameters

  assign opcode  = instr[OP_LEFT -: CODE_BITS]; // Assigning the bits for opcode

  assign r_type = (opcode == OP_RTYPE) ? ONE : ZERO; // Assigning 1 or 0 to rtype, if opcode is 0 then rtype is rtype

  assign j_type = (opcode == OP_JTYPE1 || opcode == OP_JTYPE2) ? ONE : ZERO; // if opcode is either jtype1 or jtype2 then it is a jtype, else it is not jtype

  assign i_type = (opcode != OP_RTYPE && !j_type) ? ONE : ZERO; // if opcode is not zero then it is itype

  assign funct   = (r_type) ? instr[FU_LEFT  -: FUNC_BITS] : {FUNC_BITS{ZERO}}; // assigning function its width only if the type is rtype, if not function is 0

  assign rs      = instr[RS_LEFT  -: NUM_REG_BITS]; // assigning for rs

  assign rt      = instr[RT_LEFT  -: NUM_REG_BITS]; // assigning for rt

  assign rd      = instr[RD_LEFT  -: NUM_REG_BITS]; // assigning for rd

  assign rt_is_src = (r_type || (opcode == OP_SW || opcode == OP_BEQ || opcode == OP_BNE || opcode == OP_SC || opcode == OP_SB || opcode == OP_SH)); // to  be changed in future program

  assign shamt = instr[SH_LEFT -: SHIFT_BITS]; // assigning for shamt

  assign addr  = instr[JMP_LEFT:0]; // assigning for addr

  assign imm   = instr[IMM_LEFT-1:0]; // assigning for imm

  //assign r1_addr    = (rt_is_src == ONE) ? rt : rs; // r1_addr is rs source
  assign r1_addr = rs;

  //assign r2_addr    = (r_type == ONE) ? rt : ZERO; // if rtype r2_addr is rt, else it is zero

  //assign r2_addr = (r_type == ONE || opcode == OP_BEQ || opcode == OP_BNE || opcode == OP_SW) ? rt : ZERO; // source

  assign r2_addr = (r_type | rt_is_src) ? rt : ZERO;

  //assign waddr      = (i_type == ONE) ? rt : rd; // if itype waddr is rt, else it is rd

   assign waddr = (jal) ? RA_REG : (r_type) ? rd : rt;//destination

  // Decode
  always @ (*)
  begin
    // defaults
    rw_        = 1'b1;
    mem_rw_    = 1'b1;
    alu_op     = ALU_PASS1;
    alu_imm    = 1'b0;
    sel_mem    = 1'b0;
    signed_ext = 1'b0;
    byte_en    = 4'hF;
    halt       = 1'b0;
    swap       = 1'b0;
    load_link_ = 1'b1;
    check_link = 1'b0;
    atomic     = 1'b0;
    jmp        = 1'b0;
    breq       = 1'b0;
    brne       = 1'b0;
    jal        = 1'b0;
    jreg       = 1'b0;
    exception  = 1'b0;
    stall      = 1'b0;

   case ({opcode, funct})  // switch case getting opcode and function from instructions
   // ADD : R-Type : R[rd] = R[rs] + R[rt]
    ADD: begin
      rw_     = ZERO;
      alu_op  = ALU_ADD;
    end

  // ADDI : I-Type : R[rt] = R[rs] + SignExtImm
    ADDI: begin
      rw_        = ZERO;
      alu_op     = ALU_ADD;
      alu_imm    = ONE;
      signed_ext = ONE;
    end

    ADDIU: begin
      rw_        = ZERO;
      alu_op     = ALU_ADD;
      alu_imm    = ONE;
      signed_ext = ONE;
    end

    ADDU: begin
      rw_        = ZERO;
      alu_op     = ALU_ADD;
    end

    AND: begin
      rw_	 = ZERO;
      alu_op	 = ALU_AND;
    end

// ANDI : R[rt] = R[rs] & ZeroExtImm
    ANDI: begin
      rw_        = ZERO;
      alu_op     = ALU_AND;
      alu_imm    = ONE;
      signed_ext = ZERO; 
    end

  // BEQ : if (R[rs] == R[rt]) branch
    BEQ: begin
      breq   = ONE;
      //signed_ext = ONE;
      stall = equal;
    end

  // BNE : if (R[rs] != R[rt]) branch
    BNE: begin
      brne   = ONE;
      //signed_ext = ONE;
      stall = not_equal;
    end

  // LW : R[rt] = Mem[R[rs] + SignExtImm]
    LW: begin
      rw_        = ZERO;     
      alu_op     = ALU_ADD;   // compute address
      alu_imm    = ONE;
      signed_ext = ONE;
      sel_mem    = ONE;       // select data from memory
    end

  // SW : Mem[R[rs] + SignExtImm] = R[rt]
    SW: begin
      rw_        = ONE;       // no register write
      mem_rw_    = ZERO;      // write to memory
      alu_op     = ALU_ADD;
      alu_imm    = ONE;
      signed_ext = ONE;
    end

  // NOR : R[rd] = ~(R[rs] | R[rt])
    NOR: begin
      rw_     = ZERO;
      alu_op  = ALU_NOR;
    end

  // OR : R[rd] = R[rs] | R[rt]
  OR: begin
    rw_     = ZERO;
    alu_op  = ALU_OR;
  end

  // ORI : R[rt] = R[rs] | ZeroExtImm
  ORI: begin
    rw_     = ZERO;
    alu_op  = ALU_OR;
    alu_imm = ONE;
    signed_ext = ZERO; 
  end

  // SLL : R[rd] = R[rt] << shamt
  SLL: begin
    rw_     = ZERO;
    alu_op  = ALU_SLL;
  end

  // SRL : R[rd] = R[rt] >> shamt (logical)
  SRL: begin
    rw_     = ZERO;
    alu_op  = ALU_SRL;
  end

  // SRA : R[rd] = R[rt] >>> shamt (arithmetic)
  SRA: begin
    rw_     = ZERO;
    alu_op  = ALU_SRA;
  end

  // SUB : R[rd] = R[rs] - R[rt]
  SUB: begin
    rw_     = ZERO;
    alu_op  = ALU_SUB;
  end

  // SUBU : R[rd] = R[rs] - R[rt] (no overflow)
  SUBU: begin
    rw_     = ZERO;
    alu_op  = ALU_SUB;
  end
// J
  J: begin
    jmp = ONE;
    stall = ONE;
  end

  // JAL
  JAL: begin
    jal = ONE;
    jmp = ONE;
    rw_ = ZERO;
    alu_op = ALU_PASS2;
  end

  // JR
  JR: begin
    jreg = ONE;
    stall = ONE;
  end

  // LBU
  LBU: begin
    rw_ = ZERO;
    alu_op = ALU_ADD;
    alu_imm = ONE;
    signed_ext = ONE;
    sel_mem = ONE;
    byte_en = 4'b0001; 
  end

  // LHU
  LHU: begin
    rw_ = ZERO;
    alu_op = ALU_ADD;
    alu_imm = ONE;
    signed_ext = ONE;
    sel_mem = ONE;
    byte_en = 4'b0011; 
  end

  // LL
  LL: begin
    rw_        = ZERO;
    alu_op     = ALU_ADD;
    alu_imm    = ONE;
    sel_mem    = ONE;
    signed_ext = ONE;
    load_link_ = ZERO;
  end

  // SC
  SC: begin
    rw_        = ZERO;
    mem_rw_    = ZERO;
    alu_op     = ALU_ADD;
    alu_imm    = ONE;
    signed_ext = ONE;
    atomic     = ONE;
    check_link = ONE;
  end

  // LUI
  //to be set to ALU_SLL
  LUI: begin
    rw_        = ZERO;
    alu_op     = ALU_ADD; 
    alu_imm    = ONE;
    swap       = ONE;
  end

  // SB
  SB: begin
    mem_rw_    = ZERO;
    alu_op     = ALU_ADD;
    alu_imm    = ONE;
    signed_ext = ONE;
    byte_en    = 4'b0001;
  end

  // SH
  SH: begin
    mem_rw_    = ZERO;
    alu_op     = ALU_ADD;
    alu_imm    = ONE;
    signed_ext = ONE;
    byte_en    = 4'b0011;
  end

  // SLT
  SLT: begin
    rw_        = ZERO;
    alu_op     = ALU_LTS;
  end

  // SLTI
  SLTI: begin
    rw_        = ZERO;
    alu_op     = ALU_LTS;
    alu_imm    = ONE;
    signed_ext = ONE;
  end

  // SLTIU 
  SLTIU: begin
    rw_        = ZERO;
    alu_op     = ALU_LTU;
    alu_imm    = ONE;
    signed_ext = ONE;
  end

  // SLTU
  SLTU: begin
    rw_        = ZERO;
    alu_op     = ALU_LTU;
  end
    default: begin
      exception = ONE;
      halt      = ONE;
    end
  endcase
 end

endmodule
