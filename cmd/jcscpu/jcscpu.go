package main

import (
	"flag"
	"log"
	"os"

	j "github.com/patrickleboutillier/jcscpu/internal/jcscpu"
	c "github.com/patrickleboutillier/jcscpu/pkg/computer"
)

func main() {
	log.SetFlags(0)
	var bits = flag.Uint("bits", 8, "Number of bits in the architecture (valid values are between 8 and 24 inclusively)")
	var maxinsts = flag.Uint("maxinsts", 0, "Maximum number of instructions the computer is allowed to process before halting")
	var debugonstop = flag.Bool("debugonstop", false, "Print a debug status at the end of the program")
	flag.Parse()

	if *bits < 8 || *bits > 24 {
		flag.Usage()
		os.Exit(1)
	}

	var insts []int
	var err error
	if insts, err = j.ParseTextInstructions(os.Stdin); err != nil {
		log.Fatal(err)
	}

	C := c.NewComputer(int(*bits), int(*maxinsts))

	if err := C.BootAndRun(insts); err != nil {
		log.Fatal(err)
	}

	if *debugonstop {
		C.BB.Debug()
	}
}
