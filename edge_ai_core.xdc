# ==============================================================================
# Edge AI Accelerator - Timing Constraints
# Target Device: Generic Xilinx FPGA
# ==============================================================================

# Define the primary system clock
# We are requesting a 100 MHz clock (10.000 ns period) with a 50% duty cycle.
# Because the MAC unit is pipelined, the Critical Path (T_comb) is significantly 
# reduced, allowing this chip to easily meet this timing constraint.


create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]

