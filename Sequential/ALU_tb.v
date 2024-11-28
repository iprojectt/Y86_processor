
module FullAdder(X,Y,Cin,Sum,Cout);

input X,Y,Cin;
output Sum,Cout;
wire a,b,c;

xor X1(a,X,Y);
and X2(b,X,Y);
xor X3(Sum,a,Cin);
and X4(c,a,Cin);
or  X5(Cout,b,c);

endmodule


module sixty_four_bit_adder(A,B,Sum,Cout);

input [63:0]A,B;
output [63:0]Sum;
output Cout;
wire [64:0]Cin;

assign Cin[0] = 0;
genvar i;
generate for(i=0;i<64;i=i+1)

begin

FullAdder alu(A[i],B[i],Cin[i],Sum[i],Cin[i+1]);
xor (Cout,Cin[64],Cin[63]);

end
endgenerate

endmodule


module sixty_four_bit_subtractor(A,B,Sum,Cout);

input [63:0]A,B;
output [63:0]Sum;
output Cout;
wire [64:0]Cin;
wire [63:0]new;

assign Cin[0] = 1;

genvar i;
generate for(i=0;i<64;i=i+1)

begin

xor (new[i],B[i],Cin[0]);
FullAdder alu(A[i],new[i],Cin[i],Sum[i],Cin[i+1]);
xor (Cout,Cin[64],Cin[63]);

end
endgenerate

endmodule


module sixty_four_bit_and(A,B,Out);

input [63:0]A,B;
output [63:0]Out;

genvar i;
generate for(i=0;i<64;i=i+1)
and x1(Out[i],A[i],B[i]);
endgenerate

endmodule


module sixty_four_bit_xor(A,B,Out);

input [63:0]A,B;
output [63:0]Out;

genvar i;
generate for(i=0;i<64;i=i+1)
xor x1(Out[i],A[i],B[i]);
endgenerate

endmodule


module sixty_four_bit_ALU(control,A,B,add_out,sub_out,and_out,xor_out,add_Cout,sub_Cout);

input [1:0]control;
input [63:0]A,B;
output [63:0]add_out,sub_out,and_out,xor_out;
output add_Cout,sub_Cout;
output add_overflow,sub_overflow;

wire [63:0]add_out_temp,sub_out_temp,and_out_temp,xor_out_temp;
wire add_Cout_temp,sub_Cout_temp;
wire control_0,control_1,control_2,control_3;
wire k1,k2;

sixty_four_bit_adder      ALU_0(A,B,add_out_temp,add_Cout_temp);
sixty_four_bit_subtractor ALU_1(A,B,sub_out_temp,sub_Cout_temp);
sixty_four_bit_and        ALU_2(A,B,and_out_temp);
sixty_four_bit_xor        ALU_3(A,B,xor_out_temp);

and x0(control_0,!control[1],!control[0]);
and x1(control_1,!control[1],control[0]);
and x2(control_2,control[1],!control[0]);
and x3(control_3,control[1],control[0]);

genvar i;
generate for(i=0;i<64;i=i+1)

begin

and x4(add_out[i],add_out_temp[i],control_0);
and x5(sub_out[i],sub_out_temp[i],control_1);
and x6(and_out[i],and_out_temp[i],control_2);
and x7(xor_out[i],xor_out_temp[i],control_3);
and x8(add_Cout,add_Cout_temp,control_0);
and x9(sub_Cout,sub_Cout_temp,control_1);

end
endgenerate

endmodule


module ALU_tb;

reg signed[63:0]A,B;
reg [1:0]control;
wire add_Cout,sub_Cout;
wire signed[63:0]add_out,sub_out,and_out,xor_out;

sixty_four_bit_ALU dut (
  .A(A),
  .B(B),
  .control(control),
  .add_out(add_out),
  .sub_out(sub_out),
  .and_out(and_out),
  .xor_out(xor_out),
  .add_Cout(add_Cout),
  .sub_Cout(sub_Cout)
  );

initial begin 

  $dumpfile("ALU_tb.vcd");
  $dumpvars(0,ALU_tb);
 
  control = 2'b00; 
  A = (2**63-1);
  B = 1;#1
  $display("Control = %b",control);
  $display("Decimal                    | Binary");
  $display("A   = %d | A   = %b",A,A);
  $display("B   = %d | B   = %b",B,B);
  $display("add = %d | add = %b  | add_overflow = %b\n",add_out,add_out,add_Cout);

  control = 2'b00; 
  A = 4;
  B = 5;#1
  $display("Control = %b",control);
  $display("Decimal                    | Binary");
  $display("A   = %d | A   = %b",A,A);
  $display("B   = %d | B   = %b",B,B);
  $display("add = %d | add = %b  | add_overflow = %b\n",add_out,add_out,add_Cout);

  control = 2'b00; 
  A = -(2**63);
  B = -1;#1
  $display("Control = %b",control);
  $display("Decimal                    | Binary");
  $display("A   = %d | A   = %b",A,A);
  $display("B   = %d | B   = %b",B,B);
  $display("add = %d | add = %b  | add_overflow = %b\n",add_out,add_out,add_Cout);

  control = 2'b01; 
  A = -(2**63);
  B = 1;#1
  $display("Control = %b",control);
  $display("Decimal                    | Binary");
  $display("A   = %d | A   = %b",A,A);
  $display("B   = %d | B   = %b",B,B);
  $display("sub = %d | sub = %b  | sub_overflow = %b\n",sub_out,sub_out,sub_Cout);

  control = 2'b01; 
  A = (2**63-1);
  B = -1;#1
  // A = 1;
  // B = -5;#1 // example for suboverflow to be zero
  $display("Control = %b",control);
  $display("Decimal                    | Binary");
  $display("A   = %d | A   = %b",A,A);
  $display("B   = %d | B   = %b",B,B);
  $display("sub = %d | sub = %b  | sub_overflow = %b\n",sub_out,sub_out,sub_Cout);

  control = 2'b10; 
  A = 64'b101101;
  B = 64'b110011;#1
  $display("Control = %b",control);
  $display("A   = %b",A);
  $display("B   = %b",B);
  $display("and = %b\n",and_out);

  control = 2'b11; 
  A = 64'b101101;
  B = 64'b110011;#1
  $display("Control = %b",control);
  $display("A   = %b",A);
  $display("B   = %b",B);
  $display("xor = %b\n",xor_out);

  $finish;
  end
  
endmodule




