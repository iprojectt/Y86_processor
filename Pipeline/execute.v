`include "ALU.v"


module execute(clk,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,E_srcA,E_srcB,E_stat,W_stat,m_stat,M_stat,M_icode,M_cnd,M_valE,M_valA,M_dstE,M_dstM,e_dstE,e_valE,e_cnd,ZF,SF,OF);

input clk;
input [3:0] E_icode,E_ifun;
input signed [63:0] E_valA,E_valB,E_valC;
input [3:0] E_dstE,E_dstM;
input [3:0] E_srcA,E_srcB;
input [2:0] E_stat;  

output reg ZF,SF,OF;
initial begin
    ZF =0;
    SF =0;
    OF =0;
end
 
input [2:0] W_stat; 
input [2:0] m_stat; 


output reg [2:0] M_stat;
output reg [3:0] M_icode;
output reg M_cnd;
output reg signed [63:0] M_valE,M_valA;
output reg [3:0] M_dstE,M_dstM;


output reg [3:0] e_dstE; 
output reg signed [63:0] e_valE; 
output reg e_cnd=1;

reg [2:0] CC ;

reg [1:0] control;
reg signed [63:0]a,b;
wire signed [63:0]add_out,sub_out,and_out,xor_out;


sixty_four_bit_ALU alu(control,a,b,add_out,sub_out,and_out,xor_out,add_Cout,sub_Cout);




always @(*)
begin


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
OF=(((a[63] == 1'b1) == (b[63] == 1'b1))&&((add_out[63] == 1'b1) != (a[63] == 1'b1)));
end
else if(control == 2'b01)
begin
OF=(((a[63] == 1'b1) == (b[63] == 1'b1))&&((sub_out[63] == 1'b1) != (a[63] == 1'b1)));
end



end



    if(E_icode == 4'b0010 || E_icode == 7) 
    begin
        if(E_ifun == 4'h0) e_cnd = 1;             // unconditional
        else if(E_ifun == 4'h1) e_cnd = (SF^OF)|ZF; // le
        else if(E_ifun == 4'h2) e_cnd = OF^SF;    // l
        else if(E_ifun == 4'h3) e_cnd = ZF;       // e
        else if(E_ifun == 4'h4) e_cnd = ~ZF;      // ne
        else if(E_ifun == 4'h5) e_cnd = ~(SF^OF); // ge
        else if(E_ifun == 4'h6) e_cnd = ~(SF^OF)&~ZF; // g
   
    e_dstE = e_cnd ? E_dstE : 4'hF;
    end
    else
    begin
        e_dstE=E_dstE;
    end
end

always @(*)
begin
      
      if(E_icode == 4'b0011) //irmovq
      begin
           a=1'b0;
           b=E_valC;
               e_valE= b;

      end
      else if(E_icode==4'b0100) //rmmovq
      begin
            a=E_valC;
            b=E_valB;
            control=2'b00;
                e_valE=add_out;

      end
      else if(E_icode == 4'b0101) //mrmovq
      begin
           $display("\nE_dstM=%0d\n",E_dstM);
           a=E_valC;
           b=E_valB;
           control=2'b00; 
               e_valE = a+b;
               $display("\na=%0d b=%0d e_valE=%0d\n",a,b,e_valE);
      end
    
    else if(E_icode == 6) //opq
    begin
        a=E_valA;
        b=E_valB;
        if(E_ifun == 2'b00)
            begin
                control=2'b00;
                    e_valE= add_out;
            end

            else if(E_ifun == 2'b01)
            begin
                control=2'b01;
                    e_valE= sub_out;
            end
            else if(E_ifun == 2'b10)
            begin
                control=2'b10;
                    e_valE= and_out;
            end
            else if(E_ifun == 2'b11)
            begin
                control=2'b11;
                    e_valE=xor_out;

            end
    
    end

    else if(E_icode==4'b1000) //call
    begin
        a=E_valB;
        b=64'd8;
        control=2'b01;
            e_valE=sub_out;

    end
    else if(E_icode== 9)//ret
    begin
        a=64'd8;
        b=E_valB;
        control=2'b00;
            e_valE= add_out;

    end
    else if(E_icode==4'b1010)//pushq
    begin
        a=E_valB;
        b=64'd8;
        control=2'b01;
            e_valE= sub_out;

    end
    else if(E_icode==4'hB)//popq
    begin
        a=64'd8;
        b=E_valB;
        control=2'b00;
            e_valE= add_out;

    end
    else if(E_icode == 4'b0010) // cmovxx
    begin
        a=E_valA;
        b=64'd0;
            e_valE= a;

    end

    else
    begin
        a=64'd0;
        b=64'd0;
            e_valE= b;

    end 


    // if(set_cc)
    // begin
    //     CC[0] = e_valE ? 0:1; // Check value of valE
    //     CC[1] = e_valE[63]; // The MSB bit
    //     CC[2]= overflow; // This comes from the output of ALU
    // end

end

always @(posedge clk)
begin
    begin
        M_stat <= E_stat;
        M_icode <= E_icode;
        M_cnd <= e_cnd;
        M_valE <= e_valE;
        M_valA <= E_valA;
        M_dstE <= e_dstE;
        M_dstM <= E_dstM;
    end
end




endmodule