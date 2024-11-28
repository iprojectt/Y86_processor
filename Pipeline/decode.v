module decode (clk,D_icode,D_ifun,D_rA,D_rB,D_stat,D_valC,D_valP,E_bubble,W_icode,e_dstE,M_dstE,M_dstM,W_dstE,W_dstM,e_valE,M_valE,m_valM,W_valE,W_valM,E_stat,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,E_srcA,E_srcB, rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14,d_srcA,d_srcB);

input clk;
input [3:0] D_icode,D_ifun,D_rA,D_rB;
input signed [63:0] D_valC,D_valP; 
input E_bubble;
input [2:0] D_stat; // status coming from the decode pipeline register 

input [3:0] W_icode;
input [3:0] e_dstE,M_dstE,M_dstM,W_dstE,W_dstM;
input signed [63:0] e_valE,M_valE,m_valM,W_valE,W_valM;

output reg [2:0] E_stat; 
output reg [3:0] E_icode,E_ifun;
output reg signed [63:0] E_valC,E_valA,E_valB;
output reg [3:0] E_dstE,E_dstM,E_srcA,E_srcB;

output reg [63:0] rax;
output reg [63:0] rcx;
output reg [63:0] rdx;
output reg [63:0] rbx;
output reg [63:0] rsp;
output reg [63:0] rbp;
output reg [63:0] rsi;
output reg [63:0] rdi;
output reg [63:0] r8;
output reg [63:0] r9;
output reg [63:0] r10;
output reg [63:0] r11;
output reg [63:0] r12;
output reg [63:0] r13;
output reg [63:0] r14;

reg [63:0] register_memory[0:14];
output reg [3:0] d_srcA,d_srcB;
reg [3:0] d_dstE,d_dstM;
reg [63:0] d_valA,d_valB;

initial begin
    register_memory[0]=0;
    register_memory[1]=0;
    register_memory[2]=0;
    register_memory[3]=0;
    register_memory[4]=1023;
    register_memory[5]=0;
    register_memory[6]=0;
    register_memory[7]=0;
    register_memory[8]=0;  
    register_memory[9]=0;
    register_memory[10]=0;
    register_memory[11]=0;
    register_memory[12]=0;
    register_memory[13]=0;
    register_memory[14]=0;
end

