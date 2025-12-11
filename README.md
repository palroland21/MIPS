1. Single-Cycle MIPS Processor (VHDL)
This project involves designing a single-cycle MIPS processor entirely in VHDL.
The processor executes all instructions in a single clock cycle, demonstrating the basics of CPU architecture.
It includes components such as the ALU, registers, instruction memory, and data memory.
Control signals are implemented to coordinate the execution of instructions.
The design was fully simulated to verify correct functionality.
Testbenches were created to validate arithmetic, logic, and memory operations.
The project provides practical insight into instruction execution and timing.
It also demonstrates how hardware description languages like VHDL model digital circuits.
The documentation includes schematics, RTL diagrams, and simulation results.
This project served as a foundational step before moving to more advanced pipelined architectures.

2. Pipelined MIPS Processor (VHDL)
This project extends the single-cycle design into a pipelined MIPS processor implemented in VHDL.
It introduces stages such as IF, ID, EX, MEM, and WB for instruction execution.
Pipeline registers are used to store intermediate results between stages.
Hazard detection and forwarding units handle data and control hazards.
The design improves performance by allowing multiple instructions to execute simultaneously.
Simulations were performed to verify correct instruction flow and hazard handling.
Testbenches include arithmetic, branching, and memory instructions to ensure reliability.
The project demonstrates the trade-offs between complexity and performance in CPU design.
Documentation contains block diagrams, pipeline schematics, and timing analysis.
This work highlights practical knowledge of pipelining concepts and VHDL-based hardware design.
