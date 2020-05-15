package parts

import (
	"math/rand"
	"testing"

	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

func TestEnablerBasic(t *testing.T) {
	bis := g.NewBus8()
	we := g.NewWire()
	bos := g.NewBus8()
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
	bis := g.NewBus8()
	we := g.NewWire()
	bos := g.NewBus8()
	NewEnabler(bis, we, bos)

	make_enabler_test := func(t *testing.T, random bool) {
		for j := 0; j < 256; j++ {
			x := j
			if random {
				x = rand.Intn(256)
			}
			we.SetPower(false)
			bis.SetPowerInt(x)
			we.SetPower(true)
			if bos.GetPowerInt() != x {
				t.Errorf("ENABLER(%d, 1)=%d", x, x)
			}
		}
	}

	make_enabler_test(t, false)
	make_enabler_test(t, true)
}
