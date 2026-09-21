# Innovus placement / CTS / routing reference flow
# Reconstructed from the SCL report's documented stages.

# placeDesign
# optDesign -preCTS
# ccopt_design
# optDesign -postCTS
# routeDesign
# optDesign -postRoute

# Typical analysis hooks:
# timeDesign -preCTS  > ../../build/innovus/timing_preCTS.rpt
# timeDesign -postCTS > ../../build/innovus/timing_postCTS.rpt
# timeDesign -postRoute > ../../build/innovus/timing_postRoute.rpt
# report_area > ../../build/innovus/area.rpt
# report_power > ../../build/innovus/power.rpt

puts "Placement/CTS/routing reference flow loaded."
