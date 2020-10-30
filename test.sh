#!/bin/bash

while /bin/true ; do
	rm RAM_CPU.txt RAM_SIM.txt
	./genprog.pl 2>CASE.txt | ./jcscpu > RAM_CPU.txt
	if [ -s RAM_SIM.txt -a -s RAM_CPU.txt ] ; then
		if ! diff RAM_SIM.txt RAM_CPU.txt ; then
			cat CASE.txt 
			break ;
		fi
	else 
		cat CASE.txt 
		break 
	fi
done


