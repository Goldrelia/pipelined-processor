# pipelined-processor

Project by Aurelia Bouliane, Yasmine Drissi, Tayba Jusab and Matthew Liogas.

This project outlines a RISC-V processor with a 5-stage pipeline (Fetch, Decode, Execute, Memory, Writeback) and supports hazard detection.

## How to run a simulation
### 1. Upload Program
In `program.txt`, copy paste binary machine code corresponding to the program to test with. 
### 2. Run testbench in ModelSim
In ModelSim, open the root folder of this repository. Then, run the command `do testbench.tcl` at the bottom of the screen to automatically compile all VHDL files, read `program.txt` into instruction memory, and run the simulation. 
### 3. View results
Results will be generated in the output text files `register_file.txt` and `memory.txt`.
