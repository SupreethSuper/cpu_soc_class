module forward #(
    parameter BITS       = 2,
    parameter REG_WORDS  = 32,
    parameter ADDR_LEFT  = $clog2(REG_WORDS) - 1
)(
    // input  logic                 clk,
    // input  logic                 rst_,

input logic [ADDR_LEFT : 0] r1_addr_s3,
input logic [ADDR_LEFT : 0] r2_addr_s3,
input logic rw_s4,
input logic [ADDR_LEFT] waddr_s4,
);




endmodule
