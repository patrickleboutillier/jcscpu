#!/bin/bash

for f in tb/comb/*.v tb/comb/out/*.v ; do
	[ -f $f ] || continue
	iverilog -o tb/comb/out/`basename $f .v`.vvp src/comb/*.v $f || exit 1
done
