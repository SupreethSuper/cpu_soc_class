// `include "common.vh"
// `include "instr_reg_params.vh"
// `include "regfile.sv"

module pipe_mem_wb
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

    // From MEM stage (S4)
    input  logic                    atomic_s4,
    input  logic                    sel_mem_s4,
    input  logic                    check_link_s4,
    input  logic                    mem_rw_s4,
    input  logic                    rw_s4,
    input  logic [ADDR_LEFT:0]      waddr_s4,
    input  logic                    load_link_s4,
    input  logic [BITS-1:0]         r2_data_s4,
    input  logic [BITS-1:0]         r1_data_s4,
    input  logic                    alu_imm_s4,
    input  logic [BITS-1:0]         sign_ext_imm_s4,
    input  logic [SHIFT_BITS-1:0]   shamt_s4,
    input  logic [ALU_OP_PARAM:0]   alu_op_s4,
    input  logic [3:0]              byte_en_s4,
    input  logic                    halt_s4,
    input  logic [BITS-1:0]         alu_out_s4,

    // To WB stage (S5)
    output logic                    atomic_s5,
    output logic                    sel_mem_s5,
    output logic                    check_link_s5,
    output logic                    mem_rw_s5,
    output logic                    rw_s5,
    output logic [ADDR_LEFT:0]      waddr_s5,
    output logic                    load_link_s5,
    output logic [BITS-1:0]         r2_data_s5,
    output logic [BITS-1:0]         r1_data_s5,
    output logic                    alu_imm_s5,
    output logic [BITS-1:0]         sign_ext_imm_s5,
    output logic [SHIFT_BITS-1:0]   shamt_s5,
    output logic [ALU_OP_PARAM:0]   alu_op_s5,
    output logic [3:0]              byte_en_s5,
    output logic                    halt_s5,
    output logic [BITS-1:0]         alu_out_s5
);

    // ------------------------------
    // MEM/WB Pipeline Register
    // ------------------------------
    always_ff @(posedge clk or negedge rst_) begin
        if (!rst_) begin
            atomic_s5      <= 0;
            sel_mem_s5     <= 0;
            check_link_s5  <= 0;
            mem_rw_s5      <= 0;
            rw_s5          <= 0;
            waddr_s5       <= 0;
            load_link_s5   <= 0;
            r2_data_s5     <= 0;
            r1_data_s5     <= 0;
            alu_imm_s5     <= 0;
            sign_ext_imm_s5<= 0;
            shamt_s5       <= 0;
            alu_op_s5      <= 0;
            byte_en_s5     <= 0;
            halt_s5        <= 0;
            alu_out_s5     <= 0;
        end else begin
            atomic_s5      <= atomic_s4;
            sel_mem_s5     <= sel_mem_s4;
            check_link_s5  <= check_link_s4;
            mem_rw_s5      <= mem_rw_s4;
            rw_s5          <= rw_s4;
            waddr_s5       <= waddr_s4;
            load_link_s5   <= load_link_s4;
            r2_data_s5     <= r2_data_s4;
            r1_data_s5     <= r1_data_s4;
            alu_imm_s5     <= alu_imm_s4;
            sign_ext_imm_s5<= sign_ext_imm_s4;
            shamt_s5       <= shamt_s4;
            alu_op_s5      <= alu_op_s4;
            byte_en_s5     <= byte_en_s4;
            halt_s5        <= halt_s4;
            alu_out_s5     <= alu_out_s4;
        end
    end

endmodule
