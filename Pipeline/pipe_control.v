module pipe_control (m_stat,W_stat,D_icode,E_icode,M_icode,d_srcA,d_srcB,E_dstM,e_cnd,F_stall,D_stall,D_bubble,E_bubble,set_cc);

    input [2:0] m_stat,W_stat;
    input [3:0] D_icode,E_icode,M_icode;
    input [3:0] d_srcA,d_srcB,E_dstM;
    input e_cnd;

    output reg F_stall, D_stall, D_bubble, E_bubble,set_cc;

    always @(*)
    begin
        F_stall=0;
        D_stall=0;
        D_bubble=0;
        E_bubble=0;
        set_cc=1;

        if(E_icode== 4'h7 & e_cnd==0)
        begin
            D_bubble=1;
            E_bubble=1;
        end
        else if ((E_icode == 4'h5 | E_icode==4'hB) & (E_dstM==d_srcA | E_dstM==d_srcB))
        begin
            F_stall=1;
            D_stall=1;
            E_bubble=1;
        end
        else if(E_icode == 4'h9 | M_icode == 4'h9 | D_icode == 4'h9)
        begin
            F_stall = 1;
            D_bubble = 1;
        end

        else if(E_icode == 4'h0 | m_stat!=3'b001 | W_stat!= 3'b001)
        begin
            set_cc = 0;
        end
        else
        begin
            F_stall=0;
            D_stall=0;
            D_bubble=0;
            E_bubble=0;
            
        end

    end

endmodule