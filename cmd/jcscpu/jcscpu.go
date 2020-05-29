package main

import (
	"flag"
	"log"
	"os"

	j "github.com/patrickleboutillier/jcscpu/internal/jcscpu"
)

func main() {
	log.SetFlags(0)
	var bits = flag.Uint("bits", 8, "Number of bits in the architecture (valid values are between 8 and 24 inclusively)")
	var maxinsts = flag.Uint("maxinsts", 0, "Maximum number of instructions the computer is allowed to process before halting")
	var jsonio = flag.Bool("json", false, "Expect JSON input and procuse JSON output")
	var debugonstop = flag.Bool("debugonstop", false, "Print a debug status at the end of the program")
	flag.Parse()

	if *bits < 8 || *bits > 24 {
		flag.Usage()
		os.Exit(1)
	}

	j.RunProgram(*jsonio, int(*bits), int(*maxinsts), *debugonstop, os.Stdin, os.Stdout)
}
