  `include "common.vh"
  `include "instr_reg_params.vh"
module pipe_if_id
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

        input logic [BITS - 1 : 0] pc_addr_s1,
        output logic clk_s1,
        output logic load_instr_s1,
        output logic [BITS -1 : 0] mem_data_s1,
        output logic rst__s1,
        output logic equal_s1,
        output logic not_equal


   );




   endmodule

