module pc_update(cnd,clk,icode,new_PC,valM,valC,valP);

input [63:0] valC,valM,valP;
input clk,cnd;
input [3:0] icode;

///// updates pc value
output reg [63:0] new_PC;     

always@(*)
begin
case(icode)
4'b0111:         ///jump
begin
    if(cnd)
        new_PC=valC;
    
    else
        new_PC=valP;
    
end

4'b1001:      ///return
begin
    new_PC=valM;
end

4'b1000:   ///call
begin
    new_PC=valC;
end

default:        ///default
begin
    new_PC=valP;
end

endcase

end
endmodule