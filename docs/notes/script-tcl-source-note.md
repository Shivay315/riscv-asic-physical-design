# Supplied `script.tcl` Note

The uploaded `script.tcl` file is not a Cadence execution script. It is an engineering note describing a RISC-V `data_memory` synthesis/elaboration issue, its suspected causes, and proposed SRAM/BRAM approaches.

It is retained here as a documentation note rather than being placed under `scripts/`, because labeling it as a runnable TCL implementation script would be inaccurate.

```text
# Script for Cadence RTL Compiler Synthesis

set_attribute lib_search_path {../lib/max/}
set_attribute hdl_search_path {../Verilog/}
set_attribute library [list slow.lib]
set_attribute information_level 6

set myFiles [list file_name.v]
set basename seu_test_block;
set myClk clk;
set myPeriod_ps 10000;
set myInDelay_ns 0.1;
set myOutDelay_ns 0.1;
set runname synthesis_report;


#*********************************************
# BELOW HERE SHOULD NOT BE CHANGED
#*********************************************

# Analysis and Elaborate the HDL Files
read_HDL -sv ${myFiles}
elaborate ${basename}

# Apply constraints and generate clocks
set clock [define_clock -period ${myPeriod_ps} -name ${myClk} [clock_ports]]
external_delay -input $myInDelay_ns -clock ${myClk} [find /-port ports_in/*]
external_delay -output $myOutDelay_ns -clock #{myClk} [find / -port ports_in/*]

# Check that the design is OK so far
check_design -unresolved
report timing -lint

#Synthesize the design to the target library
syn_gen

#Write out the reports
report timing > ${basename}_${runname}_timing.rep
report gates > ${basename}_${runname}_cell.rep
report power > ${basename}_${runname}.sdc
gui_show
```
