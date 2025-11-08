// test bench for the cpu
module top_cpu4();

   logic        halt;
   logic        exception;
   logic         clk;
   logic         rst_;
   logic  [31:0] counter;

   cpu4 cpu4( .halt(halt), .exception(exception), .clk(clk), .rst_(rst_) );

   initial begin
     $readmemh("i_mem_vals.txt", cpu4.i_memory.mem); // instruction memory
     $readmemh("d_mem_vals.txt", cpu4.d_memory.mem); // data memory
   end

   // ✅ Dump waveforms for GTKWave
   initial begin
     $dumpfile("cpu_waves.vcd");   // output VCD filename
     $dumpvars(0, top_cpu4);       // dump everything inside top_cpu4 hierarchy
     #5;                           // small delay to ensure dump starts
   end

   initial begin
     clk      <= 1'b0;
     rst_     <= 1'b0;
     counter  <= 32'h0;
     #10 rst_ <= 1'b1;
     forever begin
        #10 clk <= 1'b1;
        #10 clk <= 1'b0;
     end
   end

   always @(*) begin
      if (rst_ && exception && !halt)
         $display("Illegal Instruction @ cycle %d", counter);
   end

   always @(posedge clk) begin
      if (halt)
         #5 $finish;  // tiny delay so wave dump is flushed
   end

   always @(negedge clk) begin
     if (rst_)
       counter <= counter + 1;
     if (halt || exception) begin
       #5;
       $finish;
     end
   end

   final begin
     for (integer index = 0; index < 32; index++)
        $display("regfile %d is %h", index, cpu4.regfile.mem[index]);
   end

endmodule
