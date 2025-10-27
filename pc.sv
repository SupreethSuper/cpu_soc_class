// program counter

module pc
  #(
   parameter BITS=32                  // default number of BITS per word
   )
   (

   output logic [BITS-1:0] pc_addr,      // current instruction address

   input                clk,             // system clock
   input  [BITS-7:0]    addr,            // jump address (instr[25:0])
   input                rst_,            // system reset (active low)
   input                jmp,             // take a jump (instr immediate jump)
   input                load_instr,      // load the next address (enable)
   input  [BITS-1:0]    sign_ext_imm,    // branch address (already sign-extended)
   input                equal,           // values equal for branch
   input                breq,            // doing branch on equal
   input                not_equal,       // values not equal for branch
   input                brne,            // doing branch on not equal
   input                jreg,            // jumping to register value
   input  [BITS-1:0]    r1_data          // value read from register file for jreg
   );

  
    logic 		[BITS-1:0] p1_addr;
    logic 		[BITS-1:0] branch_dst;
    logic 		[BITS-1:0] jump_dst;
    logic 		[BITS-1:0] next_addr;
    logic 		[BITS-1:0] jreg_sel;
    logic 		[BITS-1:0] jmp_sel;
    logic 		[BITS-1:0] breq_sel;
    logic 		[BITS-1:0] brne_sel;
    logic 		[BITS-1:0] none_sel;

    //1. increment by default
    assign p1_addr = pc_addr + 1'b1;
    //2. handle conditional branches
    assign branch_dst = pc_addr + sign_ext_imm; 
    assign jump_dst = {pc_addr[BITS-1: BITS-4], 2'b00, addr}; 

    assign jreg_sel = jreg ? r1_data : {BITS{1'b0}}; 
    assign jmp_sel = jmp ? jump_dst : {BITS{1'b0}}; 
    assign breq_sel = (breq && equal) ? branch_dst : {BITS{1'b0}}; 
    assign brne_sel = (brne && not_equal) ? branch_dst : {BITS{1'b0}};

    assign none_sel  = ~(jreg | jmp | (breq && equal) | (brne && not_equal)) ?  p1_addr: {BITS{1'b0}}; 

    assign next_addr = jreg_sel | jmp_sel | breq_sel | brne_sel | none_sel;
 
  
  
   always @(posedge clk or negedge rst_) 
   begin
      if (!rst_) 
      begin
         pc_addr <= { BITS {1'b0 } };
      end 
	else 
	begin
         if (load_instr)
           pc_addr <= next_addr;
        end
   end

endmodule
