package parts

import (
	"fmt"
	"math/rand"
	"testing"

	a "github.com/patrickleboutillier/jcscpu/go/pkg/arch"
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

var max_nb_tests int = a.GetMaxByteValue()

func TestEnablerBasic(t *testing.T) {
	bis := g.NewBus()
	we := g.NewWire()
	bos := g.NewBus()
	NewEnabler(bis, we, bos)

	bis.GetWire(0).SetPower(true)
	if bos.GetPower() != "00000000" {
		t.Errorf("B(i:10000000,e:0)=o:00000000, e=off, no output")
	}
	bis.GetWire(4).SetPower(true)
	if bos.GetPower() != "00000000" {
		t.Errorf("B(i:10001000,e:0)=o:00000000, e=off, no output")
	}
	we.SetPower(true)
	if bos.GetPower() != "10001000" {
		t.Errorf("B(i:10001000,e:1)=o:10001000, e=on, i goes through")
	}
	bis.GetWire(4).SetPower(false)
	if bos.GetPower() != "10000000" {
		t.Errorf("B(i:10000000,e:1)=o:10000000, e=on, i goes through")
	}
	bis.GetWire(0).SetPower(false)
	if bos.GetPower() != "00000000" {
		t.Errorf("B(i:00000000,e:1)=o:00000000, e=on, i goes through")
	}
	bis.GetWire(7).SetPower(true)
	if bos.GetPower() != "00000001" {
		t.Errorf("B(i:00000001,e:1)=o:00000001, e=on, i goes through")
	}
	we.SetPower(false)
	if bos.GetPower() != "00000000" {
		t.Errorf("B(i:00000001,e:0)=o:00000000, e=off, no output")
	}
}

func TestEnablerMaker(t *testing.T) {
	bis := g.NewBus()
	we := g.NewWire()
	bos := g.NewBus()
	NewEnabler(bis, we, bos)

	for j := 0; j < max_nb_tests; j++ {
		x := j
		for _, r := range [2]bool{false, true} {
			if r {
				x = rand.Intn(a.GetMaxByteValue())
			}

			testname := fmt.Sprintf("%t,%d", r, x)
			t.Run(testname, func(t *testing.T) {
				we.SetPower(false)
				bis.SetPowerInt(x)
				we.SetPower(true)
				if bos.GetPowerInt() != x {
					t.Errorf("ENABLER(%d, 1)=%d", x, x)
				}
			})
		}
	}
}
