
// the register file - 2 read, 1 write
module regfile
  #(
   parameter WORDS=32,                  // default number of words
   parameter BITS=32,                   // default number of bits per word
   parameter ADDR_LEFT=$clog2(WORDS)-1  // log base 2 of the number of words
                                        // which is # of bits needed to address
                                        // the memory for read and write
   )
   (

   output [BITS-1:0] r1_data,          // read value 1
   output [BITS-1:0] r2_data,          // read value 2

   input                clk,           // system clock
   input		rst_,	       // active-low reset
   input                rw_,           // read=1, write=0
   input  [BITS-1:0]    wdata,         // data to write
   input  [ADDR_LEFT:0]        waddr,         // write address
   input  [ADDR_LEFT:0]        r1_addr,       // read address 1
   input  [ADDR_LEFT:0]        r2_addr,       // read address 2
   input  [3:0]         byte_en        // byte enables
   );

   logic [BITS-1:0] mem[0:WORDS-1]; // default creates 32 32-bit words
  // logic signal to indicate if address is within range or not
  
  integer i;

  // Output read values. If address is valid, output memory content;
  // otherwise, output zeros
  assign r1_data = mem[r1_addr];
  assign r2_data = mem[r2_addr];

  always_ff @(posedge clk or negedge rst_) begin
     if (!rst_) begin
       for (i = 0; i < WORDS; i = i + 1)
         mem[i] <= {BITS{1'b0}};
     end
     else begin

//positive edge of the clock
  if (!rw_ && (waddr != {ADDR_LEFT+1{1'b0}})) begin
         case (byte_en)
           4'b0001: mem[waddr] <= {mem[waddr][BITS-1:8],  wdata[7:0]};
           4'b0011: mem[waddr] <= {mem[waddr][BITS-1:16], wdata[15:0]};
           4'b1111: mem[waddr] <= wdata;
           default: mem[waddr] <= wdata; // treat other cases as full write
         endcase
       end
     end
   mem[0] <= {BITS{1'b0}};
   end
endmodule


