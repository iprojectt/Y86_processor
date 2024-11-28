module decode(clk, icode, rA, rB, valA, valB, valM, valE, cnd, rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14);

input clk;
input [3:0] rA;
input [3:0] rB;
input [3:0] icode;
input [63:0] valM;
input [63:0] valE;
input cnd;
output reg [63:0] valA;
output reg [63:0] valB;


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
reg [63:0] reg_memory [0:14];

initial 
begin 
    reg_memory[0] = 0;
    reg_memory[1] = 0;
    reg_memory[2] = 0;
    reg_memory[3] = 0;
    reg_memory[4] = 1023;
    reg_memory[5] = 0;
    reg_memory[6] = 0;
    reg_memory[7] = 0;
    reg_memory[8] = 0;
    reg_memory[9] = 0;
    reg_memory[10] = 0;
    reg_memory[11] = 0;
    reg_memory[12] = 0;
    reg_memory[13] = 0;
    reg_memory[14] = 0;  

end 


always @(*) 
begin
//    valA = 64'bx;
//    valB = 64'bx;
    // For nop and halt conditions there are no registers involved
    if(icode == 4'b0010 || icode == 4'b0100 || icode == 4'b0101 ||icode == 4'b0110) //cmovxx
    begin
        valA = reg_memory[rA];
        if(icode == 4'b0100 || icode == 4'b0101 ||icode == 4'b0110) //rmmovq //mrmovq //opq
        begin
            valB = reg_memory[rB];
        end
    end

    if(icode == 4'b1000 || icode == 4'b1001 || icode == 4'b1010 || icode == 4'b1011) //call
    begin
        if(icode == 4'b1001 || icode == 4'b1011) //ret
        begin
            valA = reg_memory[4];
        end

        if(icode == 4'b1010) //pushq
        begin
            valA = reg_memory[rA];
        end
        valB = reg_memory[4]; // As we have to push address o fnext instruction onto stack
    end




rax =reg_memory[0];
rcx =reg_memory[1];
rdx =reg_memory[2];
rbx =reg_memory[3];
rsp =reg_memory[4];
rbp =reg_memory[5];
rsi =reg_memory[6];
rdi =reg_memory[7];
r8 =reg_memory[8];
r9 =reg_memory[9];
r10 =reg_memory[10];
r11 =reg_memory[11];
r12 =reg_memory[12];
r13 =reg_memory[13];
r14 =reg_memory[14];



end



//write_back
always@(negedge clk)

begin


if(icode==4'b0010) //cmovxx
begin
if(cnd==1'b1)
begin
reg_memory[rB]=valE;
end
end



else if(icode==4'b0011 || icode==4'b0110) //irmovq  OPq
begin
reg_memory[rB]=valE;
end


else if(icode==4'b0101) //mrmovq
begin
reg_memory[rA]=valM;
end



else if(icode==4'b1000 || icode==4'b1001 || icode==4'b1010  ) //call  ret    pushq
begin
reg_memory[4]=valE;
end



else if(icode==4'b1011) //popq
begin
reg_memory[4]=valE;
reg_memory[rA]=valM;
end




rax =reg_memory[0];
rcx =reg_memory[1];
rdx =reg_memory[2];
rbx =reg_memory[3];
rsp =reg_memory[4];
rbp =reg_memory[5];
rsi =reg_memory[6];
rdi =reg_memory[7];
r8  =reg_memory[8];
r9  =reg_memory[9];
r10 =reg_memory[10];
r11 =reg_memory[11];
r12 =reg_memory[12];
r13 =reg_memory[13];
r14 =reg_memory[14];


end

endmodule








// module decode_tb;
//     reg clk;
//     reg [63:0] PC;
//     reg [63:0] valE, valM;
//     // reg  [7:0] instr_mem;
//     wire instr_valid;
//     wire memory_error;
//     wire [63:0]valC,valP;
//     wire [63:0] valA,valB;
//     wire [3:0]icode,ifun,rA,rB;
//     reg [7:0] instr_mem [0 : 14]; 
//     wire [63:0] rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14;
    
//     // fetch UUT_f(clk,icode,ifun,rA,rB,valC,valP,memory_error,instr_valid,instr,PC);
//     fetch UUT_f(clk,icode,ifun,rA,rB,valC,valP,memory_error,instr_valid,PC);
 
   
//     decode UUT_d(clk, icode, rA, rB, valA, valB, valM, valE, cnd, rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14);            

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

//    $monitor("clk=%d icode=%b ifun=%b rA=%b rB=%b,valA=%d,valB=%d PC=%d\n",clk,icode,ifun,rA,rB,valA,valB,PC); 
// end

// endmodule

