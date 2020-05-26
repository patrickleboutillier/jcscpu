package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"

	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
	b "github.com/patrickleboutillier/jcscpu/pkg/board"
)

func main() {
	log.SetFlags(0)
	var bits = flag.Uint("bits", 8, "Number of bits in the architecture (valid values are between 8 and 32 inclusively)")
	flag.Parse()
	if *bits < 8 || *bits > 32 {
		flag.Usage()
		os.Exit(1)
	}
	a.SetArchBits(int(*bits))

	BB := b.NewBreadboard()
	insts := ParseInstructions()
	if len(insts) == 0 {
		log.Fatal("No valid instructions provided!")
	}

	BB.Run(insts)
}

func ParseInstructions() []int {
	ret := make([]int, 0, 64)

	scanner := bufio.NewScanner(os.Stdin)
	nbline := 0
	for scanner.Scan() {
		nbline++
		line := scanner.Text()
		if line[0] == '#' {
			continue
		}
		var inst int
		n, err := fmt.Sscanf(line, "%b", &inst)
		if err != nil {
			log.Fatal(err)
		}
		if n != 1 || inst < 0 {
			log.Fatal("Invalid instruction '%s' at line %d", line, nbline)
		}
		if inst > a.GetMaxByteValue() {
			log.Fatal("Instruction '%d' to large for architecture size at line %d", inst, nbline)
		}

		ret = append(ret, inst)
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	// Append HALT
	ret = append(ret, b.HALT())

	return ret
}
