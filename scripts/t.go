package main

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

func main() {
	b := g.NewBus()
	b.SetPower(0b10101010)
	fmt.Printf("%08b\n", b.GetPower())
}