// here we find dstW,dstM,srcA,srcB follow the chart of different operations
always @(*)
begin

    case(D_icode)
        4'h2: begin //cmovxx
          d_srcA = D_rA;
          d_srcB = 4'hF;
          d_dstE = D_rB;
          d_dstM = 4'hF;

        end

        4'h3: begin
        	d_dstE = D_rB;
           d_srcA = 4'hF;
          d_srcB = 4'hF;
          d_dstM = 4'hF;
        end

        4'h4: begin
          d_srcA = D_rA;
          d_srcB = D_rB;
           d_dstE = 4'hF;
          d_dstM = 4'hF;
        end

        4'h5: begin
          d_dstE = 4'hF;
          d_srcA = 4'hF;
          d_srcB = D_rB;
          d_dstM = D_rA;
          $display("\nd_dstM =%0d",d_dstM);
        end

        4'h6: begin
          d_srcA = D_rA;
          d_srcB = D_rB;
          d_dstE = D_rB;
          d_dstM = 4'hF;
        end

        4'h8:begin
           d_srcA = 4'hF;
          d_srcB = 4;
          d_dstE = 4;
          d_dstM = 4'hF;
        end

        4'h9:begin
          d_srcA = 4;
          d_srcB = 4;
          d_dstE = 4;
          d_dstM = 4'hF;
        end

        4'hA: begin
          d_srcA = D_rA;
          d_srcB = 4;
          d_dstE = 4;
          d_dstM = 4'hF;
        end

        4'hB: begin
          d_srcA = 4;
          d_srcB = 4;
          d_dstE = 4;
          d_dstM = D_rA;
        end

        default: begin
          d_srcA = 4'hF;
          d_srcB = 4'hF;
          d_dstE = 4'hF;
          d_dstM = 4'hF;
        end
    endcase

    if(D_icode == 4'b0010 || D_icode == 4'b0100 || D_icode == 4'b0110 || D_icode == 4'b1010)   //cmovxx //rmmovq  //opq  //pushq
    begin
        d_valA = register_memory[d_srcA];
        if(D_icode == 4'b0100 || D_icode == 4'b0110)   //rmmovq  //opq
        begin
        d_valB = register_memory[D_rB];
        end

        if(D_icode == 4'b1010) //pushq
        begin
        d_valB = register_memory[4];
        end
    end

    if(D_icode == 4'b0101) //mrmovq
    begin
      d_valA = register_memory[d_srcA];
        d_valB = register_memory[D_rB];
       $display("\nd_valB=%0d,D_rb=%0d\n",d_valB,D_rB);
    end

    if(D_icode == 4'b1000 || D_icode == 4'b1001 || D_icode == 4'b1011) //call  //ret  //popq
    begin
        d_valB = register_memory[4];  // As we have to push address to fnext instruction onto stack
        if(D_icode == 4'b1001 || D_icode == 4'b1011)  //ret  //popq
        begin
          d_valA = register_memory[4];
        end
    end

    // Forwarding A
    if(D_icode == 4'h7 | D_icode == 4'h8) //jxx or call
      d_valA = D_valP;

    else if(d_srcA == e_dstE & e_dstE != 4'hF)
      d_valA = e_valE;

    else if(d_srcA == M_dstM & M_dstM != 4'hF)
      d_valA = m_valM;

   
    else if(d_srcA == M_dstE & M_dstE != 4'hF)
      d_valA = M_valE;

 else if(d_srcA == W_dstM & W_dstM != 4'hF)
      d_valA = W_valM;

    else if(d_srcA == W_dstE & W_dstE != 4'hF)
      d_valA = W_valE;


    // Forwarding B
    if(d_srcB == e_dstE & e_dstE != 4'hF)      
      d_valB = e_valE;

    else if(d_srcB == M_dstM & M_dstM != 4'hF)
      d_valB = m_valM;

    

    else if(d_srcB == M_dstE & M_dstE != 4'hF) 
      d_valB = M_valE;
      else if(d_srcB == W_dstM & W_dstM != 4'hF) 
      d_valB = W_valM;

    else if(d_srcB == W_dstE & W_dstE != 4'hF) 
      begin
        d_valB = W_valE;
        $display("\nd_valB=%0d\n",d_valB);
      end
              $display("\nd_srcB=%0d, W_dstE = %0d\n",d_srcB,W_dstE);


end

//here we are updating the values in Execute pipeline register
always @(posedge clk)
begin
	 if(E_bubble)
    begin
      E_stat <= 3'b001;
      E_icode <= 4'b0001;
      E_ifun <= 4'b0000;
      E_valC <= 4'b0000;
      E_valA <= 4'b0000;
      E_valB <= 4'b0000;
      E_dstE <= 4'hF;
      E_dstM <= 4'b1111;
      E_srcA <= 4'hF;
      E_srcB <= 4'b1111;
    end

    else
    begin
      E_stat <= D_stat;
      E_icode <= D_icode;
      E_ifun <= D_ifun;
      E_valC <= D_valC;
      E_valA <= d_valA;
      E_valB <= d_valB;
      E_srcA <= d_srcA;
      E_srcB <= d_srcB;
      E_dstE <= d_dstE;
      E_dstM <= d_dstM;
    end
    $display("\nE_valB=%0d\n",E_valB);

end


// Write back
always @(*)
begin

	  if(W_icode == 4'b0010 || W_icode == 4'b0011 || W_icode == 4'b0110 || W_icode == 4'b1000 || W_icode == 4'b1001 || W_icode== 4'hA)   //cmovXX  //irmovq  //opq //Dest //ret //push
    begin
      register_memory[W_dstE] = W_valE; // updating %rsp
    end

    if(W_icode == 4'b0101) // mrrmovq D(rB),rA
    begin 
      $display("\nW_dstM=%0d  %0d\n",W_dstM,W_valM);
      register_memory[W_dstM]= W_valM; 
    end

    if(W_icode==4'b1011) // pop
    begin
        register_memory[W_dstE] =W_valE;
        register_memory[W_dstM]=W_valM;
    end

		rax = register_memory[0];
    rcx = register_memory[1];
    rdx = register_memory[2];
    rbx = register_memory[3];
    rsp = register_memory[4];
    rbp = register_memory[5];
    rsi = register_memory[6];
    rdi = register_memory[7];
    r8  = register_memory[8];
    r9  = register_memory[9];
    r10 = register_memory[10];
    r11 = register_memory[11];
    r12 = register_memory[12];
    r13 = register_memory[13];
    r14 = register_memory[14];

end

endmodule


