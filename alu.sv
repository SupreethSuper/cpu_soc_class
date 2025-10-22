/*
// the alu module 

module alu
  #(
   parameter NUM_BITS=32, // default data width
   parameter OP_BITS=4,   // bits needed to define operations
   parameter SHIFT_BITS=5 // bits needed to define shift amount
   )

   (
   output logic [NUM_BITS-1:0] alu_out,     // alu result
   output logic           equal,           // arguments eqaul needed for branches
   output logic           not_equal,       // arguments not equal needed for branches

   input  [NUM_BITS-1:0]   data1,     // two data inputs
   input  [NUM_BITS-1:0]   data2,
   input  [OP_BITS-1:0]    alu_op,    // operation to perform
   input  [SHIFT_BITS-1:0] shamt      // shift amount needed for shifting
   );

   `include "common.vh" // holds the common constant values

   localparam logic [NUM_BITS-1:0] ZERO = {NUM_BITS{1'b0}}; // 32 bit constant 0
   localparam logic [NUM_BITS-1:0] ONE  = {{NUM_BITS-1{1'b0}}, 1'b1};  // 32 bit constant 1
   
   // ALU operation logic begins
   always_comb begin 

   alu_out = ZERO;

   case(alu_op)

	ALU_PASS1: alu_out = data1; // Pass through operation , output first operand
        
        ALU_ADD  : alu_out = data1 + data2; // Addition Operation
    
        ALU_AND  : alu_out = data1 & data2; // Bitwise AND operation
    
        ALU_OR   : alu_out = data1 | data2; // Bitwise OR operation
    
        ALU_NOR  : alu_out = ~(data1 | data2); // Bitwise NOR operation
    
        ALU_SUB  : alu_out = data1 + (~data2 + ONE); // Subtraction Operation
    
       // Comparison operations
       // Signed less-than: check MSBs for sign difference, or do normal compare if signs match
        ALU_LTS: begin
	    logic signed_lt = (data1[NUM_BITS-1] & ~data2[NUM_BITS-1]) | (~(data1[NUM_BITS-1] ^ data2[NUM_BITS-1]) & (data1 < data2));
            alu_out = signed_lt ? ONE : ZERO;
	end
   
        ALU_LTU  : alu_out = (data1 < data2) ? ONE : ZERO; // Unsigned Less than - Direct comparison
    
        ALU_SLL  : alu_out = data2 <<  shamt; // Logical Shift Left                  
    
        ALU_SRL  : alu_out = data2 >>  shamt; // Logical Shift Right
    
        ALU_PASS2: alu_out = data2; // Pass through operation , output second operand
    
	// Arithmetic Shift Right
        ALU_SRA: begin
	      if (shamt == {SHIFT_BITS{1'b0}}) begin
		
		alu_out = data2; // No Shift, Just pass output
	      end
	      else if (shamt >= NUM_BITS) begin
		
		alu_out = {NUM_BITS{data2[NUM_BITS-1]}}; // Shift more than word size -> Fill entire word with sign bit
	      end
	      else begin
		
		logic [NUM_BITS-1:0] logical_part = (data2 >> shamt); // Normal case: combine logical shift result with sign-extended mask
		
		logic [NUM_BITS-1:0] fillmask =
		  ({NUM_BITS{data2[NUM_BITS-1]}} << (NUM_BITS - shamt));
		
		alu_out = logical_part | fillmask;
	      end
	    end
    
        default  : alu_out = ZERO; // Default case: if alu_op doesn’t match anything, output zero

  endcase

  end

  // Equality flags for branch instructions
  assign equal     = (data1 == data2);
  assign not_equal = ~equal;

endmodule
*/

// the alu module 
module alu
  #(
   parameter NUM_BITS=32, // default data width
   parameter OP_BITS=4,   // bits needed to define operations
   parameter SHIFT_BITS=5 // bits needed to define shift amount
   )

   (
   output logic [NUM_BITS-1:0] alu_out,     // alu result

   //equall and not equall pushed to a separate module
  //  output            equal,           // arguments eqaul needed for branches
  //  output            not_equal,       // arguments not equal needed for branches

   input  [NUM_BITS-1:0]   data1,     // two data inputs
   input  [NUM_BITS-1:0]   data2,
   input  [OP_BITS-1:0]    alu_op,    // operation to perform
   input  [SHIFT_BITS-1:0] shamt      // shift amount needed for shifting
   );

   `include "common.vh" // holds the common constant values

logic [NUM_BITS-1:0] ONE ={{NUM_BITS-1{1'b0}},1'b1};
logic [NUM_BITS-1:0] ZERO = {NUM_BITS{1'b0}};


//equal and not equal pushed to a separate module

// assign equal = (data1 == data2);
// assign not_equal = ~(data1 == data2);

always_comb begin

alu_out = ZERO;

case(alu_op)
  ALU_PASS1: alu_out = data1;
  ALU_ADD  : alu_out = data1 + data2;
  ALU_AND  : alu_out = data1 & data2;
  ALU_OR   : alu_out = data1 | data2;
  ALU_NOR  : alu_out = ~(data1 | data2);
  ALU_SUB  : alu_out = data1 + (~data2 + ONE);
  ALU_LTS  : begin
               if (data1[NUM_BITS-1] == data2[NUM_BITS-1]) begin
                  alu_out = (data1 < data2) ? ONE : ZERO;
                end
               else begin
                  alu_out = data1[NUM_BITS-1] ? ONE : ZERO;
                end
              end
  ALU_LTU  : alu_out = data1 < data2 ? ONE : ZERO;
  ALU_SLL  : alu_out = data2 << shamt;
  ALU_SRL  : alu_out = data2 >> shamt;
  ALU_PASS2: alu_out = data2;
  ALU_SRA  : alu_out = (data2 >> shamt) | ({NUM_BITS{data2[NUM_BITS-1]}} << (NUM_BITS - shamt));

default: alu_out = ZERO;

endcase
end
	
endmodule
