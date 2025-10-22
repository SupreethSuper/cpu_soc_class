`timescale 1ps/1ps
// `include "common.vh"
// `include "eqNE_.sv"

module tb_eqNe();

localparam NUM_BITS = 32;

logic [NUM_BITS - 1 : 0] data1, data2;
logic eq, ne;

// Instantiate the DUT
eqNE_ #(.NUM_BITS(NUM_BITS)) dut (
    .data1(data1),
    .data2(data2),
    .equal(eq),
    .not_equal(ne)
);

initial begin
    $dumpfile("tb_eqNe.vcd");
    $dumpvars(0, tb_eqNe);

    data1 = {32'd16};
    data2 = 32'd32;
    #20;
    data1 = 32'd32;
    data2 = 32'd32;
    #20;

    $display("test complete");
    $finish;
end

endmodule
