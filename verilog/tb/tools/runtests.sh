#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

for f in tb/out/*.vvp ; do
	g=${f%vp}
	printf "Running %-30s " "$g(vp):"
	vvp $f | tee /tmp/out 
	if grep -q '!!!' /tmp/out ; then
		echo -e "  ${RED}ERRORS DETECTED!${NC}"
	fi
done
