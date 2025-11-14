// Cache using CAM
module cam
  #(
   parameter WORDS=8,                   // default number of words
   parameter BITS=8,                    // default number of bits per word
   parameter ADDR_LEFT=$clog2(WORDS)-1, // log base 2 of the number of words
                                        // which is # of bits needed to address
                                        // the memory for read and write
   parameter TAG_SZ=8                   // size of the tag
   )
   (

   output logic [BITS-1:0]    data,        // the data
   output logic               found_it,    // was in the CAM

   input  [TAG_SZ-1:0]        check_tag,   // the tag to match
   input                      read,        // read signal

   input                      write_,      // write_ signal
   input  [ADDR_LEFT:0]       w_addr,      // address to write
   input  [BITS-1:0]          wdata,       // data to write
   input  [TAG_SZ-1:0]        new_tag,     // the new tag
   input                      new_valid,   // new valid bit

   input                      clk,         // system clock
   input                      rst_         // system reset
   );

   `include "cam_params.vh"

   logic [BITS-1:0]   data_mem[0:WORDS-1]; // data memory
   logic [TAG_SZ-1:0] tag_mem[0:WORDS-1];  // tag memory
   logic [WORDS-1:0]  val_mem;             // valid memory

   integer index;                       // for the loop
   logic [ADDR_LEFT:0] match_index;     // where we found it
   logic found;                         // did we find it

   assign data = { BITS { 1'b0 } };
   assign found_it = 1'b0;

endmodule
