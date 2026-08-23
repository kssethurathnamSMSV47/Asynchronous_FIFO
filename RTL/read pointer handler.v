module read_pointer_handler(empty, g_rptr, b_rptr, g_wptr_sync,
r_clk, r_en, rrst_n);

    input r_clk, r_en, rrst_n;
    input [4:0] g_wptr_sync;
    output reg [4:0] b_rptr;
    output [4:0] g_rptr;
    output empty;

    wire [4:0] b_wptr_sync;

    grey_to_binary G1(b_wptr_sync, g_wptr_sync);
    binary_to_grey B1(g_rptr, b_rptr);

    assign empty = (b_rptr == b_wptr_sync);

    always @(r_clk)
    begin
        if(rrst_n)
        begin
            b_rptr <= 0;
        end
        else begin
            if(r_en && !empty)
            begin
                b_rptr <= b_rptr + 1;
            end
        end
    end

endmodule
