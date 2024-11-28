module memory (clk, icode, valA, valB, valP, valE, valM, stored_in_mem,index);

input clk;
input wire [3:0] icode;
input wire [63:0] valA, valB, valP, valE;

output reg [63:0] valM;
reg [63:0] memory_arr [0:1023];
output reg memory_error = 0; //This is just a flag to ensure that we are accessing the correct memory_arr 
output reg signed [63:0] stored_in_mem,index;


// initial 
// begin 

//   memory_arr[0]=8'b00010000; //nop   1  0
//   memory_arr[1]=8'b10010000; // ret  9  0


//   memory_arr[2]=8'b00100000; //cmovq fn 2  0
//   memory_arr[3]=8'b01100100; //rA rB    3  4
  
//   memory_arr[4]=8'b01000000; //rmmovq fn 4 0
//   memory_arr[5]=8'b00100011; //rA rB     
  
//   memory_arr[6]=8'b01010000; 
//   memory_arr[7]=8'b00100011;  
//   memory_arr[8]=8'b01100001;  
//   memory_arr[9]=8'b00100011; 
//   memory_arr[10]=8'b01110000;
//   memory_arr[11]=8'b00100011;
//   memory_arr[12]=8'b10000000;
//   memory_arr[13]=8'b00100011;
  

// end 


always @(*)
begin

    if((valE>1023 )| (valA >1023 ))
    begin 
        memory_error=1;
    end

    else if(icode == 4'b0101) //mrmovq
    begin
        valM=memory_arr[valE];
    end
    else if(icode == 4'b1001) //ret
    begin
        valM=memory_arr[valA];
    end
    else if( icode== 4'b1011) //popq
    begin
        valM=memory_arr[valA];
    end

end


always @(*)
begin
    // we are checking only valE because we are accessing memory_arr with the value of valE in the following cases->
    if(valE>1023) 
       begin
         memory_error=1;
       end

    if(icode == 4'b0100) //rmmovq
    begin
        memory_arr[valE] <= valA;
    end
    else if(icode == 4'b1000) //call
    begin
        memory_arr[valE] <= valP;
    end
    else if(icode == 4'b1010) // pushq
    begin
        memory_arr[valE] <= valA;
    end


    stored_in_mem = memory_arr[valE];
   
end
endmodule