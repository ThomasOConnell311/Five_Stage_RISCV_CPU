# Five-Stage RISC-V CPU

A 32-bit, five-stage pipelined RISC-V processor implemented in SystemVerilog and tested using AMD/Xilinx Vivado. The design includes pipeline forwarding, hazard detection, load-use stalling, branch handling, separate instruction and data memories, and a Basys 3 FPGA top-level interface.

# Features

- 32-bit RISC-V datapath
- Five pipeline stages:
  - Instruction Fetch (IF)
  - Instruction Decode (ID)
  - Execute (EX)
  - Memory Access (MEM)
  - Write Back (WB)
- EX/MEM and MEM/WB forwarding
- Load-use hazard detection and pipeline stalling
- Branch evaluation and pipeline control
- Register file with 32 general-purpose registers
- Separate instruction and data memories
- Self-checking SystemVerilog testbench
- Basys 3 FPGA wrapper and seven-segment display driver

# Instruction Support

The processor implements a project-specific subset of the RV32I instruction set, including:

- Register-register arithmetic and logical instructions
- Immediate arithmetic and logical instructions
- Load and store instructions
- Conditional branch instructions
- Jump instructions
- Upper-immediate instructions

This project is intended as an educational processor implementation rather than a fully RV32I-compliant commercial core.

# Pipeline Architecture

| Stage | Function |
|---|---|
| IF | Fetches the next instruction from instruction memory |
| ID | Decodes the instruction and reads source registers |
| EX | Performs ALU operations, branch evaluation, and address calculation |
| MEM | Reads from or writes to data memory |
| WB | Writes results back to the register file |

The forwarding unit resolves many data dependencies by selecting results from later pipeline stages. The hazard unit detects load-use dependencies and stalls the pipeline when forwarding alone cannot resolve the dependency.

# Main RTL Modules

| Module | Purpose |
|---|---|
| `riscv_pipeline_cpu.sv` | Top-level pipelined CPU core |
| `control_unit.sv` | Main instruction decoder and control-signal generation |
| `reg_file.sv` | 32-register integer register file |
| `imm_gen.sv` | RISC-V immediate-value generation |
| `hazard_unit.sv` | Load-use hazard detection and stall control |
| `forwarding_unit.sv` | EX/MEM and MEM/WB forwarding control |
| `alu_control.sv` | Selects the required ALU operation |
| `alu.sv` | Arithmetic and logical execution unit |
| `branch_unit.sv` | Branch-condition evaluation |
| `instr_mem.sv` | Instruction memory |
| `data_mem.sv` | Data memory |
| `riscv_defs.sv` | Shared processor definitions |
| `basys3_top.sv` | Basys 3 FPGA top-level wrapper |
| `seven_seg_driver.sv` | Seven-segment display controller |
| `tb_riscv_pipeline_cpu.sv` | Behavioral simulation testbench |

# Verification

The processor was verified with a SystemVerilog testbench in Vivado XSim. The test program exercises arithmetic operations, data dependencies, memory access, forwarding, and pipeline control.

Expected simulation results:

```text
x1 = 5
x2 = 10
x3 = 15
x4 = 15
x5 = 16
mem[0] = 15
PASS: pipelined CPU demo program worked.
```

The self-checking testbench reports a failure if the final architectural state does not match the expected result.

# Vivado Configuration

- Design top module: `basys3_top`
- Simulation top module: `tb_riscv_pipeline_cpu`
- Constraint file: `basys3.xdc`
- Target board: Digilent Basys 3
- HDL: SystemVerilog
- Simulator: Vivado XSim

# Running the Simulation

1. Clone or download this repository.
2. Open `riscv_cpu.xpr` in Vivado.
3. Select **Run Simulation**.
4. Select **Run Behavioral Simulation**.
5. Run the simulation for at least 425 ns.
6. Check the Tcl Console for the register values and the PASS message.

# Building for the Basys 3

1. Open `riscv_cpu.xpr`.
2. Confirm that `basys3_top` is selected as the design top.
3. Run synthesis.
4. Run implementation.
5. Generate the bitstream.
6. Connect the Basys 3 and program it through Vivado Hardware Manager.

# Project Status

The processor successfully completes its demonstration program in behavioral simulation and has been synthesized and programmed onto a Basys 3 FPGA.