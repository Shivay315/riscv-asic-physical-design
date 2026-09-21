# Innovus physical verification / export reference flow
# Reconstructed/public template — execute only inside an authorized PDK flow.

# verify_drc
# verifyConnectivity -type all
# report_timing
# report_area
# report_power
# saveDesign ../../build/innovus/riscv_final.enc
# streamOut ../../build/innovus/riscv_final.gds -mapFile <LAYER_MAP> -libName <LIB> -units 1000 -mode ALL

puts "Signoff/export reference flow loaded."
