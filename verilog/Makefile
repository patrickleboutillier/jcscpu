
clean:
	rm -f tb/out/* out/*

test: clean
	./tb/tools/gentests.sh
	./tb/tools/buildtests.sh
	./tb/tools/runtests.sh

demo: clean
	iverilog -o out/demo.vvp src/demo/*.v src/demo.v || exit 1
	
