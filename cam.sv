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
//---------------------outputs only----------------------------------------------
   output logic [BITS-1:0]    data,        // the data
   output logic               found_it,    // was in the CAM
//----------------------end of outputs--------------------------------------------

//------------------------inputs only-------------------------------------------

//----------------------------control signals-------------------------------------
   input                      read,        // read signal
   input                      clk,         // system clock
   input                      write_,      // write_ signal
   input                      rst_         // system reset
   input                      new_valid,   // new valid bit
//---------------------------------------------------------------------------------

//-----------------------------------data------------------------------------------
   input  [TAG_SZ-1:0]        check_tag,   // the tag to match
   input  [ADDR_LEFT:0]       w_addr,      // address to write
   input  [BITS-1:0]          wdata,       // data to write
   input  [TAG_SZ-1:0]        new_tag,     // the new tag
//--------------------------------------------------------------------------------------
   );

   `include "cam_params.vh"

   logic [BITS-1:0]   data_mem[0:WORDS-1]; // data memory
   logic [TAG_SZ-1:0] tag_mem[0:WORDS-1];  // tag memory
   logic [WORDS-1:0]  val_mem;             // valid memory

   integer index;                       // for the loop
   logic [ADDR_LEFT:0] match_index;     // where we found it
   logic found;                         // did we find it

   //the reset block
   always_ff @( posedge clk or negedge rst_ ) begin //reset
    
    if(!rst_) begin
      //all the mems set to 0
      for(index < 0; index < WORDS; index = index + 1) begin
        data_mem[ index ] <= { BITS { 1'b0 } };
        tag_mem [ index ] <= { BITS { 1'b0 } };
        val_mem [ index ] <= { BITS { 1'b0 } };
      end

      else begin
        //now checking if write_ == 0, cause condition executing at !write_, which means that !write_ =1, which means that write_ = 0
        if(write_)

          data_mem[ w_addr ] <= wdata;
          tag_mem [ w_addr ] <= new_tag;
          val_mem [ w_addr ] <= new_valid;
      end
      //if not the write_, then its the read, and using if, cause not taking the risk of using if else
      // if(read) begin
        



      // end
    end


   end

//I guess this is equlivalent to if(read)
always @(read) begin
    found       = 1'b0;
    match_index = INDEX[0];

    for (index = 0; index < WORDS; index = index + 1) begin
        if (val_mem[index] && (tag_mem[index] == input_tag)) begin
            match_index = INDEX[index];
            found       = 1'b1;
        end
    end
end



   assign data = found ? data_mem[match_index] : { BITS { 1'b0 } };
   assign found_it = found;

endmodule
