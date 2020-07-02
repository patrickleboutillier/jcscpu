#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' 

for f in tb/out/*.vvp ; do
	g=${f%vp}
	printf "Running %-35s " "$g(vp):"
	vvp $f | tee tb/out/vvp.out
	if grep -q '!!!' tb/out/vvp.out ; then
		echo -e "  ${RED}ERRORS DETECTED!${NC}"
	fi
done
