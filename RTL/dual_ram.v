module dual_rom(data_in, data_out, w_clk, r_clk, w_en, r_en,
w_ptr, r_ptr, full, empty);

    input [7:0] data_in;
    input w_clk, r_clk, w_en, r_en, full, empty;
    input [4:0] w_ptr, r_ptr;
    output reg [7:0] data_out;

    reg [7:0] mem [15:0];

    always @(posedge w_clk or posedge r_clk)
    begin
        if(w_en && !full)
        begin
            mem[w_ptr[3:0]] <= data_in;
        end
        if(r_en && !empty)
        begin
            data_out <= mem[r_ptr[3:0]];
        end
    end

endmodule
