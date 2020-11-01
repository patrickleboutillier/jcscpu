#!/bin/bash

quit=n
trap 'quit=y' INT


done_error(){
	[ "$quit" == 'n' ] && cat CASE.txt 
}


nb=0
while /bin/true ; do
	# rm -f RAM_CPU.txt RAM_SIM.txt
	./genprog.pl 2>CASE.txt | ./jcscpu > RAM_CPU.txt
	# grep "^DEBUG: RAM" OUT_CPU.txt > RAM_CPU.txt
	# grep -v "^DEBUG: RAM" OUT_CPU.txt >> CASE.txt
	if ! cmp RAM_SIM.txt RAM_CPU.txt > /dev/null ; then
		if [ -s RAM_SIM.txt -a -s RAM_CPU.txt ] ; then
			diff RAM_SIM.txt RAM_CPU.txt 
			done_error
			break 
		else 
			done_error
			break 
		fi
	fi
	nb=$((nb + 1))
done

echo
echo $nb tests run

