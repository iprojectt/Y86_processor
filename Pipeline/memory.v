module memory (clk,M_stat,M_icode,M_cnd,M_valE,M_valA,M_dstE,M_dstM,W_stat,W_icode,W_valE,W_valM,W_dstE,W_dstM,m_valM,m_stat);

input clk;
input [2:0] M_stat;
input [3:0] M_icode;
input M_cnd;
input signed [63:0] M_valE,M_valA;
input [3:0] M_dstE,M_dstM;

output reg [2:0] W_stat;
output reg [3:0] W_icode;
output reg signed [63:0] W_valE,W_valM;
output reg [3:0] W_dstE,W_dstM;
output reg signed [63:0] m_valM;
output reg [2:0] m_stat;

reg [63:0] memory [0:1023];
reg memory_error = 0;
reg check_valE,check_valA;

always @(*)
begin
    if(memory_error)
        m_stat = 3'b011;
    else
        m_stat = M_stat;
end

always @(*)
begin
    if(M_icode==4'b0100 | M_icode==4'b0101 | M_icode== 4'b1000 | M_icode==4'hB) // These are the values of icode where value of valE determines the location in memory  
    begin 
        check_valE=1; 
     end

    else
    begin
        check_valE=0;
    end

    if(M_icode == 4'b1001 | M_icode == 4'b1010)
    begin
        check_valA=1;
    end

    else
    begin
        check_valA=0;
    end

end

always @(*)
begin

    if((M_valE>1023 & check_valE) || (M_valA > 1023 & check_valA))
    begin 
        memory_error=1 ;
    end

    if(M_icode == 4'b0101) //mrmovq
    begin
        $display("\nM_dstM=%0d, %0d\n",M_dstM,M_valE);
        m_valM=memory[M_valE];
    end

    if(M_icode == 4'b1001 || M_icode == 4'hB)   //ret   //popq
    begin
        m_valM=memory[M_valA];
    end

end

always @(posedge clk)
begin
    // checking only valE as we are accessing memory with the value of valE in the these cases->
    if(M_valE < 0) 
    begin
          memory_error=1;
        $display("M_valE=%d\n check_valE =%d\n",M_valE,check_valE);
      end

    if(M_icode == 4'b0100 || M_icode == 4'b1000 || M_icode == 4'hA)  //rmmovq   //call    // pushq
    begin
        memory[M_valE] = M_valA;
$display("memory[%0d] = %0d\n",M_valE,M_valA);

    end


end

// here i am updating the writeback pipeline register
always @(posedge clk)
begin
    W_stat <= m_stat;
    W_icode <= M_icode;
    W_valE <= M_valE;
    W_valM <= m_valM;
    W_dstE <= M_dstE;
    W_dstM <= M_dstM;
end

endmodule
