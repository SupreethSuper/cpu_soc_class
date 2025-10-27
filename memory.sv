`include "memory_params.vh"

// data memory
module memory
  #(
   // Defaults come from the defines above so they are consistent with the
   // memory_defines.vh file.
   parameter WORDS      = `MEM_NUM_WORDS_DEF,   // default number of words
   parameter BITS       = `MEM_NUM_BITS_DEF,    // default number of bits per word
   parameter BASE_ADDR  = `MEM_BASE_ADDR_DEF,   // 32-bit base address (word-addressed)
   parameter ADDR_LEFT  = $clog2(WORDS)-1       // bits needed to address WORDS
   )
   (

   output reg [BITS-1:0]  rdata,  // read data (combinational)

   input              clk,    // system clock
   input  [BITS-1:0]  wdata,  // data to write
   input              rw_,    // read=1, write=0
   input  [31:0]      addr,   // word-address (32-bit)
   input  [3:0]       byte_en // byte enables
   );

   // memory storage
   reg [BITS-1:0] mem[0:WORDS-1]; // WORDS words, each BITS wide
   wire [ADDR_LEFT:0] word_addr; //always assign the variable in the next line
   wire addr_is_valid;

   assign addr_is_valid = (addr >= BASE_ADDR) && (addr < (BASE_ADDR + WORDS));
   assign word_addr = addr[ADDR_LEFT:0];
   assign rdata = ((rw_ == 1'b1) && ( addr_is_valid)) ? mem[word_addr] : {BITS{1'b0}};


   // --- Write: synchronous on posedge clk ---
   // Allowed byte_en values: 4'b0001 (1 byte), 4'b0011 (2 bytes), 4'b1111 (4 bytes).
   // Other byte_en values: write ignored.
   always @(posedge clk) begin
      if (rw_ == 1'b0) begin // write operation
         if (addr_is_valid  ) begin
           case (byte_en)
               4'b0001: mem [word_addr][7:0] <= wdata[7:0]; 
               4'b0011: mem [word_addr][15:0] <= wdata[15:0];
               4'b1111: mem [word_addr] <= wdata; 
               default: ; 
            endcase
         end
      end
   end

endmodule
