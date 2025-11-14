
module top_cam();

   localparam BITS=8;
   localparam TAG_SZ=8;
   localparam WORDS=8;
   localparam ADDR_LEFT=$clog2(WORDS)-1;

   logic [BITS-1:0]    data;
   logic               found_it;
   logic [TAG_SZ-1:0]  new_tag;
   logic [TAG_SZ-1:0]  check_tag;
   logic               rst_;
   logic               clk;
   logic [ADDR_LEFT:0] w_addr;
   logic [BITS-1:0]    wdata;
   logic               read;
   logic               write_;
   logic               new_valid;

   logic [TAG_SZ-1:0] tag_0;
   logic [TAG_SZ-1:0] tag_1;
   logic [TAG_SZ-1:0] tag_2;
   logic [TAG_SZ-1:0] tag_3;
   logic [TAG_SZ-1:0] tag_4;
   logic [TAG_SZ-1:0] tag_5;
   logic [TAG_SZ-1:0] tag_6;
   logic [TAG_SZ-1:0] tag_7;

   logic [BITS-1:0] data_0;
   logic [BITS-1:0] data_1;
   logic [BITS-1:0] data_2;
   logic [BITS-1:0] data_3;
   logic [BITS-1:0] data_4;
   logic [BITS-1:0] data_5;
   logic [BITS-1:0] data_6;
   logic [BITS-1:0] data_7;

   logic val_0;
   logic val_1;
   logic val_2;
   logic val_3;
   logic val_4;
   logic val_5;
   logic val_6;
   logic val_7;

   cam cam( .data(data), .found_it(found_it),

            .check_tag(check_tag), .read(read),

            .write_(write_), .w_addr(w_addr),
            .wdata(wdata), .new_tag(new_tag), .new_valid(new_valid),

            .clk(clk), .rst_(rst_) );

   initial
   begin
     w_addr    = 3'b0;
     wdata     = 8'h0;
     new_tag   = 8'h1;
     read      = 1'b0;
     write_    = 1'b1;
     check_tag = 8'h0;
     new_valid = 1'b1;
     #10;
     write_    = 1'b0;
     new_tag = 8'h5; wdata = 8'h11; w_addr = 3'h1;
     wait(clk == 1'b1);
     wait(clk == 1'b0);

     new_tag = 8'h6; wdata = 8'h13; w_addr = 3'h3;
     wait(clk == 1'b1);
     wait(clk == 1'b0);

     new_tag = 8'h0; wdata = 8'h15; w_addr = 3'h5;
     wait(clk == 1'b1);
     wait(clk == 1'b0);

     new_tag = 8'h4; wdata = 8'h16; w_addr = 3'h6;
     wait(clk == 1'b1);
     wait(clk == 1'b0);

     new_tag = 8'h9; wdata = 8'h17; w_addr = 3'h7;
     wait(clk == 1'b1);
     wait(clk == 1'b0);
     write_ = 1'b1;
     read   = 1'b1;
     new_valid = 1'b0;
     new_tag = 8'h0;
     check_tag = 8'h0; wdata = 8'h0; w_addr = 3'h0;

     wait(clk == 1'b1);
     wait(clk == 1'b0);
     check_tag = 8'h5;
     wait(clk == 1'b1);
     wait(clk == 1'b0);
     check_tag = 8'h6;
     wait(clk == 1'b1);
     wait(clk == 1'b0);
     check_tag = 8'h7;
     wait(clk == 1'b1);
     wait(clk == 1'b0);
     check_tag = 8'h0;
     wait(clk == 1'b1);
     wait(clk == 1'b0);
     check_tag = 8'h4;
     wait(clk == 1'b1);
     wait(clk == 1'b0);
     check_tag = 8'h9;
     wait(clk == 1'b1);
     wait(clk == 1'b0);
     check_tag = 8'h1;
     wait(clk == 1'b1);
     wait(clk == 1'b0);
     $finish;
   end

   initial
   begin
     clk <= 1'b0;
     rst_ <= 1'b0;
     #10 rst_ <= 1'b1;
     while ( 1'b1 )
     begin
        #10 clk <= 1'b1;
        #10 clk <= 1'b0;
     end
   end

   initial
     begin
      $dumpfile("cam.vcd");      // dump the waves
      $dumpvars(0,top_cam);
   end

   assign tag_0 = cam.tag_mem[0];
   assign tag_1 = cam.tag_mem[1];
   assign tag_2 = cam.tag_mem[2];
   assign tag_3 = cam.tag_mem[3];
   assign tag_4 = cam.tag_mem[4];
   assign tag_5 = cam.tag_mem[5];
   assign tag_6 = cam.tag_mem[6];
   assign tag_7 = cam.tag_mem[7];

   assign data_0 = cam.data_mem[0];
   assign data_1 = cam.data_mem[1];
   assign data_2 = cam.data_mem[2];
   assign data_3 = cam.data_mem[3];
   assign data_4 = cam.data_mem[4];
   assign data_5 = cam.data_mem[5];
   assign data_6 = cam.data_mem[6];
   assign data_7 = cam.data_mem[7];

   assign val_0 = cam.val_mem[0];
   assign val_1 = cam.val_mem[1];
   assign val_2 = cam.val_mem[2];
   assign val_3 = cam.val_mem[3];
   assign val_4 = cam.val_mem[4];
   assign val_5 = cam.val_mem[5];
   assign val_6 = cam.val_mem[6];
   assign val_7 = cam.val_mem[7];
endmodule
