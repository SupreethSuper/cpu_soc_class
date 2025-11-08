Assignment homework08 has been submitted
[sathrey5@eecad104 homework08]$ vi top_cpu4.sv
// test bench for the cpu
module top_cpu4();

   //logic [31:0] rdata;
   logic        halt;
   logic        exception;

   logic         clk;
   logic         rst_;
   logic  [31:0] counter;




   cpu4 cpu4( .halt(halt), .exception(exception), .clk(clk), .rst_(rst_) );
   initial // read the array to load the program
   begin
     $readmemh("i_mem_vals.txt",cpu4.i_memory.mem); // loading the memory
     $readmemh("i_mem_vals_d.txt",cpu4.d_memory.mem);
     //for ( integer ind = 0 ; ind < 5 ; ind++ )
     //   $display("memory index %d is %h",ind,cpu.i_memory.mem[ind]);
   end



   initial
   begin
     clk <= 1'b0;
     rst_ <= 1'b0;
     counter <= 32'h0;
     #10 rst_ <= 1'b1;
     while ( 1 )
     begin
        #10 clk <= 1'b1;
        #10 clk <= 1'b0;
     end
   end

   always @ ( * )
   begin
      if ( ( rst_ == 1'b1 ) && ( exception == 1'b1 ) && ( halt == 1'b0 ) )
        $display("Illegal Instruction @ cycle %d", counter);
   end

   always @ ( posedge clk )
   begin
      if ( halt == 1'b1 )
         $finish;
   end

 always @ (negedge clk)
   begin
     if (rst_ == 1'b1)
       counter <= counter + 1;
     if (halt || exception)
     begin
       #5;
       $finish;
     end
   end

  final   // dump the regfile to verify things worked
  begin
     for ( integer index = 0 ; index < 32 ; index++ )
        $display("regfile %d is %h",index,cpu4.regfile.mem[index]);
  end

  //initial
  //begin
  //  $dumpfile("cpu_waves.vcd");      // dump the waves to view on your laptop
  //  $dumpvars(0,top_cpu);
  //end
endmodule

