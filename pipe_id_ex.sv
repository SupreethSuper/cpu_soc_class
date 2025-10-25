// `include "common.vh"
// `include "instr_reg_params.vh"
// `include "regfile.sv"

module pipe_id_ex
#(
   parameter BITS=32,
   parameter REG_WORDS=32,
   parameter ADDR_LEFT=$clog2(REG_WORDS)-1,
   parameter OP_BITS=4,
   parameter SHIFT_BITS=5,
   parameter JMP_LEFT=25,
   parameter IMM_LEFT=BITS/2,
   parameter ALU_OP_PARAM=3
)
(
    input  logic                    clk,
    input  logic                    rst_,

    // From ID stage
    input  logic                    atomic,
    input  logic                    sel_mem,
    input  logic                    check_link,
    input  logic                    mem_rw_,
    input  logic                    rw_,
    input  logic [ADDR_LEFT:0]      waddr,
    input  logic                    load_link_,
    input  logic [BITS-1:0]         r2_data,
    input  logic [BITS-1:0]         r1_data,
    input  logic                    alu_imm,
    input  logic [BITS-1:0]         sign_ext_imm,
    input  logic [SHIFT_BITS-1:0]   shamt,
    input  logic [ALU_OP_PARAM:0]   alu_op,
    input  logic [3:0]              byte_en,
    input  logic                    halt_s2,

    // To EX stage
    output logic                    atomic_s3,
    output logic                    sel_mem_s3,
    output logic                    check_link_s3,
    output logic                    mem_rw_s3,
    output logic                    rw_s3,
    output logic [ADDR_LEFT:0]      waddr_s3,
    output logic                    load_link_s3,
    output logic [BITS-1:0]         r2_data_s3,
    output logic [BITS-1:0]         r1_data_s3,
    output logic                    alu_imm_s3,
    output logic [BITS-1:0]         sign_ext_imm_s3,
    output logic [SHIFT_BITS-1:0]   shamt_s3,
    output logic [ALU_OP_PARAM:0]   alu_op_s3,
    output logic [3:0]              byte_en_s3,
    output logic                    halt_s3
);

always_ff @(posedge clk or negedge rst_) begin
    if (~rst_) begin
        atomic_s3        <= 0;
        sel_mem_s3       <= 0;
        check_link_s3    <= 0;
        mem_rw_s3        <= 0;
        rw_s3            <= 0;
        waddr_s3         <= 0;
        load_link_s3     <= 0;
        r1_data_s3       <= 0;
        r2_data_s3       <= 0;
        alu_imm_s3       <= 0;
        sign_ext_imm_s3  <= 0;
        shamt_s3         <= 0;
        alu_op_s3        <= 0;
        byte_en_s3       <= 0;
        halt_s3          <= 0;
    end else begin
        atomic_s3        <= atomic;
        sel_mem_s3       <= sel_mem;
        check_link_s3    <= check_link;
        mem_rw_s3        <= mem_rw_;
        rw_s3            <= rw_;
        waddr_s3         <= waddr;
        load_link_s3     <= load_link_;
        r1_data_s3       <= r1_data;
        r2_data_s3       <= r2_data;
        alu_imm_s3       <= alu_imm;
        sign_ext_imm_s3  <= sign_ext_imm;
        shamt_s3         <= shamt;
        alu_op_s3        <= alu_op;
        byte_en_s3       <= byte_en;
        halt_s3          <= halt_s2;
    end
end

endmodule
