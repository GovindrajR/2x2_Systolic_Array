/* =====================================================================
   Module: Edge AI Systolic Array Core
   Description: A 2x2 Systolic Array of Processing Elements (PEs) using
                pipelined Multiply-Accumulate (MAC) units.
   Architecture: Output-Stationary (Accumulators stay inside PEs).
                 Data flows Right (Activations) and Down (Weights).
======================================================================== */

// ---------------------------------------------------------------------
// 1. Pipelined MAC Unit (The Math Engine)
// ---------------------------------------------------------------------
module pipelined_mac (
    input wire clk,
    input wire rst,
    input wire signed [7:0] A,
    input wire signed [7:0] B,
    output reg signed [31:0] Y
);
    reg signed [15:0] P_reg; // Pipeline register to hold A * B

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            P_reg <= 16'sd0;
            Y     <= 32'sd0;
        end else begin
            // Stage 1: Multiply
            P_reg <= A * B;
            // Stage 2: Accumulate (Using the product from the previous cycle)
            Y     <= Y + P_reg;
        end
    end
endmodule

// ---------------------------------------------------------------------
// 2. Processing Element
// ---------------------------------------------------------------------
module processing_element (
    input wire clk,
    input wire rst,
    input wire signed [7:0] A_in,
    input wire signed [7:0] B_in,
    output reg signed [7:0] A_out,
    output reg signed [7:0] B_out,
    output wire signed [31:0] Y
);
    // The Math Engine (Branch Before Registers)
    pipelined_mac mac_core (
        .clk(clk),
        .rst(rst),
        .A(A_in),
        .B(B_in),
        .Y(Y)
    );

    // Forwarding Registers (1 Clock Cycle Delay)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_out <= 8'sd0;
            B_out <= 8'sd0;
        end else begin
            A_out <= A_in; // Pass to Right
            B_out <= B_in; // Pass to Bottom
        end
    end
endmodule

// ---------------------------------------------------------------------
// 3. Top-Level 2x2 Systolic Array
// ---------------------------------------------------------------------
module systolic_array_2x2 (
    input wire clk,
    input wire rst,

    // Matrix A Inputs (Activations entering from the Left)
    input wire signed [7:0] A_in_row0,
    input wire signed [7:0] A_in_row1,

    // Matrix B Inputs (Weights entering from the Top)
    input wire signed [7:0] B_in_col0,
    input wire signed [7:0] B_in_col1,

    // Matrix Y Outputs (The final accumulated results)
    output wire signed [31:0] Y00,
    output wire signed [31:0] Y01,
    output wire signed [31:0] Y10,
    output wire signed [31:0] Y11
);

    // Internal interconnect wires
    wire signed [7:0] a_00_to_01, a_10_to_11;
    wire signed [7:0] b_00_to_10, b_01_to_11;
    wire signed [7:0] unused_A_out_01, unused_A_out_11;
    wire signed [7:0] unused_B_out_10, unused_B_out_11;

    // PE [0,0] - Top Left
    processing_element pe00 (
        .clk(clk), .rst(rst),
        .A_in(A_in_row0), .B_in(B_in_col0),
        .A_out(a_00_to_01), .B_out(b_00_to_10),
        .Y(Y00)
    );

    // PE [0,1] - Top Right
    processing_element pe01 (
        .clk(clk), .rst(rst),
        .A_in(a_00_to_01), .B_in(B_in_col1),
        .A_out(unused_A_out_01), .B_out(b_01_to_11),
        .Y(Y01)
    );

    // PE [1,0] - Bottom Left
    processing_element pe10 (
        .clk(clk), .rst(rst),
        .A_in(A_in_row1), .B_in(b_00_to_10),
        .A_out(a_10_to_11), .B_out(unused_B_out_10),
        .Y(Y10)
    );

    // PE [1,1] - Bottom Right
    processing_element pe11 (
        .clk(clk), .rst(rst),
        .A_in(a_10_to_11), .B_in(b_01_to_11),
        .A_out(unused_A_out_11), .B_out(unused_B_out_11),
        .Y(Y11)
    );

endmodule
