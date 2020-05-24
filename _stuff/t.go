package main

import (
	"fmt"
	"log"
	"os"
	"runtime"
	"runtime/pprof"
	"time"

	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
	p "github.com/patrickleboutillier/jcscpu/pkg/parts"
)

func main() {
	fc, err := os.Create("./cpu.prof")
	if err != nil {
		log.Fatal(err)
	}
	fm, err := os.Create("./mem.prof")
	if err != nil {
		log.Fatal(err)
	}

	pprof.StartCPUProfile(fc)
	defer pprof.StopCPUProfile()

	fmt.Printf("ArchBits: %d\n", a.GetArchBits())

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

	defer fm.Close()
	runtime.GC() // get up-to-date statistics
	pprof.WriteHeapProfile(fm)
}
