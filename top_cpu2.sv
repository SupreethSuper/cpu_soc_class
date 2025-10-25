`timescale 1ns/1ps

module top_cpu2;

  // ------------------------------------------
  // Parameters
  // ------------------------------------------
  localparam BITS       = 32;
  localparam REG_WORDS  = 32;
  localparam MEM_DEPTH  = 256;
  localparam ADDR_LEFT  = $clog2(REG_WORDS) - 1;

  // ------------------------------------------
  // DUT I/O
  // ------------------------------------------
  logic clk;
  logic rst_;
  logic halt;
  logic exception;

  // ------------------------------------------
  // Memories (Instruction + Data)
  // ------------------------------------------
  logic [BITS-1:0] imem [0:MEM_DEPTH-1];
  logic [BITS-1:0] dmem [0:MEM_DEPTH-1];

  // ------------------------------------------
  // Instantiate DUT (Device Under Test)
  // ------------------------------------------
  cpu3 uut (
    .clk(clk),
    .rst_(rst_),
    .halt(halt),
    .exception(exception)
  );

  // ------------------------------------------
  // Clock Generator (10ns period)
  // ------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // ------------------------------------------
  // Reset Sequence
  // ------------------------------------------
  initial begin
    rst_ = 0;
    #20;
    rst_ = 1;
  end

  // ------------------------------------------
  // Instruction Memory Preload
  // ------------------------------------------
  initial begin
    // Simple arithmetic + load/store + halt test
    // Assemble manually or from assembler
    // Format: $readmemh("program.hex", imem);
    imem[0] = 32'h20010005;  // ADDI R1, R0, 5
    imem[1] = 32'h20020003;  // ADDI R2, R0, 3
    imem[2] = 32'h00221820;  // ADD R3, R1, R2  -> R3 = 8
    imem[3] = 32'hAC030004;  // SW R3, 4(R0)
    imem[4] = 32'h8C040004;  // LW R4, 4(R0)
    imem[5] = 32'h00000000;  // NOP
    imem[6] = 32'hFC000000;  // HALT (custom opcode)
  end

  // ------------------------------------------
  // Data Memory Initialization
  // ------------------------------------------
  initial begin
    for (int i = 0; i < MEM_DEPTH; i++)
      dmem[i] = 32'h00000000;
  end

  // ------------------------------------------
  // Instruction Fetch Emulation
  // ------------------------------------------
  // This assumes cpu3 has an internal PC and an instruction fetch port
  always_ff @(posedge clk) begin
    if (rst_)
      uut.if_stage.instr <= imem[uut.if_stage.pc >> 2];
  end

  // ------------------------------------------
  // Data Memory Access Emulation
  // ------------------------------------------
  always_ff @(posedge clk) begin
    if (rst_) begin
      // Store
      if (uut.mem_stage.mem_rw_s4) begin
        dmem[uut.mem_stage.alu_out_s4 >> 2] <= uut.mem_stage.r2_data_s4;
      end
    end
  end

  // Connect load data back to CPU
  assign uut.mem_stage.mem_data_in = dmem[uut.mem_stage.alu_out_s4 >> 2];

  // ------------------------------------------
  // Monitor - Watch Write-Back Stage
  // ------------------------------------------
  always_ff @(posedge clk) begin
    if (rst_ && uut.wb_stage.rw_s5) begin
      $display("[%0t] WB: R[%0d] <= %h",
        $time, uut.wb_stage.waddr_s5, uut.wb_stage.alu_out_s5);
    end
  end

  // ------------------------------------------
  // Scoreboard - Final Check
  // ------------------------------------------
  initial begin
    wait(halt);
    #10;
    $display("\n--- Simulation Complete ---");
    $display("Register File Snapshot:");
    for (int i = 0; i < 8; i++)
      $display("R[%0d] = %h", i, uut.regfile.regs[i]);

    if (uut.regfile.regs[4] == 32'h00000008)
      $display("✅ TEST PASS: R4 = 8 as expected!");
    else
      $display("❌ TEST FAIL: R4 = %h, expected 8", uut.regfile.regs[4]);

    $finish;
  end

  // ------------------------------------------
  // Waveform Dump
  // ------------------------------------------
  initial begin
    $dumpfile("cpu3_tb.vcd");
    $dumpvars(0, tb_cpu3);
  end

endmodule
