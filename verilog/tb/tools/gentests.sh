#!/bin/bash

if [ -n "$VERBOSE" ] ; then
	VERBOSE=1
else 
	VERBOSE=0
fi

for f in tb/tv/*.tv ; do
	g=`basename $f .tv`
	{
		echo "module test() ;"
		echo
		echo ' reg sclk, reset ;'
		echo ' `define VERBOSE '$VERBOSE
		cat $f | grep ^// | sed 's/^\/\///'
		echo ' `define TVFILE "'$f'"'
		NBLINES=$(grep ^[01xz] $f | wc -l)
		echo ' `define NBLINES '$NBLINES
		cat tb/tools/template.v
	} > tb/out/${g}.v
done
