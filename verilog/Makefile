
clean:
	rm -f tb/comb/out/* tb/seq/out/*

test: clean
	./tb/comb/tools/gentests.sh
	./tb/comb/tools/buildtests.sh
	./tb/comb/tools/runtests.sh

	#./tb/seq/tools/gentests.sh
	#./tb/seq/tools/buildtests.sh
	#./tb/seq/tools/runtests.sh
