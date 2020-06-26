#!/bin/bash

for f in tb/*.v tb/out/*.v ; do 
	iverilog -o tb/out/`basename $f .v`.vvp src/*.v $f || exit 1
done
