# RISC-V Genus synthesis reference flow
#
# IMPORTANT:
# This is a reconstructed/public reproduction template based on the SCL
# internship report methodology. It is NOT claimed to be the exact SCL script.
# Replace library paths, MMMC setup, RTL list and top-level name with the
# corresponding authorized project environment.

set DESIGN riscv
set RTL_DIR ../../rtl
set OUT_DIR ../../build/genus
file mkdir $OUT_DIR

# Authorized environment-specific setup goes here.
# set_db init_lib_search_path {<SCL_LIB_PATH>}
# set_db library {tsl18fs120_scl_ss_1.lib}
# set_db hdl_search_path [list $RTL_DIR]

read_hdl -sv [glob $RTL_DIR/*.v]
elaborate $DESIGN

# Example constraint section — use the actual project SDC in a licensed flow.
# create_clock -name clk -period <PERIOD_NS> [get_ports clk]
# set_input_delay <DELAY_NS> -clock clk [get_ports ...]
# set_output_delay <DELAY_NS> -clock clk [get_ports ...]

check_design -unresolved
syn_generic
syn_map
syn_opt

report_timing > $OUT_DIR/timing.rpt
report_area   > $OUT_DIR/area.rpt
report_power  > $OUT_DIR/power.rpt

write_hdl > $OUT_DIR/${DESIGN}_synth.v
write_sdc > $OUT_DIR/${DESIGN}.sdc

puts "RISC-V Genus reference flow complete."
