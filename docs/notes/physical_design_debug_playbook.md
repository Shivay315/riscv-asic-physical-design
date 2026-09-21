# Physical-Design Debug Playbook (Reconstructed)

This is an interview/reproduction guide reconstructed from the internship report's documented stages and standard Innovus usage. It is **not a transcript of the original SCL command history**.

## Placement / pre-CTS

```tcl
checkDesign -all
checkPlace
report_timing
optDesign -preCTS
```

Typical engineering checks include placement legality, unconstrained paths, high fanout, max transition/capacitance and congestion before CTS.

## CTS

```tcl
ccopt_design
report_timing
```

For CTS debugging, inspect clock-tree skew, insertion delay, clock transition and newly exposed setup/hold paths before moving to route.

## Routing

```tcl
routeDesign
report_timing
verify_drc
verifyConnectivity -type all
```

## Post-route optimization

The SCL report explicitly identifies `optDesign` as the post-route optimization utility.

```tcl
optDesign -postRoute
report_timing
report_area
report_power
verify_drc
verifyConnectivity -type all
```

## DRC debugging

The basic loop is:

```text
verify_drc
   ↓
identify violation class/location
   ↓
inspect routing / geometry / spacing / via condition
   ↓
repair with the appropriate Innovus ECO/route/optimization action
   ↓
verify_drc again
```

The exact violation-specific repair commands depend on the SCL PDK rule deck and were not supplied in the source material; this repository intentionally does not invent a historical command transcript.
