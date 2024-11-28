`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "pipe_control.v"

module processor;
    reg clk;
reg [2:0] stat;
    reg [63:0] F_predPC;

    wire [63:0] f_predPC;
    wire [2:0] D_stat,E_stat,M_stat,W_stat,m_stat;
    wire [3:0] D_icode,E_icode,M_icode,W_icode;
    wire [3:0] D_ifun,E_ifun;
    wire [3:0] D_rA,D_rB;
    wire signed [63:0] D_valC,D_valP;
    wire [3:0] d_srcA,d_srcB;
    wire signed [63:0] E_valC,E_valA,E_valB,e_valE;
    wire signed [63:0] M_valE,M_valA,m_valM;
    wire signed [63:0] W_valE,W_valM;
    wire [3:0] E_dstE,E_dstM,E_srcA,E_srcB,e_dstE;
    wire [3:0] M_dstE,M_dstM;
    wire [3:0] W_dstE,W_dstM;
    // wire [63:0] e_valE;
    wire ZF,SF,OF;


 wire signed [63:0] M_valE_out;
 wire signed [63:0] M_valA_out;

    wire M_cnd;
    wire e_cnd;
    
     wire signed [63:0] rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14; 
     wire F_stall,D_stall,D_bubble,E_bubble,set_cc;


    fetch fetch(D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,f_predPC,M_icode,M_cnd,M_valA,W_icode,W_valM,F_predPC,clk,F_stall,D_stall,D_bubble);

    decode decode (clk,D_icode,D_ifun,D_rA,D_rB,D_stat,D_valC,D_valP,E_bubble,W_icode,e_dstE,M_dstE,M_dstM,W_dstE,W_dstM,e_valE,M_valE,m_valM,W_valE,W_valM,E_stat,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,E_srcA,E_srcB, rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14,d_srcA,d_srcB);

    execute execute(clk,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,E_srcA,E_srcB,E_stat,W_stat,m_stat,M_stat,M_icode,M_cnd,M_valE,M_valA,M_dstE,M_dstM,e_dstE,e_valE,e_cnd,ZF,SF,OF);

    memory memory (clk,M_stat,M_icode,M_cnd,M_valE,M_valA,M_dstE,M_dstM,W_stat,W_icode,W_valE,W_valM,W_dstE,W_dstM,m_valM,m_stat);

    pipe_control pipe_control (m_stat,W_stat,D_icode,E_icode,M_icode,d_srcA,d_srcB,E_dstM,e_cnd,F_stall,D_stall,D_bubble,E_bubble,set_cc);

    always@(W_stat)begin
        stat = W_stat;
    end  

    always@(stat) begin
        if(stat==3'b100)
        begin
            $display("Instruction error");
            #9
            $finish;
        end
        else if (stat == 3'b011)
        begin
            $display("Memory_error");
            #9
            $finish;
        end
        else if(stat== 3'b010)
        begin
            $display("halting");
            #9
            $finish;
        end
    end


    always #10 clk = ~clk;


    always @(posedge clk)
    begin
        F_predPC <= f_predPC;
    end

    
    initial begin 
        F_predPC=64'd0;
        clk=0;
      $dumpfile("processor.vcd");
        $dumpvars(0,processor);
      $monitor(" \n clk = %0d , M_valE =%0d , M_valA = %0d , m_valM = %0d \n........................................\n\n W_stat=%d\n,f_predPC=%d\n F_predPC=%d\n\n......................................\n D_icode=%d\n,E_icode=%d\n, M_icode=%d\n,W_icode=%d\n,........................................\n F_stall=%d\nD_stall=%d\nD_bubble=%d\nE_bubble=%d\n\n......................................\n  e_valE=%d\n  D_ifun=%d\n W_valE=%d\n E_valC=%d\n\n......................................... \n,rax =%d\n, rcx=%d\n, rdx=%d\n, rbx=%d\n, rsp=%d\n, rbp=%d\n, rsi=%d\n, rdi=%d\n,  r8=%d\n,  r9=%d\n, r10=%d\n, r11=%d\n, r12=%d\n, r13=%d\n, r14=%d\n\n\n",clk,M_valE,M_valA,m_valM, W_stat, f_predPC, F_predPC, D_icode,E_icode,M_icode,W_icode,F_stall,D_stall,D_bubble,E_bubble,e_valE,D_ifun,W_valE,E_valC,rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14);
//    $monitor("f_predPC=%d F_predPC=%d D_icode=%d,E_icode=%d, M_icode=%d,W_icode=%d ,m_valM=%d, f_stall=%d, ifun=%d,valE=%d, valC=%d \n",f_predPC,F_predPC, D_icode,E_icode,M_icode,W_icode,m_valM,F_stall,D_ifun,W_valE,E_valC);

    end 


endmodule

