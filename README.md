# HOMEMADE 5-STAGE-PIPELINE RISC-V
![RV32-1](https://github.com/user-attachments/assets/334058cc-4280-4ac5-83b5-097ff429da1a)

```
iverilog -g2012 -o sim.vvp src/*.sv subsystems_tb/IF_ID_path_tb.sv 
vvp sim.vvp
```

```
iverilog -g2012 -o sim.vvp \
  src/PC_counter.sv \
  src/PC_plus_4_counter.sv \
  src/Instr_Mem.sv \
  src/Reg_File.sv \
  src/Control_Unit.sv \
  src/ALU_Decoder.sv \
  src/Sign_Ext.sv \
  src/PC_Target.sv \
  src/Mux_PCTarget_to_PC.sv \
  src/MuxA.sv \
  src/Mux_Reg_to_B.sv \
  src/MuxB.sv \
  src/ALU.sv \
  src/J_and_B.sv \
  src/Reg_IF_ID.sv \
  src/Reg_ID_EX.sv \
  subsystems_tb/IF_to_EX_path.sv \
  subsystems_tb/IF_to_EX_path_tb.sv
```
