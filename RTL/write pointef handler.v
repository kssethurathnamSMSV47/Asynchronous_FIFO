module write_pointer_handler(full, b_wptr, g_wptr,
wclk, wrst_n, g_rptr_sync, wr_en);

    input wclk, wrst_n, wr_en;
    input [4:0] g_rptr_sync;
    output full;
    output reg [4:0] b_wptr;
    output [4:0] g_wptr;

    wire [4:0] b_rptr_sync;

    grey_to_binary G2(b_rptr_sync, g_rptr_sync);
    binary_to_grey B2(g_wptr, b_wptr);

    assign full = ({~b_wptr[4],b_wptr[3:0]} == b_rptr_sync);

    always @(posedge wclk)
    begin
        if(!wrst_n)
        begin
            b_wptr <= 0;
        end
        else begin
            if(wr_en && !full) begin
                b_wptr <= b_wptr + 1;
            end
        end
    end

endmodule
