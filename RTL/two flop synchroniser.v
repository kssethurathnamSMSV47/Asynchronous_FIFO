module d_flop(q, clk, d, rst);

    input clk, d, rst;
    output reg q;

    always @(posedge clk)
    begin
        if(rst)
        begin
            q <= 0;
        end
        else begin
            q <= d;
        end
    end

endmodule

module two_flop_synchronizer(q, clk, d, rst);

    input clk, d, rst;
    output q;
    wire t;

    d_flop D0(.q(t), .clk(clk), .d(d), .rst(rst));
    d_flop D1(.q(q), .clk(clk), .d(t), .rst(rst));

endmodule
