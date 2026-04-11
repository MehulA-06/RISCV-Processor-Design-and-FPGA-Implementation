# RISC-V RV32I Single-Cycle and Pipeline Processor on ZedBoard (Zynq-7000 FPGA)

## Overview
This project implements a **32-bit RISC-V RV32I single-cycle processor** in **Verilog HDL** and deploys it on the **ZedBoard (Zynq-7000 FPGA)**. The processor executes instructions in a single clock cycle and supports a subset of the **RV32I instruction set architecture**.

The design includes essential processor components such as:

- Program Counter (PC)
- Instruction Memory
- Register File
- Arithmetic Logic Unit (ALU)
- Control Unit
- Data Memory
- Immediate Generator
- Performance Counters

The processor is synthesized and implemented using **Xilinx Vivado**, and results are verified through both **simulation and FPGA hardware testing**.

---

# Architecture

The processor follows a **single-cycle datapath architecture**, meaning each instruction completes within one clock cycle.

### Core Modules

| Module | Description |
|------|-------------|
| **PC** | Holds address of next instruction |
| **Instruction Memory** | Stores program instructions |
| **Register File** | 32 registers (x0–x31) |
| **ALU** | Performs arithmetic and logical operations |
| **Control Unit** | Generates control signals based on opcode |
| **Immediate Generator** | Extracts and sign-extends immediates |
| **Data Memory** | Handles load/store instructions |
| **Performance Counter** | Tracks cycle and instruction counts |

![Single Cycle RISCV Datapath](Single%20Cycle%20RV32I/Images/Single_Cycle_RISCV_Datapath.png)


# Architecture

The processor follows a **5-stage pipelined datapath architecture**, enabling multiple instructions to be processed simultaneously across different stages (Fetch, Decode, Execute, Memory, Writeback).

### Core Modules

| Module | Description |
|--------|------------|
| **RISCV_Top** | Top-level module integrating all pipeline stages |
| **PC** | Holds address of next instruction |
| **fetch_cycle** | Fetches instruction and updates program counter |
| **Inst_memory** | Stores program instructions |
| **decode_cycle** | Decodes instruction and reads register values |
| **Reg_file** | 32 registers (x0–x31) |
| **control_unit** | Generates control signals based on opcode |
| **main_decoder** | Produces high-level control signals |
| **ALU_decoder** | Generates ALU control signals |
| **Sign_extend** | Extracts and sign-extends immediates |
| **execute_cycle** | Performs ALU operations and branch decisions |
| **ALU** | Performs arithmetic and logical operations |
| **forwarding_unit** | Resolves data hazards using forwarding |
| **hazard_unit** | Detects and handles pipeline hazards (stall/flush) |
| **memory_cycle** | Handles memory access stage |
| **Data_memory** | Handles load/store instructions |
| **writeback_cycle** | Writes results back to register file |
| **Mux** | Selects between multiple data sources |
| **PerformanceCounter** | Tracks cycle and instruction counts |
| **RISCV_Testbench** | Testbench for simulation and verification |

![Pipeline RISCV Datapath](Pipeline%20RV32I/Images/5%20stage%20pipeline%20datapath.png)
---

# Supported Instruction Set

The processor implements a subset of the **RV32I base instruction set**.

### Arithmetic Instructions
- `ADD`
- `SUB`
- `ADDI`
- `SLT`

### Logical Instructions
- `AND`
- `OR`
- `XOR`

### Shift Instructions
- `SLL`
- `SRL`
- `SRA`

### Memory Instructions
- `LW`
- `SW`

### Branch Instructions
- `BEQ`
- `BNE`

### Jump Instructions
- `JAL`
- `JALR`

---

# FPGA Platform

The processor is implemented on the **ZedBoard development board**, which uses the **Xilinx Zynq-7000 XC7Z020 FPGA device**.

### Board Features Used
- Onboard clock
- User LEDs
- Reset push button

---

# Simulation

Simulation is performed using **Vivado Simulator (XSIM)**.

### Running Simulation

1. Open Vivado
2. Add all source files
3. Add the testbench
4. Run behavioral simulation

Example simulation output verifies correct instruction execution by monitoring:

- Program Counter
- Register values
- ALU output
- Memory operations

Example result:
Checkpoint 1:
x1=5
x2=3

Checkpoint 2:
x3=8


---

# FPGA Implementation

## Clock

To make processor activity observable on LEDs, a **clock divider** is used to slow down the CPU clock.


---

# LED Debug Output

For hardware debugging, selected internal signals are mapped to LEDs.

Example:

```verilog
assign led_out = PC_Current[7:0];


This allows visualization of processor execution on FPGA.

