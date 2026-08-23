
module Async_fifo(data_out, full, empty, w_clk, r_clk, w_en,
r_en, w_rst_n, rrst_n, data_in);

    input [7:0] data_in;
    input w_clk, r_clk, w_en, r_en, w_rst_n, rrst_n;
    output full, empty;
    output [7:0] data_out;

    wire [4:0] b_rptr, b_wptr, g_rptr, g_wptr, g_wptr_sync, g_rptr_sync;

    read_pointer_handler R(.empty(empty), .g_rptr(g_rptr), .b_rptr(b_rptr), 
.g_wptr_sync(g_wptr_sync),.r_clk(r_clk), .r_en(r_en), .rrst_n(rrst_n));

    write_pointer_handler W(.full(full), .b_wptr(b_wptr), .g_wptr(g_wptr),
.wclk(w_clk), .wrst_n(w_rst_n), .g_rptr_sync(g_rptr_sync), .wr_en(w_en));

    dual_rom D(.data_in(data_in), .data_out(data_out), .w_clk(w_clk), .r_clk(r_clk),
.w_en(w_en), .r_en(r_en), .w_ptr(b_wptr), .r_ptr(b_rptr), .full(full), .empty(empty));

    two_flop_synchronizer T1(.q(g_wptr_sync[4]), .clk(r_clk), .d(g_wptr[4]), .rst(rrst_n));
    two_flop_synchronizer T2(.q(g_wptr_sync[3]), .clk(r_clk), .d(g_wptr[3]), .rst(rrst_n));
    two_flop_synchronizer T3(.q(g_wptr_sync[2]), .clk(r_clk), .d(g_wptr[2]), .rst(rrst_n));
    two_flop_synchronizer T4(.q(g_wptr_sync[1]), .clk(r_clk), .d(g_wptr[1]), .rst(rrst_n));
    two_flop_synchronizer T5(.q(g_wptr_sync[0]), .clk(r_clk), .d(g_wptr[0]), .rst(rrst_n));
    two_flop_synchronizer T6(.q(g_rptr_sync[4]), .clk(w_clk), .d(g_rptr[4]), .rst(w_rst_n));
    two_flop_synchronizer T7(.q(g_rptr_sync[3]), .clk(w_clk), .d(g_rptr[3]), .rst(w_rst_n));
    two_flop_synchronizer T8(.q(g_rptr_sync[2]), .clk(w_clk), .d(g_rptr[2]), .rst(w_rst_n));
    two_flop_synchronizer T9(.q(g_rptr_sync[1]), .clk(w_clk), .d(g_rptr[1]), .rst(w_rst_n));
    two_flop_synchronizer T10(.q(g_rptr_sync[0]), .clk(w_clk), .d(g_rptr[0]), .rst(w_rst_n));

endmodule
