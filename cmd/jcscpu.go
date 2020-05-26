package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
	c "github.com/patrickleboutillier/jcscpu/pkg/computer"
)

func main() {
	log.SetFlags(0)
	var bits = flag.Uint("bits", 8, "Number of bits in the architecture (valid values are between 8 and 32 inclusively)")
	flag.Parse()
	if *bits < 8 || *bits > 32 {
		flag.Usage()
		os.Exit(1)
	}

	C := c.NewComputer(int(*bits))
	insts := ParseInstructions()
	if len(insts) == 0 {
		log.Fatal("No valid instructions provided!")
	}

	// Should be Boot...
	C.BB.Run(insts)
}

func ParseInstructions() []int {
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
		if inst > a.GetMaxByteValue() {
			log.Fatalf("Instruction '%b' to large for architecture size at line %d", inst, nbline)
		}

		ret = append(ret, inst)
	}

	if err := scanner.Err(); err != nil {
		log.Fatalf("Error parsing line %d: %v", nbline, err)
	}

	return ret
}
