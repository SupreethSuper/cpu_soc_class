module forward #(
    parameter BITS       = 32,
    parameter REG_WORDS  = 32,
    parameter ADDR_LEFT  = $clog2(REG_WORDS) - 1
)(
    input  logic [ADDR_LEFT:0] r1_addr_s3,
    input  logic [ADDR_LEFT:0] r2_addr_s3,
    input  logic [BITS-1:0]    r1_data_s3,
    input  logic [BITS-1:0]    r2_data_s3,
    input  logic [BITS-1:0]    alu_out_s4,
    input  logic [ADDR_LEFT:0] waddr_s4,
    input  logic               rw_s4,
    output logic [BITS-1:0]    r1_data_fwd,
    output logic [BITS-1:0]    r2_data_fwd
);

    always_comb begin
        // default: pass-through
        r1_data_fwd = r1_data_s3;
        r2_data_fwd = r2_data_s3;

        // forwarding conditions
        if (rw_s4 && (waddr_s4 != 0) && (r1_addr_s3 == waddr_s4))
            r1_data_fwd = alu_out_s4;

        if (rw_s4 && (waddr_s4 != 0) && (r2_addr_s3 == waddr_s4))
            r2_data_fwd = alu_out_s4;
    end
endmodule
