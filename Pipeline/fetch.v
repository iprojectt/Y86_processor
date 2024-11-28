module fetch(D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,f_predPC,M_icode,M_cnd,M_valA,W_icode,W_valM,F_predPC,clk,F_stall,D_stall,D_bubble);

input clk;
input M_cnd;
input [3:0] M_icode,W_icode;
input signed [63:0] M_valA,W_valM;
input [63:0] F_predPC; // This is the predicted value of PC which is coming from previous instruction
input F_stall;  // in stall case we keep our PC value fixed
input D_stall; // Conditions for load/use hazard
input D_bubble; // Conditions for Mispredicted branch

// D pipeline register
output reg [3:0] D_icode,D_ifun;
output reg [3:0] D_rA,D_rB;
output reg signed [63:0] D_valC,D_valP;
output reg [2:0] D_stat; // AOK,HLT,ADR,INS
output reg [63:0] f_predPC;  // we predict next PC value 

reg [3:0] icode,ifun;
reg [3:0] rA,rB;
reg signed [63:0] valC,valP;
reg memory_error=0, instr_valid=1; 
reg [2:0] stat;
reg [0:79] instr;
reg [7:0] instr_mem[0:1000];
reg [63:0] PC;
initial 
    PC = F_predPC;

always @(*) begin
    if(W_icode==4'h9) // ret 
        PC = W_valM;

    else if(M_icode==4'h7) // jxx
    begin
        if(!M_cnd) 
            PC= M_valA; 
    end

    else
        PC = F_predPC;
end

initial
begin
    stat = 1;
   $readmemb("load_hazard.txt",instr_mem);

end 

always @(*)
begin

    instr_valid=1;
    if(PC>200)
    begin
        memory_error=1;
    end

    icode = instr_mem[PC][7:4];
    ifun  = instr_mem[PC][3:0];
    
    if(icode == 4'b0000 || icode == 4'b0001)   //halt  //nop
    begin 
         valP = PC + 1;
        f_predPC = valP;

    end

 if(icode == 4'b0010 ||  icode == 4'b0011 || icode == 4'b0100 || icode == 4'b0101 ||  icode == 4'b0110)  //cmovq //irmovq  //rmmovq  //mrmovq  // OPq

    begin   
        rA = instr_mem[PC+1][7:4];
        rB = instr_mem[PC+1][3:0]; 

        if(icode == 4'b0010 || icode == 4'b0110)  //cmovq  //Opq  
        begin 
        valP=PC+2;
        f_predPC=valP;
        end

        if(icode == 4'b0011 || icode == 4'b0100 || icode == 4'b0101) //irmovq  //rmmovq  //mrmovq
        begin
        valC = {instr_mem[PC+9],instr_mem[PC+8],instr_mem[PC+7],instr_mem[PC+6],instr_mem[PC+5],instr_mem[PC+4],instr_mem[PC+3],instr_mem[PC+2]};
        valP = PC+10;
        f_predPC=valP;
        end
    end

    if(icode == 4'b0111 || icode == 4'b1000 )  //call //jxx
    begin
        valC = {instr_mem[PC+8],instr_mem[PC+7],instr_mem[PC+6],instr_mem[PC+5],instr_mem[PC+4],instr_mem[PC+3],instr_mem[PC+2],instr_mem[PC+1]};

        valP=PC+9;
        f_predPC=valC; // In pipeline we assume initailly jump is taken
    end




if(icode == 4'b0111 || icode == 4'b1000 )  //call //jxx
    begin
        valC = {instr_mem[PC+8],instr_mem[PC+7],instr_mem[PC+6],instr_mem[PC+5],instr_mem[PC+4],instr_mem[PC+3],instr_mem[PC+2],instr_mem[PC+1]};

        valP=PC+9;
        f_predPC=valC; // In pipeline we assume initailly jump is taken
    end


  if(icode == 4'b1001) //ret
    begin
        valP=PC+1;
    end
//  if(M_icode == 4'b0111 && M_cnd == 1 )  //call //jxx
//     begin
//         valC = {instr_mem[PC+8],instr_mem[PC+7],instr_mem[PC+6],instr_mem[PC+5],instr_mem[PC+4],instr_mem[PC+3],instr_mem[PC+2],instr_mem[PC+1]};

//         // valP=PC+9;
    
//         f_predPC= M_valA; // In pipeline we assume initailly jump is taken
//     end

// //   if(W_icode == 4'b1001) //ret
// //     begin
// //         valP= W_;
// //     end


   if(icode ==  4'hA || icode == 4'hB) //pushq   //popq
    begin
        rA = instr_mem[PC+1][7:4];
        rB = instr_mem[PC+1][3:0];
        valP=PC+2;
        f_predPC=valP;
    end


    if( icode > 11)
        instr_valid=1'b0;


    if(instr_valid==1'b0) // If the instruction is invalid
        stat = 3'b100;

    else if(memory_error==1) // for memory address
    begin
        stat = 3'b011;
    end

    else if(icode==4'b0000) // for halting
        stat = 3'b010;         // ALL OK (MSB is 1 and rest are 0)

end


always @(posedge clk)
begin
    if(F_stall)
    begin
        PC = F_predPC; // we keep our PC value same as previous
    end
    if(!D_stall)
    begin
    if(D_bubble) // In this case we just execute of nop 
    begin
        D_icode <= 4'b0001;
        D_ifun <= 4'b0000;
        D_rA <= 4'b1111;
        D_rB <= 4'b1111;
        D_valC <= 64'b0;
        D_valP <= 64'b0;
        D_stat <= 3'b001; // ALL OK status
    end
    else
    begin
        D_icode <= icode;
        D_ifun <= ifun;
        D_rA <= rA;
        D_rB <= rB;
        D_valC <= valC;
        D_valP <= valP;
        D_stat <= stat;
    end
    end
end

// initial
// begin

//    $readmemb("test5.txt",instr_mem,0,23);

// end 

endmodule