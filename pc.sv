
// program counter
module pc
  #(
   parameter BITS=32                  // default number of BITS per word
   )
   (

   output logic [BITS-1:0] pc_addr,      // current instruction address

   input                clk,             // system clock
   input  [BITS-7:0]    addr,            // jump address
   input                rst_,            // system reset
   input                jmp,             // take a jump
   input                load_instr,      // load the next address
   input  [BITS-1:0]    sign_ext_imm,    // branch address
   input                equal,           // values equal for branch
   input                breq,            // doing branch on equal
   input                not_equal,       // values not equal for branch
   input                brne,            // doing branch on not equal
   input                jreg,            // jumping to register value
   input  [BITS-1:0]    r1_data          // value read from register file for jreg
   );

logic [BITS-1:0] ONE  ={{BITS-1{1'b0}},1'b1};
logic [BITS-1:0] ZERO = {BITS{1'b0}};
logic [BITS-1:0] p1_addr, next_pc;

// increment address
assign p1_addr = pc_addr + ONE;

logic [BITS-1:0] seq_pc, breq_pc, brne_pc, jmp_pc, jreg_pc;

assign seq_pc  = (breq && equal) | (brne && not_equal) | jmp | jreg
                 ? ZERO
                 : p1_addr;
// branch equal
assign breq_pc = (breq && equal)     ? (pc_addr + sign_ext_imm) : ZERO;

// branch not equal
assign brne_pc = (brne && not_equal) ? (pc_addr + sign_ext_imm) : ZERO;

// jump address
assign jmp_pc  = jmp ? { pc_addr[BITS-1:BITS-4], 2'b00, addr } : ZERO;

// jump register
assign jreg_pc = jreg ? r1_data : ZERO;

// combining all using OR
assign next_pc = seq_pc | breq_pc | brne_pc | jmp_pc | jreg_pc;

always_ff @(posedge clk or negedge rst_) begin
   if (!rst_)
      pc_addr <= ZERO;      // reset to 0
   else if (load_instr)
      pc_addr <= next_pc; 
end

endmodule

