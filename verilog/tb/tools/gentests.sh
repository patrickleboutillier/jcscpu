#!/bin/bash

for f in tb/tv/*.tv ; do
	g=`basename $f .tv`
	{
		echo "module test() ;"
		echo
		cat $f | grep ^// | sed 's/^\/\///'
		echo ' `define TVFILE "'$f'"'
		NBLINES=$(grep ^[01] $f | wc -l)
		echo ' `define NBLINES '$NBLINES
		cat tb/tools/template.v
	} > tb/out/${g}.v
done
