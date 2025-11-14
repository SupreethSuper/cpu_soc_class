// forward.sv
// Forwarding + Stall logic for data, jump, and branch hazards
module forward #(
    parameter BITS       = 32,
    parameter REG_WORDS  = 32,
    parameter ADDR_LEFT  = $clog2(REG_WORDS) - 1
)(
    // ===========================
    // Inputs
    // ===========================
    input  logic [ADDR_LEFT:0] r1_addr_s3,
    input  logic [ADDR_LEFT:0] r2_addr_s3,
    input  logic [ADDR_LEFT:0] waddr_s3,
    input  logic [ADDR_LEFT:0] waddr_s4,
    input  logic [ADDR_LEFT:0] waddr_s5,
    input  logic [ADDR_LEFT:0] r1_addr,    // current decode stage
    input  logic [ADDR_LEFT:0] r2_addr,

    input  logic               rw_s3,
    input  logic               rw_s4,
    input  logic               rw_s5,

    input  logic               sel_mem_s3,
    input  logic               sel_mem_s4,
    input  logic               sel_mem_s5,

    input  logic [BITS-1:0]    alu_out_s4,
    input  logic [BITS-1:0]    alu_out_s5,
    input  logic [BITS-1:0]    d_mem_rdata_s5,

    input  logic               jreg,       // jump register flag
    input  logic               breq,       // beq
    input  logic               brne,       // bne

    // ===========================
    // Outputs
    // ===========================
    output logic [BITS-1:0] r1_fwd_s4,
    output logic [BITS-1:0] r2_fwd_s4,
    output logic [BITS-1:0] r1_fwd_s5,
    output logic [BITS-1:0] r2_fwd_s5,
    output logic [BITS-1:0] r1_fwd_s6,
    output logic [BITS-1:0] r2_fwd_s6,

    output logic [BITS-1:0] j_fwd_s4,      // jr forwarding from stage 4
    output logic [BITS-1:0] j_fwd_s5,      // jr forwarding from stage 5

    output logic [BITS-1:0] b_r1_fwd_s4,   // branch forwarding
    output logic [BITS-1:0] b_r2_fwd_s4,
    output logic [BITS-1:0] b_r1_fwd_s5,
    output logic [BITS-1:0] b_r2_fwd_s5,

    output logic             stall_pipe
);

    logic [BITS-1:0] reg_wdata_s5;
    assign reg_wdata_s5 = sel_mem_s5 ? d_mem_rdata_s5 : alu_out_s5;

    // Default passthrough
    always_comb begin
        stall_pipe = 1'b0;

        r1_fwd_s4 = '0; r2_fwd_s4 = '0;
        r1_fwd_s5 = '0; r2_fwd_s5 = '0;
        r1_fwd_s6 = '0; r2_fwd_s6 = '0;
        j_fwd_s4  = '0; j_fwd_s5  = '0;
        b_r1_fwd_s4 = '0; b_r2_fwd_s4 = '0;
        b_r1_fwd_s5 = '0; b_r2_fwd_s5 = '0;

        // =======================
        // DATA FORWARDING (same as before)
        // =======================
        if (rw_s4 && (waddr_s4 != 0)) begin
            if (r1_addr_s3 == waddr_s4) r1_fwd_s4 = alu_out_s4;
            if (r2_addr_s3 == waddr_s4) r2_fwd_s4 = alu_out_s4;
        end
        if (rw_s5 && (waddr_s5 != 0)) begin
            if (r1_addr_s3 == waddr_s5) r1_fwd_s4 = reg_wdata_s5;
            if (r2_addr_s3 == waddr_s5) r2_fwd_s4 = reg_wdata_s5;
        end

        // =======================
        // JUMP REGISTER (jr) forwarding/stall logic
        // =======================
        // Stage 4 → JR
        if (jreg && rw_s4 && (waddr_s4 == r1_addr))
            j_fwd_s4 = alu_out_s4;

        // Stage 5 → JR
        if (jreg && rw_s5 && (waddr_s5 == r1_addr))
            j_fwd_s5 = reg_wdata_s5;

        // One-cycle stall: JR depends on Stage 3 (value not computed yet)
        if (jreg && rw_s3 && (waddr_s3 == r1_addr))
            stall_pipe = 1'b1;

        // Two-cycle stall: JR depends on load still in Stage 4
        if (jreg && sel_mem_s4 && (waddr_s4 == r1_addr))
            stall_pipe = 1'b1;

        // =======================
        // BRANCH forwarding/stall logic
        // =======================
        if ((breq || brne)) begin
            // stage 4 forward
            if (rw_s4 && (waddr_s4 != 0)) begin
                if (r1_addr == waddr_s4) b_r1_fwd_s4 = alu_out_s4;
                if (r2_addr == waddr_s4) b_r2_fwd_s4 = alu_out_s4;
            end
            // stage 5 forward
            if (rw_s5 && (waddr_s5 != 0)) begin
                if (r1_addr == waddr_s5) b_r1_fwd_s5 = reg_wdata_s5;
                if (r2_addr == waddr_s5) b_r2_fwd_s5 = reg_wdata_s5;
            end
            // stalls similar to jr
            if (rw_s3 && ((waddr_s3 == r1_addr) || (waddr_s3 == r2_addr)))
                stall_pipe = 1'b1;
            if (sel_mem_s4 && ((waddr_s4 == r1_addr) || (waddr_s4 == r2_addr)))
                stall_pipe = 1'b1;
        end
    end

endmodule
