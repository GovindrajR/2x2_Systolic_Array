## Edge AI Accelerator: 2x2 Pipelined Systolic Array

### 📌 Overview

This repository contains the RTL design, verification testbench, and synthesis results for a custom 2x2 Systolic Array, a fundamental hardware accelerator architecture used in modern Edge AI and Machine Learning ASICs (like the Google TPU) to accelerate Matrix Multiplication.

This project demonstrates advanced Digital VLSI and Computer Architecture concepts:

Pipelined Datapaths: Breaking the Multiplier-Adder critical path to maximize $F_{max}$.

Spatial Computing: Connecting Processing Elements (PEs) in a 2D mesh to pass data horizontally and vertically.

Hardware Dataflow (Skewing): Designing testbenches to inject data in a staggered "parallelogram" format to resolve physical timing latencies across the grid.

## 🏗️ Hardware Architecture

1. The Processing Element (PE)

The core "cell" of the array is the Processing Element. Each PE contains:

A Pipelined MAC (Multiply-Accumulate) Unit that computes $Y = Y + (A \times B)$ over a 2-cycle latency.

Forwarding Registers that catch the input Activation (A) and Weight (B) and pass them to the neighboring PEs on the next clock tick (the "Bucket Brigade" concept).

2. The 2x2 Systolic Mesh

The 4 PEs are structurally wired in a 2x2 grid.

Activations (A) stream horizontally from Left to Right.

Weights (B) stream vertically from Top to Bottom.

Partial sums (Y) remain stationary inside each PE's 32-bit accumulator (Output-Stationary Dataflow).

### 📊 Verification & Data Skewing

Because data takes physical time (clock cycles) to travel through the grid, the input matrices cannot be injected instantly. The software/memory controller must skew the matrices into a parallelogram.

Test Case: 2x2 Matrix Multiplication

Matrix A (Activations)   Matrix B (Weights)
[ 1, 2 ]                 [ 5, 6 ]
[ 3, 4 ]                 [ 7, 8 ]



Simulation Output (Vivado XSIM):

Starting Matrix Multiplication...

===============================
FINAL OUTPUT MATRIX (Y):
[         19,          22]
[         43,          50]
===============================
Expected: [19, 22]
          [43, 50]



### 📈 Synthesis & Implementation Results

Synthesized and Implemented using Xilinx Vivado targeting a generic FPGA architecture.

Area & Power (Utilization Report)

LUTs: 372 (0.28% Utilization)

Registers (Flip-Flops): 224 (0.08% Utilization)

Total On-Chip Power: 0.262 W (Dynamic: 0.131 W)

Engineering Note: The architecture is heavily optimized for area, utilizing minimal combinational logic by leveraging strict pipelining.

Timing Analysis (STA)

Target Clock: 100 MHz (10.000 ns period)

Worst Negative Slack (WNS): +4.554 ns

Setup/Hold Violations: 0

Engineering Note: The pipelined MAC architecture successfully broke the Multiplier-Adder critical path. With a positive slack of 4.554ns, the current logic resolves in ~5.4ns, indicating this core can comfortably scale to >180 MHz before experiencing setup violations on this fabric.

### 🛠️ How to Run

Clone this repository.

Open Xilinx Vivado and create a new project.

Add edge_ai_core.v as a Design Source.

Add tb_edge_ai.v as a Simulation Source.

Add edge_ai_core.xdc as a Constraints file.

Run Behavioral Simulation or Synthesis.

Designed by 

$$ Govindraj R $$

 | Open to VLSI/Hardware Architecture Roles.
