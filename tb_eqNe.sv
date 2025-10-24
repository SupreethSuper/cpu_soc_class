`timescale 1ps/1ps


module tb_eqNe();

logic halt, exception, clk, rst_;

cpu3 dut(
    .halt       (halt),
    .exception  (exception),
    .clk        (clk),
    .rst_       (rst_)
)

initial begin
    $display("starting test");

    rst_ =      1'b0;
    $display("reset is being set to %d\n", rst_);
    halt =      1'b0;
    display("halt is beging set to %d\n", halt);
    exception = 1'b0;
    display("halt is beging set to %d\n", exception);
end

//clk cycle
always begin

    clk =   1'b1;
    #1
    clk =    1'b0;

end    


//main tb logic

always begin

    #3
    rst_ =      1'b0;
    $display("reset is being set to %d\n", rst_);
    exception = 1'b1; #5
    
    exception = 1'b0;
    #5

    halt = 1'b0;
    #5
    halt = 1'b1;
    #15

end    

//finish block of always
always begin


#50, $display("test over, stopping test");
$finish;


end    



endmodule
