// `include "common.vh"

module equality #(
    parameter NUM_BITS = 32
) (
    input  logic [NUM_BITS - 1 : 0]  data1,       // input data
    input  logic [NUM_BITS - 1 : 0]  data2,       // input data
    output logic                     equal,       // equal comparison
    output logic                     not_equal    // not equal comparison
);

assign equal     = (data1 == data2);
assign not_equal = (data1 != data2);

endmodule
