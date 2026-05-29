# RISC-V Processor Design and FPGA Implementation


## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Part 1 – Single-Cycle RV32I Processor](#part-1--single-cycle-rv32i-processor)
  - [Architecture](#architecture--single-cycle)
  - [Core Modules](#core-modules--single-cycle)
  - [Datapath Diagram](#datapath-diagram--single-cycle)
- [Part 2 – 5-Stage Pipelined RV32I Processor](#part-2--5-stage-pipelined-rv32i-processor)
  - [Architecture](#architecture--pipeline-rv32i)
  - [Core Modules](#core-modules--pipeline-rv32i)
  - [Datapath Diagram](#datapath-diagram--pipeline-rv32i)
- [Part 3 – Pipelined RV32IMC Processor](#part-3--pipelined-rv32imc-processor)
- [Supported Instruction Set](#supported-instruction-set)
- [Hazard Handling](#hazard-handling)
- [FPGA Platforms](#fpga-platforms)
- [Tools & Prerequisites](#tools--prerequisites)
- [Getting Started](#getting-started)
- [Simulation](#simulation)
- [FPGA Implementation](#fpga-implementation)
- [Performance Counters](#performance-counters)
- [Project Highlights](#project-highlights)

---

## Overview

This project presents a complete ground-up implementation of **32-bit RISC-V processors** in **Verilog HDL**, progressing from a simple single-cycle design to a full 5-stage pipelined processor with hazard handling, and finally extending to the **RV32IMC** ISA (Integer + Multiply/Divide + Compressed instructions).

All designs are synthesized, implemented, and verified on real **FPGA hardware** using **Xilinx Vivado**.

| Design | ISA | Architecture | Target FPGA |
|---|---|---|---|
| Single-Cycle | RV32I | Single-cycle | ZedBoard (Zynq-7000) |
| Pipeline | RV32I | 5-stage pipeline | ZedBoard (Zynq-7000) |
| Pipeline | RV32IMC | 5-stage pipeline | ZedBoard (Zynq-7000) + Genesys 2 |

---

## Repository Structure

```
RISCV-Processor-Design-and-FPGA-Implementation/
│
├── Single Cycle RV32I/
│   ├── Sources/              # Verilog source files
│   ├── Testbench/            # Simulation testbench
│   ├── Constraints/          # XDC constraint files
│   └── Images/               # Architecture diagrams
│
├── Pipeline RV32I/
│   ├── Sources/              # Verilog source files
│   ├── Testbench/            # Simulation testbench
│   ├── Constraints/          # XDC constraint files
│   └── Images/               # Architecture diagrams
│
├── Pipeline RV32IMC/
│   ├── Sources/              # Verilog source files
│   ├── Testbench/            # Simulation testbench
│   ├── Constraints/          # XDC constraint files
│   └── Images/               # Architecture diagrams
│
└── README.md
```

---

## Part 1 – Single-Cycle RV32I Processor

### Architecture – Single-Cycle

The single-cycle processor completes **every instruction in exactly one clock cycle**. All datapath components are active simultaneously per instruction, driven by a central control unit decoding the opcode.

```
         ┌──────────┐    ┌──────────────────┐    ┌──────────┐
  CLK ──►│    PC    │───►│ Instruction Mem  │───►│ Control  │
         └──────────┘    └──────────────────┘    │  Unit    │
               ▲                  │               └──────────┘
               │            Instruction                │
               │                  ▼               Control Signals
               │         ┌──────────────┐              │
               │         │  Reg File    │◄─────────────┤
               │         └──────────────┘              │
               │                  │                    │
               │                  ▼                    │
               │             ┌─────────┐               │
               │             │   ALU   │◄──────────────┤
               │             └─────────┘               │
               │                  │                    │
               │                  ▼                    │
               │          ┌─────────────┐              │
               └──────────│  Data Mem   │              │
                          └─────────────┘              │
```

### Core Modules – Single-Cycle

| Module | File | Description |
|---|---|---|
| `PC` | `PC.v` | Program counter — holds and updates the address of the current instruction |
| `Inst_Memory` | `Inst_Memory.v` | Read-only instruction memory, initialized with the program |
| `Reg_File` | `Reg_File.v` | 32 × 32-bit general-purpose registers (x0 hardwired to 0) |
| `ALU` | `ALU.v` | Performs ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT |
| `Control_Unit` | `Control_Unit.v` | Decodes opcode and generates all datapath control signals |
| `Imm_Gen` | `Imm_Gen.v` | Extracts and sign-extends immediates for all instruction formats |
| `Data_Memory` | `Data_Memory.v` | Read/write data memory for LW/SW instructions |
| `PerformanceCounter` | `PerformanceCounter.v` | Counts total cycles and retired instructions |
| `Top` | `Top.v` | Top-level module wiring all components together |
| `Testbench` | `Testbench.v` | Simulation testbench with checkpoint-based verification |

### Datapath Diagram – Single-Cycle

![Single Cycle RISCV Datapath](Single%20Cycle%20RV32I/Images/Single_Cycle_RISCV_Datapath.png)

---

## Part 2 – 5-Stage Pipelined RV32I Processor

### Architecture – Pipeline RV32I

The pipelined processor implements the classic **5-stage RISC pipeline**: Fetch → Decode → Execute → Memory → Writeback. Inter-stage pipeline registers hold intermediate values, allowing multiple instructions to be in-flight simultaneously.

```
  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
  │  FETCH  │──►│ DECODE  │──►│ EXECUTE │──►│ MEMORY  │──►│  WRITE  │
  │         │   │         │   │         │   │         │   │  BACK   │
  │  IF/ID  │   │  ID/EX  │   │ EX/MEM  │   │ MEM/WB  │   │         │
  └─────────┘   └─────────┘   └─────────┘   └─────────┘   └─────────┘
       ▲               ▲            ▲
       │               │            │
  ┌────┴───────────────┴────────────┴──────┐
  │         Hazard & Forwarding Unit       │
  └────────────────────────────────────────┘
```

**Key features:**
- **Data forwarding** (EX-EX and MEM-EX) to eliminate most data hazards without stalls
- **Hazard detection unit** for load-use stalls (1-cycle bubble insertion)
- **Branch flush** on taken branches (control hazard handling)

### Core Modules – Pipeline RV32I

| Module | File | Description |
|---|---|---|
| `RISCV_Top` | `RISCV_Top.v` | Top-level integrating all pipeline stages |
| `fetch_cycle` | `fetch_cycle.v` | IF stage: instruction fetch and PC update |
| `Inst_memory` | `Inst_memory.v` | Instruction memory |
| `decode_cycle` | `decode_cycle.v` | ID stage: decode and register read |
| `Reg_file` | `Reg_file.v` | 32 × 32-bit register file (x0 = 0) |
| `control_unit` | `control_unit.v` | Top-level control unit |
| `main_decoder` | `main_decoder.v` | Produces high-level control signals from opcode |
| `ALU_decoder` | `ALU_decoder.v` | Generates specific ALU operation codes |
| `Sign_extend` | `Sign_extend.v` | Immediate extraction and sign-extension |
| `execute_cycle` | `execute_cycle.v` | EX stage: ALU operation and branch evaluation |
| `ALU` | `ALU.v` | Arithmetic Logic Unit |
| `forwarding_unit` | `forwarding_unit.v` | Data hazard resolution via forwarding |
| `hazard_unit` | `hazard_unit.v` | Stall and flush control for hazards |
| `memory_cycle` | `memory_cycle.v` | MEM stage: data memory access |
| `Data_memory` | `Data_memory.v` | Data memory for LW/SW |
| `writeback_cycle` | `writeback_cycle.v` | WB stage: register file write-back |
| `Mux` | `Mux.v` | Parameterized multiplexers for datapath selects |
| `PerformanceCounter` | `PerformanceCounter.v` | Cycle and instruction retirement counters |
| `RISCV_Testbench` | `RISCV_Testbench.v` | Full simulation testbench |

### Datapath Diagram – Pipeline RV32I

![Pipeline RISCV Datapath](Pipeline%20RV32IMC/Images/5%20stage%20pipeline%20datapath.png)

---

## Part 3 – Pipelined RV32IMC Processor

The **RV32IMC** processor extends the pipelined RV32I design with two additional standard extensions:

| Extension | Description |
|---|---|
| **M** – Integer Multiply/Divide | Adds `MUL`, `MULH`, `MULHSU`, `MULHU`, `DIV`, `DIVU`, `REM`, `REMU` instructions |
| **C** – Compressed Instructions | Adds 16-bit compressed instruction encodings to reduce code size |

This design is the most feature-complete variant in this repository and targets both the **ZedBoard** and the **Genesys 2** (Kintex-7) FPGA platform.

---

## Supported Instruction Set

### RV32I Base Integer Instructions

| Category | Instructions |
|---|---|
| **Arithmetic (R-type)** | `ADD`, `SUB`, `SLT`, `SLTU` |
| **Arithmetic (I-type)** | `ADDI`, `SLTI`, `SLTIU` |
| **Logical (R-type)** | `AND`, `OR`, `XOR` |
| **Logical (I-type)** | `ANDI`, `ORI`, `XORI` |
| **Shift (R-type)** | `SLL`, `SRL`, `SRA` |
| **Shift (I-type)** | `SLLI`, `SRLI`, `SRAI` |
| **Load** | `LW`, `LH`, `LB`, `LHU`, `LBU` |
| **Store** | `SW`, `SH`, `SB` |
| **Branch** | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` |
| **Jump** | `JAL`, `JALR` |
| **Upper Immediate** | `LUI`, `AUIPC` |

### RV32M Extension (Pipeline RV32IMC only)

| Category | Instructions |
|---|---|
| **Multiply** | `MUL`, `MULH`, `MULHSU`, `MULHU` |
| **Divide/Remainder** | `DIV`, `DIVU`, `REM`, `REMU` |

### RV32C Extension (Pipeline RV32IMC only)

16-bit compressed encodings for common integer instructions — reduces instruction memory footprint.

---

## Hazard Handling

The pipelined processors implement full hazard mitigation:

### Data Hazards

| Hazard Type | Resolution |
|---|---|
| **EX-EX Forwarding** | ALU result from EX/MEM register forwarded directly to EX stage inputs |
| **MEM-EX Forwarding** | ALU/memory result from MEM/WB register forwarded to EX stage inputs |
| **Load-Use Hazard** | 1-cycle stall (pipeline bubble) inserted by the hazard detection unit |

### Control Hazards

| Hazard Type | Resolution |
|---|---|
| **Branch Taken** | Flush instructions in IF and ID stages (2-cycle penalty) |
| **JAL / JALR** | Target PC computed in EX stage; IF/ID pipeline registers flushed |

---

## FPGA Platforms

| Feature | ZedBoard | Genesys 2 |
|---|---|---|
| **Device** | Xilinx Zynq-7000 XC7Z020 | Xilinx Kintex-7 XC7K325T |
| **Logic Cells** | 85,000 | 326,080 |
| **Block RAM** | 560 KB | 16 MB |
| **Onboard Clock** | 100 MHz | 200 MHz |
| **Used by** | All three designs | Pipeline RV32IMC |

### Board Resources Used
- Onboard system clock
- User push-button for synchronous reset
- User LEDs for live debug output

---

## Tools & Prerequisites

| Tool | Version / Notes |
|---|---|
| **Xilinx Vivado** | 2016.x or later (Design Suite) |
| **FPGA Boards** | Zedboard Zynq 7000, Kintex-7 Genesys2 |

---

## Getting Started

### 1. Open Vivado and Create a Project

1. Launch **Xilinx Vivado**.
2. Click **Create Project** → choose a project name and directory.
3. Select **RTL Project** and check *Do not specify sources at this time*.
4. Choose your target FPGA part:
   - ZedBoard: `xc7z020clg484-1`
   - Genesys 2: `xc7k325tffg900-2`

### 2. Add Sources

1. Go to **Add Sources** → **Add or Create Design Sources**.
2. Add all `.v` files from the relevant folder (e.g., `Single Cycle RV32I/Sources/`).
3. Go to **Add Sources** → **Add or Create Simulation Sources**.
4. Add the testbench `.v` file.
5. Go to **Add Sources** → **Add or Create Constraints**.
6. Add the `.xdc` constraint file for your target board.


### Running Behavioral Simulation

1. In Vivado, go to **Flow Navigator** → **Simulation** → **Run Behavioral Simulation**.
2. The waveform viewer opens automatically.
3. Add signals of interest to the waveform window (PC, registers, ALU output, memory data).
4. Click **Run All** to execute the full testbench.

### What to Observe

| Signal | Description |
|---|---|
| `PC_Current` | Instruction address being executed |
| `RegFile[x1]...[x31]` | Register values after each instruction |
| `ALU_Result` | Output of ALU per cycle |
| `DataMem_Out` | Data read from memory on LW |
| `cycle_count` | Performance counter — total clock cycles |
| `instr_count` | Performance counter — retired instructions |

### Example Simulation Output

```
=== Checkpoint 1 ===
x1 = 5
x2 = 3

=== Checkpoint 2 ===
x3 = 8       // x3 = x1 + x2

=== Checkpoint 3 ===
x4 = 2       // x4 = x2 - x1 ... (expected: 3 - 5 = -2 in 2's complement)
Memory[0] = 8
```

---

## FPGA Implementation

### Synthesis and Implementation Steps

1. In Vivado, run **Synthesis** (`Flow Navigator` → `Run Synthesis`).
2. Run **Implementation** (`Flow Navigator` → `Run Implementation`).
3. Review the **Timing Summary** — ensure no setup/hold violations (WNS ≥ 0).
4. Review **Utilization Report** for LUT, FF, BRAM usage.
5. Generate **Bitstream** (`Flow Navigator` → `Generate Bitstream`).
6. Connect your FPGA board via USB-JTAG.
7. Open **Hardware Manager** → **Program Device**.

### Clock Divider

The processor runs at the full board clock frequency (100/200 MHz) internally, but to make instruction execution visible on LEDs, a **clock divider** is instantiated to produce a human-visible heartbeat signal:

```verilog
// Example: divide 100 MHz down to ~1 Hz for LED visualization
reg [26:0] clk_div_counter;
reg        clk_slow;

always @(posedge clk) begin
    if (clk_div_counter == 27'd99_999_999) begin
        clk_div_counter <= 0;
        clk_slow <= ~clk_slow;
    end else begin
        clk_div_counter <= clk_div_counter + 1;
    end
end
```

## Project Highlights

- Complete RV32I ISA implementation from scratch in Verilog HDL
- Progressive design: single-cycle → 5-stage pipeline → RV32IMC
- Full hazard handling: data forwarding, load-use stall, branch flush
- Performance counters for CPI measurement and analysis
- Verified on real FPGA hardware (ZedBoard and Genesys 2)
- Clean, modular Verilog code organized by pipeline stage
- Constraint files and testbenches included for every design

---
