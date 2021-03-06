package parts

import (
	"fmt"
	"math/rand"
	"testing"

	t8 "github.com/patrickleboutillier/jcscpu/internal/testarch"
	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

var nb_enabler_tests int = 1024

func TestEnablerBasic(t *testing.T) {
	bis := g.NewBus(t8.GetArchBits())
	we := g.NewWire()
	bos := g.NewBus(t8.GetArchBits())
	NewEnabler(bis, we, bos)

	bis.GetBit(7).SetPower(true)
	tm.Is(t, bos.GetPower(), 0b00000000, "E(i:10000000,e:0)=o:00000000, e=off, no output")
	bis.GetBit(3).SetPower(true)
	tm.Is(t, bos.GetPower(), 0b00000000, "E(i:10001000,e:0)=o:00000000, e=off, no output")
	we.SetPower(true)
	tm.Is(t, bos.GetPower(), 0b10001000, "E(i:10001000,e:1)=o:10001000, e=on, i goes through")
	bis.GetBit(3).SetPower(false)
	tm.Is(t, bos.GetPower(), 0b10000000, "E(i:10000000,e:1)=o:10000000, e=on, i goes through")
	bis.GetBit(7).SetPower(false)
	tm.Is(t, bos.GetPower(), 0b00000000, "E(i:00000000,e:1)=o:00000000, e=on, i goes through")
	bis.GetBit(0).SetPower(true)
	tm.Is(t, bos.GetPower(), 0b00000001, "E(i:00000001,e:1)=o:00000001, e=on, i goes through")
	we.SetPower(false)
	tm.Is(t, bos.GetPower(), 0b00000000, "E(i:00000001,e:0)=o:00000000, e=off, no output")
}

func TestEnablerMaker(t *testing.T) {
	bis := g.NewBus(t8.GetArchBits())
	we := g.NewWire()
	bos := g.NewBus(t8.GetArchBits())
	NewEnabler(bis, we, bos)

	for j := 0; j < nb_enabler_tests; j++ {
		x := j % (1 << bis.GetSize())
		for _, r := range [2]bool{false, true} {
			if r {
				x = rand.Intn(bis.GetMaxPower())
			}

			testname := fmt.Sprintf("ENABLER(%d, 1)=%d", x, x)
			t.Run(testname, func(t *testing.T) {
				we.SetPower(false)
				bis.SetPower(x)
				we.SetPower(true)
				tm.Is(t, bos.GetPower(), x, testname)
			})
		}
	}
}
