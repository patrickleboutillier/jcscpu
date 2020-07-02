#!/bin/bash

for f in tb/out/*.v ; do
	[ -f $f ] || continue
	iverilog -o tb/out/`basename $f .v`.vvp src/lib/*.v $f || exit 1
done
