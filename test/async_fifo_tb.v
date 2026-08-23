`timescale 1ns/1ps

module tb_async_fifo;


    reg                  wr_clk = 0;
    reg                  rd_clk = 0;
    reg                  wr_rst_n = 0;
    reg                  rd_rst_n = 0;
    reg                  wr_en = 0;
    reg  [7:0]     wr_data = 0;
    wire                 full;
    reg                  rd_en = 0;
    wire [7:0]     rd_data;
    wire                 empty;

    integer wr_count   = 0;
    integer rd_count   = 0;
    integer errors     = 0;
    integer next_wdata  = 0;

    reg [7:0] expected_q [0:2047];
    integer wr_ptr_sb = 0;
    integer rd_ptr_sb = 0;

    Async_fifo D (.data_out(rd_data), .full(full), .empty(empty), .w_clk(wr_clk), 
.r_clk(rd_clk), .w_en(wr_en), .r_en(rd_en), .w_rst_n(wr_rst_n), .rrst_n(rd_rst_n),
.data_in(wr_data));

    always #5  wr_clk = ~wr_clk;   // 100.0 MHz
    always #7  rd_clk = ~rd_clk;   //  71.4 MHz

    initial begin
        wr_rst_n = 0; rd_rst_n = 0;
        repeat (5) @(posedge wr_clk);
        wr_rst_n = 1;
        repeat (5) @(posedge rd_clk);
        rd_rst_n = 1;
    end

    integer wcycles = 0;
    always @(posedge wr_clk) begin
        if (!wr_rst_n) begin
            wr_en <= 0;
        end else begin
            // 1) Record the effect of whatever wr_en/wr_data were driving
            //    THIS edge (i.e. exactly what the DUT just latched).
            if (wr_en && !full) begin
                expected_q[wr_ptr_sb] = wr_data;
                wr_ptr_sb = wr_ptr_sb + 1;
                wr_count  = wr_count + 1;
            end
            // 2) Decide stimulus to drive for the NEXT edge.
            wcycles = wcycles + 1;
            if (wcycles <= 600 && !full && ($random % 3 != 0)) begin
                wr_en   <= 1;
                wr_data <= next_wdata[7:0];
                next_wdata = next_wdata + 1;
            end else begin
                wr_en <= 0;
            end
        end
    end

    integer rcycles = 0;
    // always @(posedge rd_clk) begin
    //     if (!rd_rst_n) begin
    //         rd_en <= 0;
    //     end else begin
    //         // 1) Record the effect of whatever rd_en was driving THIS edge.
    //         if (rd_en && !empty) begin
    //             if (rd_data !== expected_q[rd_ptr_sb]) begin
    //                 $display("MISMATCH at t=%0t: got %0d expected %0d (rd_ptr_sb=%0d)",
    //                           $time, rd_data, expected_q[rd_ptr_sb], rd_ptr_sb);
    //                 errors = errors + 1;
    //             end
    //             rd_ptr_sb = rd_ptr_sb + 1;
    //             rd_count  = rd_count + 1;
    //         end
    //         // 2) Decide stimulus for the NEXT edge.
    //         rcycles = rcycles + 1;
    //         if (!empty && ($random % 3 != 0))
    //             rd_en <= 1;
    //         else
    //             rd_en <= 0;

    //         if (rcycles > 1200 && rd_count >= wr_count && !(wr_en || (wcycles<=600))) begin
    //             // drained everything after the write process stopped
    //         end
    //     end
    // end

    always @(posedge rd_clk) begin
    if (!rd_rst_n) begin
        rd_en <= 0;
    end
    else begin

        if (rd_en && !empty) begin
            #1;

            if (rd_data !== expected_q[rd_ptr_sb]) begin
                $display("MISMATCH at t=%0t: got %0d expected %0d (rd_ptr_sb=%0d)",
                          $time, rd_data, expected_q[rd_ptr_sb], rd_ptr_sb);
                errors = errors + 1;
            end

            rd_ptr_sb = rd_ptr_sb + 1;
            rd_count  = rd_count + 1;
        end

        rcycles = rcycles + 1;

        if (!empty && ($random % 3 != 0))
            rd_en <= 1;
        else
            rd_en <= 0;
    end
end

    initial begin

        $dumpfile("async_fifo.vcd");
        $dumpvars(0, tb_async_fifo);
        wait (wr_rst_n && rd_rst_n);
        wait (wcycles > 600);          // write stimulus phase complete
        // Keep clocking reads until fully drained
        wait (rd_count == wr_count);
        #100;
        $display("--------------------------------------------------");
        $display("Total written = %0d, Total read = %0d", wr_count, rd_count);
        if (errors == 0 && wr_count == rd_count)
            $display("TEST PASSED: all %0d words verified, no data corruption", rd_count);
        else
            $display("TEST FAILED: %0d mismatches, wr_count=%0d rd_count=%0d",
                      errors, wr_count, rd_count);
        $display("--------------------------------------------------");
        $finish;
    end

    initial begin
        #200000;
        $display("TIMEOUT - simulation did not finish in time");
        $finish;
    end

endmodule
