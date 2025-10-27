// the alu module 
 `include "common.vh" // holds the common constant values
module alu
  #(
   parameter NUM_BITS=32, // default data width
   parameter OP_BITS=4,   // bits needed to define operations
   parameter SHIFT_BITS=5 // bits needed to define shift amount
   )

   (
   output logic [NUM_BITS-1:0] alu_out,     // alu result
   output logic         equal,           // arguments eqaul needed for branches
   output logic      not_equal,       // arguments not equal needed for branches

   input  [NUM_BITS-1:0]   data1,     // two data inputs
   input  [NUM_BITS-1:0]   data2,
   input  [OP_BITS-1:0]    alu_op,    // operation to perform
   input  [SHIFT_BITS-1:0] shamt      // shift amount needed for shifting
   );
  logic [NUM_BITS:0]out=0;
  logic [NUM_BITS:0]comp_data2=0;
  logic [NUM_BITS-1:0]temp_data;
  logic msb_bit;
 
    

 always @ (*)
begin
  equal     = (data1 == data2);
  not_equal = (data1 != data2);


  case(alu_op)
	
	ALU_PASS1:	begin
		  	alu_out = data1;
		   	end

	ALU_ADD	 :	begin
			alu_out = (data1 + data2);
			end	
	
	ALU_AND  :  	begin
			alu_out = (data1 & data2);
			end	
	ALU_OR   :      begin
			alu_out = (data1 | data2);
			end
	ALU_NOR  :	begin
			alu_out = ~(data1 | data2);
			end

	ALU_SUB  :	begin
       			 if(data1==data2)
        			begin
            			alu_out[31:0] = 0;
				equal = 1;
				not_equal = 0;
         			end
     			
			else
				begin
          			comp_data2[31:0] = ~(data2) + 1;
         			out[32:0] = data1[31:0]+comp_data2[31:0];
          			alu_out[31:0] = out[31:0];
				not_equal = 1;
				equal = 0;
        			end
    			end

     	ALU_LTS  :	begin
			case({data1[31],data2[31]})
    				2'b00 : begin 
      					if(data1 < data2)
   					begin
      						alu_out = 1;
                  				not_equal=1;
						equal	 =0;
              				end
      					else if(data1 == data2)
        				begin
                				equal=1;
                  				alu_out=0;
						not_equal = 0;
               				end
      					else 
					begin
                  				alu_out=0;
      			 		 	not_equal=1;
						equal = 0;
    					end
					end
  				2'b01:	begin
      					alu_out=0;
					not_equal = 1;
					equal = 0;
    					end
    				2'b10:  begin
      					alu_out=1;
					not_equal = 1;
					equal = 0;
    					end
   				2'b11:  begin
      					if(data1 > data2)
   					begin
      						alu_out = 0;
                  				not_equal=1;
						equal = 0;
                			end
      					else if(data1 == data2)
        				begin
                				equal=1;
                  				alu_out=0;
						not_equal = 0;
                			end
      					else 
					begin
                  				alu_out=1;
      			  			not_equal=1;
						equal = 0;
    					end
					end
    			        default:begin
    			  			alu_out=0;
      						equal = 0;
      						not_equal = 0;
    					end
			endcase
			end
	
	ALU_LTU  :	begin
			if(data1 < data2)
				begin
				alu_out = 1;
				not_equal = 1;
				equal =0;
				end
			else if(data1 == data2)
				begin
				alu_out = 0;
				equal	= 1;
				end
			else
				begin
				alu_out = 0;
				not_equal=1;
				end
			end

	ALU_SLL  :	begin
			alu_out = data2 << shamt;
			end

	ALU_SRL  :	begin
			alu_out = data2 >> shamt;
			end
	
	ALU_PASS2:	begin
			alu_out = data2;
			end
	
	ALU_SRA  :	begin
				temp_data = data2;
				msb_bit = data2[31];
				alu_out = temp_data;
				for(int i =0;i<shamt;i++)
					begin
					alu_out = {msb_bit,alu_out[31:1]};
					end
			end
	default  :	begin
			alu_out = 0;
			equal	= (data1 == data2);
			not_equal = ~(data1 == data2);
			end

  endcase
 end

endmodule
