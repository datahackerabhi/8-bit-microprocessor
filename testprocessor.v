`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:01:59 11/02/2017 
// Design Name: 
// Module Name:    processor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


///////////////////////       ALU           /////////////////////////////

module ALU(clk,r0a,r1a,r2a,f_select);

input clk;
input  [7:0] r0a;
input  [7:0] r1a;
output [7:0] r2a;
reg    [7:0] r2a;

reg ce;
initial begin ce = 0; end
wire [7:0] loadop;

input  [3:0]f_select;
reg rdwr ;


Memory m(.ce(ce),.addr(r0a),.rdwr(rdwr),.data_in(r1a),.data_out(loadop));

always @(posedge clk) begin
 case(f_select)
  3'b000:  r2a <= r0a+r1a;
  3'b001:  r2a <= r0a-r1a;
  3'b010:  r2a <= r0a&r1a;
  3'b011:  r2a <= r0a|r1a;
  3'b100:  r2a <= r0a<<1;
  3'b101:  r2a <= r0a>>1;
  3'b110:  begin
           rdwr <= 0;//store into address given in  r0a with data from r1a
	   ce <= ~ce;		 
	   end		  
			 
  3'b111: begin
          rdwr <= 1;//load data from addr in r0a into r2a
	  ce <= ~ce;
	  r2a <= loadop;
          end
//  default:  r2a <= 5;
 endcase
end
endmodule


///////////////////////////    RAM   //////////////////////////////////////


module Memory(input ce,input [7:0]addr,input rdwr,input [7:0]data_in,output [7:0]data_out);
reg [7:0] memory[255:0];
reg [7:0] temp;
assign data_out = temp;

always@(posedge ce or negedge ce) begin
 if(rdwr == 1) //1 == load
   begin
   temp <= memory[addr];
	end
 else
   begin
   memory[addr] <= data_in;
	end
end

endmodule


///////////////////////////     Execution Unit     //////////////////////////

module EU(o1,o2,clk,wr,ld,en,f_select,addressbus,datain,temp);

output [7:0] temp;

reg [7:0] dataout;
input en;
input wr;
input ld;
input clk;
input [3:0]f_select;
input [7:0]datain;
wire [7:0]op;

output [7:0]o1;
output [7:0]o2;

assign o1 = databus;
assign o2 = r[0];

reg [7:0] r[0:7];

initial 
begin
r[5] = 4;
r[6] = 5;
end

assign temp = r[1];

wire [7:0]databus;
input [2:0]addressbus; 

assign databus = ld?datain:dataout;

always@(posedge clk) begin
 
 if(wr == 1) begin
 r[addressbus] <= databus;
  end
 else
   begin
    dataout <= r[addressbus];
end
  

end

ALU alu(.clk(en&clk),.r0a(r[0]),.r1a(r[1]),.r2a(op),.f_select(f_select));
always @(*)
begin
r[2] = op;
$display("ro = %b, r1 = %b, r2 = %b r5 = %b r6 = %b ",r[0],r[1],r[2],r[5],r[6]);
end

endmodule 



///////////////////  Execution Unit control Logic   ///////////////////////

module EUCL(clk,ip1,ip2,op,opcode,pc_incr,debug,debug1,debug2);
input clk;
output [7:0] debug,debug1,debug2;
input [3:0] ip1,ip2,op,opcode;

output [7:0] pc_incr;
reg [7:0] pc_out;

reg wr,ld,en;
reg [3:0] f_select;
reg [2:0] addressbus;
reg [7:0] datain;

reg [3:0] state;

initial
begin
pc_out<=0;
state<=0;
end

assign pc_incr = pc_out;

EU eu(.clk(clk),.wr(wr),.ld(ld),.en(en),.f_select(f_select),.addressbus(addressbus),.datain(datain),.temp(debug),.o1(debug1),.o2(debug2));



always @(posedge clk) begin
ld <= 0;
wr <= 0;
en <= 0;
pc_out <= 0;

  if (opcode == 0 || opcode == 1 || opcode == 2 || opcode == 3)
  begin 
  /////  ADD , SUB , AND , OR //////   
 
  state <=4'b0000;
  case(state)
 
  4'b0000: begin
  addressbus <= ip1;
  state <= 4'b0001;
  end
 
  4'b0001: begin 
  addressbus <= 4'b0000;
  wr <= 1;
  state <= 4'b0010;
  end
  
  4'b0010: begin 
  addressbus <= ip2;
  state <= 4'b0011;
  end

  4'b0011: begin 
  addressbus <= 4'b0001;
  wr <= 1;
  state <= 4'b0100;
  end

  4'b0100: begin 
  addressbus <= 4'b0010;
  f_select <= opcode;
  en <= 1;
  state <= 4'b0101;
  end
 
  4'b0101: begin 
  addressbus <= 4'b0010;
  state <= 4'b0110;
  end
 
  4'b0110: begin 
  addressbus <= op;
  wr <= 1;
  state <= 4'b0111;
  pc_out <= 8'b00000001;  
  end 

  4'b0111: begin
  state <= 4'b0000;
  end

  endcase
  end
  
  if (opcode == 4 || opcode == 5 )
  begin 
  /////  SHIFT LEFT, SHIFT RIGHT , STORE //////   
 
  state <=4'b0000;
  case(state)
 
  4'b0000: begin
  addressbus <= ip1;
  state <= 4'b0001;
  end
 
  4'b0001: begin 
  addressbus <= 4'b0000;
  wr <= 1;
  state <= 4'b0010;
  end

  4'b0010: begin 
  addressbus <= 4'b0010;
  f_select <= opcode;
  en <= 1;
  state <= 4'b0011;
  end
 
  4'b0011: begin 
  addressbus <= 4'b0010;
  state <= 4'b0100;
  end
 
  4'b0100: begin 
  addressbus <= op;
  wr <= 1;
  state <= 4'b0101;
  pc_out <= 8'b00000001;  
  end 

  4'b0101: begin
  state <= 4'b0000;
  end

  endcase
  end
  
if (opcode == 6)
  begin 
  /////  STORE //////   
 
  state <=4'b0000;
  case(state)
 
  4'b0000: begin
  addressbus <= ip1;
  state <= 4'b0001;
  end
 
  4'b0001: begin 
  addressbus <= 4'b0000;
  wr <= 1;
  state <= 4'b0010;
  end
  
  4'b0010: begin 
  addressbus <= ip2;
  state <= 4'b0011;
  end

  4'b0011: begin 
  addressbus <= 4'b0001;
  wr <= 1;
  state <= 4'b0100;
  end

  4'b0100: begin 
  f_select <= opcode;
  en <= 1;
  wr <= 0;
  pc_out <= 8'b00000001;  
  state <= 4'b0101;

  end
 
  4'b0101: begin 
  state <= 4'b0000;
  end
 
 

  endcase
  end
  
  
  if (opcode == 7)
  begin 
  ///// LOAD  //////   
 
  state <=4'b0000;
  case(state)
 
  4'b0000: begin
  addressbus <= ip1;
  state <= 4'b0001;
  end
 
  4'b0001: begin 
  addressbus <= 4'b0000;
  wr <= 1;
  state <= 4'b0010;
  end
  
  4'b0010: begin 
  addressbus <= 4'b0010;
  f_select <= opcode;
  en <= 1;
  state <= 4'b0011;
  end
 
  4'b0011: begin 
  addressbus <= 4'b0010;
  f_select <= opcode;
  en <= 1;
  en <= 1;
  state <= 4'b0100;       // Load takes 2 cycles
  end

  4'b0100: begin 
  addressbus <= 4'b0010;
  state <= 4'b0101;
  end
 
  4'b0101: begin 
  addressbus <= op;
  wr <= 1;
  state <= 4'b0110;
  pc_out <= 8'b00000001;  
  end 

  4'b0110: begin
  state <= 4'b0000;
  end

  endcase
  end
  
  if(opcode == 8) 
  
  begin
  ////LOAD IMMEDIATE////// - gets data into R0
  state <=4'b0000;
  case(state)
  
  4'b0000: begin
  ld <= 1;
  datain <= (ip1<<4) + (ip2);
  state <= 4'b0001;
  end
   
  4'b0001: begin
  addressbus <= 4'b0000;
  ld <= 1;
  wr <= 1;
  pc_out <= 8'b00000001;
  state <= 4'b0010;
  end
  
  4'b0010: begin
  state <= 4'b0000;
  end
  
  endcase
  end
  
end
endmodule

//////////////////////   Program Memory   //////////////////////////////////

module program_memory(p_c,instr);
input [7:0] p_c;
reg [255:0] p_m [15:0];
output [15:0] instr;
initial begin
p_m [0] = 16'h8562; //<opcode><ip1><ip2><op>
/*
p_m [1] = 16'h7562;
p_m [2] = 16'h6604;
p_m [3] = 16'h7502;
*/
end
assign instr = p_m [p_c];
endmodule


//////////////////// Instruction Decoder  ////////////////////////////

module instruction_decoder(instr,opcode,ip1,ip2,op);
input [15:0] instr;
output [3:0] opcode,ip1,ip2,op;
assign opcode = instr [15:12];
assign ip1 = instr [11:8];
assign ip2 = instr [7:4];
assign op = instr [3:0];
endmodule

//////////////////////////////  Control Unit /////////////////////////

module CU(clk,debug,debug1,debug2);
input clk;
reg [7:0] p_c;

initial
begin 
p_c = 0;
end

output [7:0] debug,debug1,debug2;
wire [7:0] pc_incr;
wire [15:0] instr;
wire [3:0] opcode,ip1,ip2,op;

program_memory pm(.p_c(p_c),.instr(instr));
instruction_decoder id(instr,opcode,ip1,ip2,op);
EUCL eucl(clk,ip1,ip2,op,opcode,pc_incr,debug,debug1,debug2);
always @(posedge clk) 
begin
p_c <= p_c + pc_incr;
end
endmodule
