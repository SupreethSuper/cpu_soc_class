// test bench for the cpu
module top_cpu3();

   //logic [31:0] rdata;
   logic        halt;
   logic        exception;

   logic         clk;
   logic         rst_;
   logic  [31:0] counter;


    logic [31:0] r_zero;   // 0
    logic [31:0] r_at;     // 1
    logic [31:0] r_v0, r_v1; // 2-3
    logic [31:0] r_a0, r_a1, r_a2, r_a3; // 4-7
    logic [31:0] r_t0, r_t1, r_t2, r_t3, r_t4, r_t5, r_t6, r_t7; // 8-15
    logic [31:0] r_s0, r_s1, r_s2, r_s3, r_s4, r_s5, r_s6, r_s7; // 16-23
    logic [31:0] r_t8, r_t9; // 24-25
    logic [31:0] r_k0, r_k1; // 26-27
    logic [31:0] r_gp; // 28
    logic [31:0] r_sp; // 29
    logic [31:0] r_fp; // 30
    logic [31:0] r_ra; // 31


    logic [31:0] m_mem0;
    logic [31:0] m_mem1;
    logic [31:0] m_mem2;
    logic [31:0] m_mem3;
    logic [31:0] m_mem4;
    logic [31:0] m_mem5;
    logic [31:0] m_mem6;
    logic [31:0] m_mem7;
    logic [31:0] m_mem8;
    logic [31:0] m_mem9;
    logic [31:0] m_mem10;
    logic [31:0] m_mem11;
    logic [31:0] m_mem12;
    logic [31:0] m_mem13;
    logic [31:0] m_mem14;
    logic [31:0] m_mem15;
    logic [31:0] m_mem16;
    logic [31:0] m_mem17;
    logic [31:0] m_mem20;
    logic [31:0] m_mem21;
    logic [31:0] m_mem22;
    logic [31:0] m_mem23;
    logic [31:0] m_mem24;


    assign r_zero = cpu3.regfile.mem[0];
    assign r_at   = cpu3.regfile.mem[1];
    assign r_v0   = cpu3.regfile.mem[2];
    assign r_v1   = cpu3.regfile.mem[3];
    assign r_a0   = cpu3.regfile.mem[4];
    assign r_a1   = cpu3.regfile.mem[5];
    assign r_a2   = cpu3.regfile.mem[6];
    assign r_a3   = cpu3.regfile.mem[7];
    assign r_t0   = cpu3.regfile.mem[8];
    assign r_t1   = cpu3.regfile.mem[9];
    assign r_t2   = cpu3.regfile.mem[10];
    assign r_t3   = cpu3.regfile.mem[11];
    assign r_t4   = cpu3.regfile.mem[12];
    assign r_t5   = cpu3.regfile.mem[13];
    assign r_t6   = cpu3.regfile.mem[14];
    assign r_t7   = cpu3.regfile.mem[15];
    assign r_s0   = cpu3.regfile.mem[16];
    assign r_s1   = cpu3.regfile.mem[17];
    assign r_s2   = cpu3.regfile.mem[18];
    assign r_s3   = cpu3.regfile.mem[19];
    assign r_s4   = cpu3.regfile.mem[20];
    assign r_s5   = cpu3.regfile.mem[21];
    assign r_s6   = cpu3.regfile.mem[22];
    assign r_s7   = cpu3.regfile.mem[23];
    assign r_t8   = cpu3.regfile.mem[24];
    assign r_t9   = cpu3.regfile.mem[25];
    assign r_k0   = cpu3.regfile.mem[26];
    assign r_k1   = cpu3.regfile.mem[27];
    assign r_gp   = cpu3.regfile.mem[28];
    assign r_sp   = cpu3.regfile.mem[29];
    assign r_fp   = cpu3.regfile.mem[30];
    assign r_ra   = cpu3.regfile.mem[31];

    assign m_mem0  = cpu3.i_memory.mem[0];
    assign m_mem1  = cpu3.i_memory.mem[1];
    assign m_mem2  = cpu3.i_memory.mem[2];
    assign m_mem3  = cpu3.i_memory.mem[3];
    assign m_mem4  = cpu3.i_memory.mem[4];
    assign m_mem5  = cpu3.i_memory.mem[5];
    assign m_mem6  = cpu3.i_memory.mem[6];
    assign m_mem7  = cpu3.i_memory.mem[7];
    assign m_mem8  = cpu3.i_memory.mem[8];
    assign m_mem9  = cpu3.i_memory.mem[9];
    assign m_mem10 = cpu3.i_memory.mem[10];
    assign m_mem11 = cpu3.i_memory.mem[11];
    assign m_mem12 = cpu3.i_memory.mem[12];
    assign m_mem13 = cpu3.i_memory.mem[13];
    assign m_mem14 = cpu3.i_memory.mem[14];
    assign m_mem15 = cpu3.i_memory.mem[15];
    assign m_mem16 = cpu3.i_memory.mem[16];
    assign m_mem17 = cpu3.i_memory.mem[17];
    assign m_mem20 = cpu3.i_memory.mem[20];
    assign m_mem21 = cpu3.i_memory.mem[21];
    assign m_mem22 = cpu3.i_memory.mem[22];
    assign m_mem23 = cpu3.i_memory.mem[23]; //
    assign m_mem24 = cpu3.i_memory.mem[24];

   cpu3 cpu3( .halt(halt), .exception(exception), .clk(clk), .rst_(rst_) );
   initial // read the array to load the program
   begin
     $readmemh("i_mem_vals.txt",cpu3.i_memory.mem); // loading the memory
     $readmemh("i_mem_vals_d.txt",cpu3.d_memory.mem);
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
        $display("regfile %d is %h",index,cpu3.regfile.mem[index]);
  end

  //initial
  //begin
  //  $dumpfile("cpu_waves.vcd");      // dump the waves to view on your laptop
  //  $dumpvars(0,top_cpu);
  //end
endmodule
