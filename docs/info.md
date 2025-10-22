<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
The Femto RV32I core is a minimalist 32-bit RISC-V processor that implements the RV32I base instruction set. It operates using a single-cycle architecture, meaning each instruction is executed in one clock cycle. This design prioritizes simplicity and compactness, making it ideal for educational and small-scale silicon projects like Tiny Tapeout.

Internally, the core includes:

    - A program counter (PC) that advances each cycle

    - A register file with 32 general-purpose registers

    - An ALU that performs arithmetic and logical operations

    - A control unit that decodes instructions and manages data flow

The processor fetches instructions from a predefined memory space, decodes them, executes them via the ALU, and writes results back to the register file. It supports basic operations such as arithmetic, logic, branching, and memory access.

## How to test

To test the Femto RV32I core, a testbench file is provided that simulates the processor's behavior. This testbench generates clock and reset signals and feeds a sequence of instructions to the core. It also monitors output signals and internal states to verify correct execution.

The simulation produces waveform data that can be visualized using tools like GTKWave. This allows you to inspect signal transitions, instruction flow, and register updates cycle by cycle.

To run the test:

    - Open the testbench file in your preferred simulator (e.g., Verilator, Icarus Verilog).

    - Compile and execute the simulation.

    - Load the generated .vcd file into GTKWave to inspect the waveforms.

    - Confirm that the instruction sequence behaves as expected and that register values match the expected results.

## External hardware

doesnt apply yet.
