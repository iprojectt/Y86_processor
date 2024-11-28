module fetch (clk,icode,ifun,rA,rB,valC,valP,imem_error,instr_valid,PC); 
    input clk;
    input [63:0] PC;
    reg [7:0] instr_mem [0 : 1023]; 
    output reg [3:0] icode, ifun;
    output reg [3:0] rA, rB;
    output reg [63:0] valC, valP;
    output reg imem_error = 0, instr_valid = 1;


initial 
begin 

   $readmemb("testing.txt",instr_mem);


end 

always @(posedge clk) 
begin
    if (PC > 1023) 
       assign imem_error = 1;
    else
       assign imem_error = 0;

    icode = instr_mem[PC][7:4];
    ifun  = instr_mem[PC][3:0];
   $display("icode=%d\n",icode);

    if (icode == 4'b0000 || icode == 4'b0001) 
    begin 
         valP = PC + 1;
    end

    else if (icode == 4'b0010 || icode == 4'b0011 || icode == 4'b0100 || icode == 4'b0101 || icode == 4'b0110 || icode == 4'hA || icode == 4'hB)
    begin  // irmovq
        rA = instr_mem[PC+1][7:4];
        rB = instr_mem[PC+1][3:0];
        if (icode == 4'b0011 || icode == 4'b0100 || icode == 4'b0101)  // irmovq mrmovq mrmovq
        begin
          valC = {instr_mem[PC+9],instr_mem[PC+8],instr_mem[PC+7],instr_mem[PC+6],instr_mem[PC+5],instr_mem[PC+4],instr_mem[PC+3],instr_mem[PC+2]};
          valP = PC + 10;
        end
        if (icode == 4'b0010 || icode == 4'b0110 || icode == 4'hA || icode == 4'hB)  // cmovq // Opq // pushq
        begin
          valP = PC + 2;
        end
    end

    else if (icode == 4'b0111 || icode == 4'b1000)
    begin // jxx
          valC = {instr_mem[PC+8],instr_mem[PC+7],instr_mem[PC+6],instr_mem[PC+5],instr_mem[PC+4],instr_mem[PC+3],instr_mem[PC+2],instr_mem[PC+1]};
        valP = PC + 9;
    end

    else if (icode == 4'b1001)
    begin // ret
        valP = PC + 1;
    end

    else 
        instr_valid = 1'b0;
end

endmodule


// module fetch_tb;

// reg clk;
// reg [63:0] PC;
// reg  [7:0] instr_mem [0:14];
// wire [3:0] icode;
// wire [3:0] ifun;
// wire [3:0] rA;
// wire [3:0] rB; 
// wire [63:0] valC;
// wire [63:0] valP;
// wire memory_error;
// wire instr_valid;

// fetch UUT(clk,icode,ifun,rA,rB,valC,valP,memory_error,instr_valid,PC);
    
// always @(icode) 
// begin
//     if(icode==0 && ifun==0) // halt
//       $finish;
// end

//  always #10 begin
//      clk = ~clk;
//   end

// initial begin
//   clk=1;
//  PC=64'd0;
// #20;
// PC = valP;
// #20;
// PC = valP;
// #20;
// PC = valP;
// #20;
// PC = valP; 
// #40
// $finish;

// end

// initial begin
//   $monitor("clk=%d PC=%d icode=%b ifun=%b rA=%b rB=%b,valP=%d,valC=%b\n",clk,PC,icode,ifun,rA,rB,valP,valC);

// end

// endmodule

