# MIPS Multi-Cycle Processor Implementation in VHDL

A fully functional, synthesizable 32-bit Multi-Cycle MIPS processor core implemented in VHDL. This design breaks down instruction execution into multiple clock cycles (Fetch, Decode, Execute, Memory, Writeback), optimizing hardware utilization by sharing major components like the ALU and Memory interface across different cycles.

## Features & Supported ISA

The processor implements a subset of the MIPS32 Instruction Set Architecture (ISA), supporting three instruction formats: **R-type**, **I-type**, and **J-type**. 

### Supported Instructions:
* **Memory Access:** `lw` (Load Word), `sw` (Store Word), `lbu` (Load Byte Unsigned)
* **Computational (R-type):** `add`, `sub`, `and`, `or`, `slt`
* **Immediate Operations:** `addi` (Add Immediate), `ori` (OR Immediate), `xori` (XOR Immediate)
* **Control Flow:** `beq` (Branch on Equal), `bne` (Branch on Not Equal), `j` (Jump), `jr` (Jump Register)

## Architecture Overview

Unlike a single-cycle processor, this multi-cycle architecture reuses core hardware elements to minimize resource consumption:
* **Unified Memory:** A single memory block (`mem.vhd`) handles both instructions and data, multiplexed via the `IorD` control signal.
* **Shared ALU:** The central ALU performs PC increments, branch address calculations, and standard arithmetic/logical operations.
* **Finite State Machine (FSM):** A 20-state main controller (`main_controller.vhd`) coordinates the control matrix and multiplexer selects synchronized to the system clock.

## Project Structure

* `top.vhd` - System top-level wrapper integrating the MIPS core and the memory.
* `mips.vhd` - Core processor module connecting the Datapath and the Control Unit.
* `control_unit.vhd` - Contains the main FSM controller and ALU decoder.
* `main_controller.vhd` - Multi-cycle Finite State Machine execution logic.
* `alu_decoder.vhdl` - Decodes ALU operations based on FSM states and instruction fields.
* `datapath.vhd` - Hardware execution path (registers, multiplexers, extenders).
* `register_file.vhd` - 32x32-bit architectural register file (with hardwired `$zero`).
* `alu.vhdl` - Arithmetic Logic Unit.
* `mem.vhd` - 64-word memory module simulating unified RAM with file-loading capabilities.
* `sign_or_zero_extension.vhd` - Configurable arithmetic/logical immediate extension unit.
* `byte_select.vhdl` - Hardware block supporting partial-word operations (`lbu`).
* `flopr.vhdl` / `mux2.vhdl` / `mux4.vhdl` - Basic sequential and combinational building blocks.
* `testbench.vhdl` - Complete system testbench for validation.
* `memfile.txt` - External hexadecimal file containing MIPS machine code for simulation.

## Simulation & Testing

The project includes a comprehensive verification environment (`tb_top` inside `testbench.vhdl`) that automatically initializes the system, applies a reset sequence, and runs the application loaded into memory.

### How to run:
1. Open the project in your preferred HDL simulation tool (e.g., Vivado, ModelSim, or GHDL).
2. Ensure the file path for `memfile.txt` inside `mem.vhd` correctly points to your local directory:
   ```vhdl
   signal RAM : ramtype := init_ram("C:/your_path_here/memfile.txt");
3. Set tb_top as the top-level simulation module.
4. Run the simulation. The testbench generates a 100 MHz clock and will simulate execution for 250 cycles before gracefully terminating with a "Simulation Finished Successfully" assertion.

# Author
Adrian Mateńka - Entry-level Hardware Developer