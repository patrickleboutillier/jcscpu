
clean:
	rm -f tb/out/*

test: clean
	./tb/tools/gentests.sh
	./tb/tools/buildtests.sh
	./tb/tools/runtests.sh
