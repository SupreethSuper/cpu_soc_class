`include "common.vh"
`include "instr_reg_params.vh"
`include "regfile.sv"

module pipe_ex_mem
#(
   parameter BITS = 32,
   parameter REG_WORDS = 32,
   parameter ADDR_LEFT = $clog2(REG_WORDS) - 1,
   parameter OP_BITS = 4,
   parameter SHIFT_BITS = 5,
   parameter JMP_LEFT = 25,
   parameter IMM_LEFT = BITS / 2,
   parameter ALU_OP_PARAM = 3
)
(
    input  logic                    clk,
    input  logic                    rst_,

    // From EX stage
    input  logic                    atomic_s3,
    input  logic                    sel_mem_s3,
    input  logic                    check_link_s3,
    input  logic                    mem_rw_s3,
    input  logic                    rw_s3,
    input  logic [ADDR_LEFT:0]      waddr_s3,
    input  logic                    load_link_s3,
    input  logic [BITS-1:0]         r2_data_s3,
    input  logic [BITS-1:0]         r1_data_s3,
    input  logic                    alu_imm_s3,
    input  logic [BITS-1:0]         sign_ext_imm_s3,
    input  logic [SHIFT_BITS-1:0]   shamt_s3,
    input  logic [ALU_OP_PARAM:0]   alu_op_s3,
    input  logic [3:0]              byte_en_s3,
    input  logic                    halt_s3,
    input  logic [BITS-1:0]         alu_out,  // ALU result typically goes to MEM

    // To MEM stage
    output logic                    atomic_s4,
    output logic                    sel_mem_s4,
    output logic                    check_link_s4,
    output logic                    mem_rw_s4,
    output logic                    rw_s4,
    output logic [ADDR_LEFT:0]      waddr_s4,
    output logic                    load_link_s4,
    output logic [BITS-1:0]         r2_data_s4,
    output logic [BITS-1:0]         r1_data_s4,
    output logic                    alu_imm_s4,
    output logic [BITS-1:0]         sign_ext_imm_s4,
    output logic [SHIFT_BITS-1:0]   shamt_s4,
    output logic [ALU_OP_PARAM:0]   alu_op_s4,
    output logic [3:0]              byte_en_s4,
    output logic                    halt_s4,
    output logic [BITS-1:0]         alu_out_s4
);

always_ff @(posedge clk or negedge rst_) begin
    if (~rst_) begin
        atomic_s4        <= 0;
        sel_mem_s4       <= 0;
        check_link_s4    <= 0;
        mem_rw_s4        <= 0;
        rw_s4            <= 0;
        waddr_s4         <= 0;
        load_link_s4     <= 0;
        r2_data_s4       <= 0;
        r1_data_s4       <= 0;
        alu_imm_s4       <= 0;
        sign_ext_imm_s4  <= 0;
        shamt_s4         <= 0;
        alu_op_s4        <= 0;
        byte_en_s4       <= 0;
        halt_s4          <= 0;
        alu_out_s4       <= 0;
    end else begin
        atomic_s4        <= atomic_s3;
        sel_mem_s4       <= sel_mem_s3;
        check_link_s4    <= check_link_s3;
        mem_rw_s4        <= mem_rw_s3;
        rw_s4            <= rw_s3;
        waddr_s4         <= waddr_s3;
        load_link_s4     <= load_link_s3;
        r2_data_s4       <= r2_data_s3;
        r1_data_s4       <= r1_data_s3;
        alu_imm_s4       <= alu_imm_s3;
        sign_ext_imm_s4  <= sign_ext_imm_s3;
        shamt_s4         <= shamt_s3;
        alu_op_s4        <= alu_op_s3;
        byte_en_s4       <= byte_en_s3;
        halt_s4          <= halt_s3;
        alu_out_s4       <= alu_out;
    end
end

endmodule
