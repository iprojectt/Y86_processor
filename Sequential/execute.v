`include "ALU.v"

module execute(clk,icode,ifun,valC,valA,valB,cnd,valE,ZF,SF,OF);

input clk;
input [3:0] icode,ifun;
input [63:0] valC,valA,valB;
input [2:0] CC_in; // 3 conditional code
output reg cnd;
output reg signed [63:0] valE;
// output reg [2:0]; // Changed values of CC

output reg ZF,SF,OF;         // flag bits
initial begin
    ZF =0;
    SF =0;
    OF =0;
end

reg [1:0] control;
reg signed [63:0]A,B;
wire signed [63:0]add_out,sub_out,and_out,xor_out;
// wire add_Cout,sub_Cout;
// wire add_overflow,sub_overflow;



sixty_four_bit_ALU alu(control,A,B,add_out,sub_out,and_out,xor_out,add_Cout,sub_Cout);



always@(*)

begin
if(icode==4'b0110 && clk==1)

begin
    if(control == 2'b00)
    begin
  ZF =(add_out == 1'b0);
    end
    else if(control == 2'b01)
    begin
  ZF=(sub_out == 1'b0);
    end
    else if(control == 2'b10)
    begin
  ZF=(and_out == 1'b0);
    end
    else if(control == 2'b11)
    begin
  ZF=(xor_out == 1'b0);
    end

if(control == 2'b00)
begin
SF=(add_out[63]==1'b1);
end 
else if(control == 2'b01)
begin
SF=(sub_out[63]==1'b1);
end 
else if(control == 2'b10)
begin
SF=(and_out[63]==1'b1);
end 
else if(control == 2'b11)
begin
SF=(xor_out[63]==1'b1);
end 

if(control == 2'b00)
begin
OF=(((A[63] == 1'b1) == (B[63] == 1'b1))&&((add_out[63] == 1'b1) != (A[63] == 1'b1)));
end
else if(control == 2'b01)
begin
OF=(((A[63] == 1'b1) == (B[63] == 1'b1))&&((sub_out[63] == 1'b1) != (A[63] == 1'b1)));
end



end


    if(icode == 4'b0010 || icode == 7) 
    begin
        if(ifun == 4'h0) cnd = 1;             // unconditional
        else if(ifun == 4'h1) cnd = (SF^OF)|ZF; // le
        else if(ifun == 4'h2) cnd = OF^SF;    // l
        else if(ifun == 4'h3) cnd = ZF;       // e
        else if(ifun == 4'h4) cnd = ~ZF;      // ne
        else if(ifun == 4'h5) cnd = ~(SF^OF); // ge
        else if(ifun == 4'h6) cnd = ~(SF^OF)&~ZF; // g
    end


end







always @(*)
begin
      
      if(icode == 4'b0011) //irmovq
      begin
           
           B=valC;
           valE= B;
      end
      if(icode==4'b0100) //rmmovq
      begin
            A =valC;
            B=valB;
            control=2'b00;
            valE=add_out;
      end
      if(icode == 4'b0101) //mrmovq
      begin
           A=valC;
           B=valB;
           control=2'b00;
           valE=add_out; 

      end
    
    if (icode == 6)   // opq
    begin
        A = valA;
        B = valB;
        if (ifun == 2'b00) 
        begin
            control = 2'b00;
            valE=add_out;
        end
        else if (ifun == 2'b01)
        begin
            control = 2'b01;
            valE= sub_out;
        end 
        else if (ifun == 2'b10) 
        begin
            control = 2'b10;
            valE=and_out;
        end
        else if (ifun == 2'b11)
        begin
            control = 2'b11;
        valE= xor_out;
        end
    end

    else if(icode==4'b1000) //call
    begin
        A=valB;
        B=64'd8;
        control=2'b01;
        valE=sub_out;
    end
    else if(icode==4'b1001)//ret
    begin
        A=64'd8;
        B=valB;
        control=2'b00;
        valE= add_out;
    end
    else if(icode==4'hA)//pushq
    begin
        A=valB;
        B=64'd8;
        control=2'b01;
        valE= sub_out;
    end
    else if(icode==4'hB)//popq
    begin
        A=64'd8;
        B=valB;
        control=2'b00;
        valE= add_out;
    end
   
   
    else if(icode == 4'b0010) // cmovxx
    begin
        valE= valA;
    end


end


endmodule




// module execute_tb;
//     reg clk;
//     reg [63:0] PC;
//     wire cnd;
//     wire [63:0] valE;
    

//     // reg  [7:0] instr_mem;
//     wire instr_valid;
//     wire memory_error;
//     wire [63:0]valC,valP;
//     wire [63:0] valA,valB;
//     wire [3:0]icode,ifun,rA,rB;
//     reg [7:0] instr_mem [0 : 14]; 
//     reg  [2:0] CC_in; // 3 conditional code

    
//     // fetch UUT_f(clk,icode,ifun,rA,rB,valC,valP,memory_error,instr_valid,instr,PC);
//     fetch UUT_f(clk,icode,ifun,rA,rB,valC,valP,memory_error,instr_valid,PC);
 
     
//     decode UUT_d(clk, icode, rA, rB, valA, valB);            

//     // execute  ext(clk,icode,ifun,valC,valA,valB,cnd,valE);
//     execute  ext(clk,icode,ifun,valC,valA,valB,cnd,valE,ZF,SF,OF);


// // integer i;
// // always @(PC)
// // begin
// //     for (i = 0; i < 10; i = i + 1) begin
// //         instr = {instr,instr_mem[PC + i]};
// //     end
// // end

// always @(PC)
// begin
//     if(icode ==0 & ifun==0)
//         $finish;
// end

// always #10 begin
//      clk = ~clk;
//   end

// initial begin

// clk=1;
// PC=64'd0;
// #20;
// PC = valP;
// #20;
// PC = valP;
// #20;
// PC = valP;
// #20;
// PC = valP; 
// #20
// $finish;

// end
// initial begin

//    $monitor("clk=%d icode=%b ifun=%b rA=%b rB=%b,valA=%d,valB=%d PC=%d cnd=%d valE=%d\n",clk,icode,ifun,rA,rB,valA,valB,PC,cnd,valE); 
// end

// endmodule