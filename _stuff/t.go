package main

import (
	"fmt"
	"log"
	"os"
	"runtime/pprof"
	"time"

	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
	p "github.com/patrickleboutillier/jcscpu/pkg/parts"
)

func main() {
	f, err := os.Create("./cpu.prof")
	if err != nil {
		log.Fatal(err)
	}
	pprof.StartCPUProfile(f)
	defer pprof.StopCPUProfile()

	a.SetArchBits(16)

	ba := g.NewBus()
	wsa := g.NewWire()
	bio := g.NewBus()
	ws := g.NewWire()
	we := g.NewWire()

	start := time.Now()
	p.NewRAM(ba, wsa, bio, ws, we)
	end := time.Now()
	elapsed := end.Sub(start)
	fmt.Printf("NbNANDs: %d, NbWires: %d\n", g.NbNANDs, g.NbWires)
	fmt.Printf("Duration: %dms\n", elapsed/1000000)
}
