`timescale 1ps/1ps



module tb_eqNe();

logic halt, exception, clk, rst_;

cpu3 dut(
    .halt       (halt),
    .exception  (exception),
    .clk        (clk),
    .rst_       (rst_)
);

initial begin
    $display("starting test");

    rst_ =      1'b1;
    $display("reset is being set to %d\n", rst_);
    //halt =      1'b0; --> cause its an output
    $monitor("halt is beging set to %d\n", halt);
   // exception = 1'b0; --> cause its an output
    $monitor("halt is beging set to %d\n", exception);
    rst_ =       1'b0;
    $display("reset is being set to %d\n", rst_);
end

//begin and end for dumping wave files
initial begin
    $dumpfile("tb_cpuTest0.vcd");
    $dumpvars(0, tb_eqNe);
end

initial begin
    clk = 1'b0;
end

//clk cycle
always begin

    clk <=  ~clk;
    #0.5;

end    


//main tb logic

always begin

    #3;
    rst_ =      1'b0;
    $display("reset is being set to %d\n", rst_);
   // exception = 1'b0; --> cause its an output
 //   $monitor("Exception is beging set to %d\n", exception);    
     rst_ = 1'b1;
     #5;
     #3 rst_ = 1'b0;
   // exception = 1'b0; --> cause its an output
    $monitor("Exception is beging set to %b\n", exception);    
    #5

    //halt =      1'b0; --> cause its an output

    // $monitor("halt is beging set to %d\n", halt); --> only one monitor statement is enough    
    #5
    //halt =      1'b0; --> cause its an output

    $monitor("halt is beging set to %b\n", halt);    
    #15;

end    

//finish block of always
always begin


#50 $display("test over, stopping test");
$finish;


end    



endmodule
