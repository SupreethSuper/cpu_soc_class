
// data memory
module memory
  #(
   parameter WORDS=1024,                // default number of words
   parameter BITS=32 ,                   // default number of bits per word
   parameter ADDR_LEFT=$clog2(WORDS)-1,  // log base 2 of the number of words
                                        // which is # of bits needed to address
                                        // the memory for read and write
   parameter [BITS-1:0] BASE_ADDR = 32'h1000
   )
   (

   output [BITS-1:0]  rdata,  // read data

   input              clk,    // system clock
   input  [BITS-1:0]  wdata,  // data to write
   input              rw_,    // read=1, write=0
   input  [BITS-1:0]      addr,   // only uses enough bits to access # of words
   input  [3:0]       byte_en // byte enables
   );

   reg [BITS-1:0] mem[0:WORDS-1]; // default creates 1024 32-bit words
   reg valid_bit; // register to check if address it inside index or not
  always_comb begin
  if ((addr >= BASE_ADDR) && (addr < BASE_ADDR + WORDS)) //condition to check if address in within index or not
  	valid_bit = 1'b1; // if inside index valid_bit is true 
  else
	valid_bit = 1'b0; // otherwise invalid address
  end
  assign rdata = valid_bit ? mem[addr[ADDR_LEFT:0]] : {BITS{1'b0}}; // If address is valid, rdata reads memory at that address, otherwise read zeros
//positive edge of the clock
  always @(posedge clk) begin
    if (!rw_ && valid_bit) begin // only write to memory if its a write operation and address is valid
      case (byte_en) // cases given in homework01 question
        4'b0001: mem[addr[ADDR_LEFT:0]] <= {mem[addr[ADDR_LEFT:0]][31:8],  wdata[7:0]};
        4'b0011: mem[addr[ADDR_LEFT:0]] <= {mem[addr[ADDR_LEFT:0]][31:16], wdata[15:0]};
        4'b1111: mem[addr[ADDR_LEFT:0]] <= wdata;
        default: ; //write is ignored
      endcase
    end
  end
endmodule


