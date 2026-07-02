module tb_edge_ai;

    reg tb_clk;
    reg tb_rst;
    reg signed [7:0] tb_A_row0, tb_A_row1;
    reg signed [7:0] tb_B_col0, tb_B_col1;

    wire signed [31:0] tb_Y00, tb_Y01, tb_Y10, tb_Y11;

    // Instantiate the DUT
    systolic_array_2x2 uut (
        .clk(tb_clk), .rst(tb_rst),
        .A_in_row0(tb_A_row0), .A_in_row1(tb_A_row1),
        .B_in_col0(tb_B_col0), .B_in_col1(tb_B_col1),
        .Y00(tb_Y00), .Y01(tb_Y01), .Y10(tb_Y10), .Y11(tb_Y11)
    );

    // Clock Generation (10ns Period)
    always #5 tb_clk = ~tb_clk;

    initial begin
        // Initialize
        tb_clk = 0; tb_rst = 1;
        tb_A_row0 = 0; tb_A_row1 = 0;
        tb_B_col0 = 0; tb_B_col1 = 0;

        #10 tb_rst = 0; // Release Reset

        // =========================================================
        // DATA SKEWING: The Parallelogram Injection
        // =========================================================
        $display("Starting Matrix Multiplication...");

        // Cycle 1: Inject a00 and b00
        @(posedge tb_clk);
        tb_A_row0 = 8'd1; tb_A_row1 = 8'd0;
        tb_B_col0 = 8'd5; tb_B_col1 = 8'd0;

        // Cycle 2: Inject a01, a10 and b10, b01
        @(posedge tb_clk);
        tb_A_row0 = 8'd2; tb_A_row1 = 8'd3;
        tb_B_col0 = 8'd7; tb_B_col1 = 8'd6;

        // Cycle 3: Inject a11 and b11
        @(posedge tb_clk);
        tb_A_row0 = 8'd0; tb_A_row1 = 8'd4;
        tb_B_col0 = 8'd0; tb_B_col1 = 8'd8;

        // Cycle 4: Push Zeros to flush the array
        @(posedge tb_clk);
        tb_A_row0 = 8'd0; tb_A_row1 = 8'd0;
        tb_B_col0 = 8'd0; tb_B_col1 = 8'd0;

        // Wait a few clock cycles for the pipeline to finish accumulating
        repeat(3) @(posedge tb_clk);

        // Print Results
        $display("\n===============================");
        $display("FINAL OUTPUT MATRIX (Y):");
        $display("[%d, %d]", tb_Y00, tb_Y01);
        $display("[%d, %d]", tb_Y10, tb_Y11);
        $display("===============================\n");
        
        $display("Expected: [19, 22]");
        $display("          [43, 50]");

        $finish;
    end
endmodule
