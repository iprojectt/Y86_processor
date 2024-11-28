`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
// `include "wb.v"
`include "pc_update.v"

module processor();

reg clk;
reg [63:0] PC;
reg [0:79] instr;
wire [63:0] new_PC;
wire [3:0] icode, ifun, rA, rB;
// wire [63:0] valC, valP;
wire signed [63:0] valA, valB, valC, valP, valE, valM;
// wire [63:0] valM;

wire ZF, SF, OF;
wire [2:0] CC_in;
wire [2:0] CC_out;
assign ZF=CC_in[0];
assign SF=CC_in[1];
assign OF=CC_in[2];

wire halt;

    wire instr_valid;
    wire memory_error;
    reg [7:0] instr_mem [0 : 14]; 
    wire signed [63:0] rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14;
    wire signed [63:0] stored_in_mem,index;

     
   wire cnd;
//    reg  [2:0] CC_in; // 3 conditional code

    
    // fetch UUT_f(clk,icode,ifun,rA,rB,valC,valP,memory_error,instr_valid,instr,PC);
    fetch UUT_f(clk,icode,ifun,rA,rB,valC,valP,memory_error,instr_valid,PC);
 
     
    decode UUT_d(clk, icode, rA, rB, valA, valB, valM, valE, cnd, rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14);            

    // execute  ext(clk,icode,ifun,valC,valA,valB,cnd,valE);
    execute ext(clk,icode,ifun,valC,valA,valB,cnd,valE,ZF,SF,OF);


    memory memo(clk, icode, valA, valB, valP, valE, valM, stored_in_mem,index);


   pc_update P1(cnd,clk,icode,new_PC,valM,valC,valP);

// wire [63:0] reg_memory [0:14];

// reg status[0:3];

   


initial begin
    PC = 64'd0;
    clk =0;
end

always @(*) 
begin
    if(icode== 4'b0000 && ifun== 4'b0000 || !instr_valid ) // halt
      $finish;
end

always #20 clk = ~clk;

always@(*)
begin 
    PC = new_PC;
end

initial 
begin
    $monitor("  clk=%0d  PC=%0d icode=%0h  ifun=%0d  rA=%0d  rB=%0d  valC=%0d  valP=%0d valA=%0d valB=%0d valM=%0d valE=%0d memory_error=%0d, halt=%0d\n\n,  rax =%d\n, rcx=%d\n, rdx=%d\n, rbx=%d\n, rsp=%d\n, rbp=%d\n, rsi=%d\n, rdi=%d\n, r8=%d\n, r9=%d\n, r10=%d\n, r11=%d\n, r12=%d\n, r13=%d\n, r14=%d\n\n  ZF=%d\n,SF=%d\n,OF=%d\n\n stored_in_mem =%d\n\n ", clk, PC, icode, ifun, rA, rB, valC, valP, valA, valB, valM, valE, memory_error, halt, rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14,ZF,SF,OF,stored_in_mem);
end



endmodule










// initial begin
//     $dumpfile("processor.vcd");
//     $dumpvars(0, processor);

