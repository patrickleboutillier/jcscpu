package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	c "github.com/patrickleboutillier/jcscpu/pkg/computer"
)

func main() {
	log.SetFlags(0)
	var bits = flag.Uint("bits", 8, "Number of bits in the architecture (valid values are between 8 and 32 inclusively)")
	var maxinsts = flag.Uint("maxinsts", 0, "Maximum number of instructions the computer is allowed to process before halting")
	var debugonstop = flag.Bool("debugonstop", false, "Print a debug status at the end of the program")
	flag.Parse()
	if *bits < 8 || *bits > 32 {
		flag.Usage()
		os.Exit(1)
	}

	C := c.NewComputer(int(*bits), int(*maxinsts))
	insts := ParseInstructions(int(*bits))
	if len(insts) == 0 {
		log.Fatal("No valid instructions provided!")
	}

	// Should be Boot...
	//C.BB.Run(insts)
	C.BootAndRun(insts)
	if *debugonstop {
		C.BB.Debug()
	}
}

func ParseInstructions(bits int) []int {
	ret := make([]int, 0, 64)

	scanner := bufio.NewScanner(os.Stdin)
	nbline := 0
	for scanner.Scan() {
		nbline++
		line := strings.TrimSpace(scanner.Text())
		if len(line) == 0 || line[0] == '#' {
			continue
		}
		var inst int
		_, err := fmt.Sscanf(line, "%b", &inst)
		if err != nil {
			log.Fatalf("Error parsing line %d: %v", nbline, err)
		}
		if inst >= (1 << bits) {
			log.Fatalf("Instruction '%b' to large for architecture size (%d bits) at line %d", inst, bits, nbline)
		}

		ret = append(ret, inst)
	}

	if err := scanner.Err(); err != nil {
		log.Fatalf("Error parsing line %d: %v", nbline, err)
	}

	return ret
}
