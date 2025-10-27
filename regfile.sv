

`include "regfile_params.vh"

module regfile
   #( //params
        parameter WORDS     =   REG_NUM_WORDS,  
        parameter BITS      =   REG_NUM_BITS,   
        parameter ADDR_LEFT =   $clog2(WORDS)-1, 
                                               
                                                
        parameter BASE_ADDR =   REG_BASE_ADDR
    )
    ( // I/Os
        output [BITS-1:0]   r1_data,  // read data 1
        output [BITS-1:0]   r2_data, //read data 2

        input               clk,    // system clock
        input  [BITS-1:0]   wdata,  // data to write
        input  [ADDR_LEFT:0]   waddr,
        input  [ADDR_LEFT:0]   r2_addr,
        input  [ADDR_LEFT:0]   r1_addr,
        input               rst_,
        input               rw_,    // read=1, write=0
        input  [3:0]        byte_en // byte enables
    );

   //memory description
    logic [BITS-1:0] mem[0:WORDS-1]; // default creates 32 32-bit words
    // Reset + Write
    always_ff @(posedge clk or negedge rst_) begin
        if (!rst_) begin
            for (int i = 0; i < WORDS; i++) begin
                mem[i] <= '0;
            end
        end else if (rw_ == 1'b0) begin
            if (waddr != 1'b0) begin   // block writes to $zero
                case (byte_en)
                    4'b1111: mem[waddr] <= wdata;                // full word
                    4'b0011: mem[waddr][15:0] <= wdata[15:0];    // half word
                    4'b0001: mem[waddr][7:0]  <= wdata[7:0];     // byte
                    default: mem[waddr] <= wdata;                // fallback full word
                endcase
            end
        end
    end

    // Asynchronous read
    assign r1_data = mem[r1_addr];
    assign r2_data = mem[r2_addr];

endmodule

