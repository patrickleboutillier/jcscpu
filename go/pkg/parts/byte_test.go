package parts

import (
	"testing"

	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

func TestByte(t *testing.T) {
	bis := g.NewBus8()
	ws := g.NewWire()
	bos := g.NewBus8()
	NewByte(bis, ws, bos)

	ws.SetPower(true)
	if bos.GetPower() != "00000000" {
		t.Errorf("B(i:00000000,s:1)=o:00000000, s=on, i should equal o")
	}
	bis.GetWire(0).SetPower(true)
	if bos.GetPower() != "10000000" {
		t.Errorf("B(i:10001000,s:1)=o:10001000, s=on, i should equal o")
	}
	bis.GetWire(4).SetPower(true)
	if bos.GetPower() != "10001000" {
		t.Errorf("B(i:10001000,s:1)=o:10001000, s=on, i should equal o")
	}
	ws.SetPower(false)
	if bos.GetPower() != "10001000" {
		t.Errorf("B(i:10001000,s:0)=o:10001000, s=off, i still equal o")
	}
	bis.GetWire(0).SetPower(false)
	if bos.GetPower() != "10001000" {
		t.Errorf("B(i:00001000,s:0)=o:10001000, s=off, o stays at 10001000")
	}
	ws.SetPower(true)
	if bos.GetPower() != "00001000" {
		t.Errorf("B(i:00001000,s:1)=o:00001000, s=on, o goes to 00001000 since i is 00001000")
	}
	ws.SetPower(false)
	if bos.GetPower() != "00001000" {
		t.Errorf("B(i:00001000,s:0)=o:00001000, s=on, i and o stay at 00001000")
	}
	bis.GetWire(5).SetPower(true)
	bis.GetWire(6).SetPower(true)
	bis.GetWire(7).SetPower(true)
	if bos.GetPower() != "00001000" {
		t.Errorf("B(i:00001111,s:0)=o:00001000, s=off, o stays at 00001000")
	}
	ws.SetPower(true)
	if bos.GetPower() != "00001111" {
		t.Errorf("B(i:00001111,s:1)=o:00001111, s=on, o goes to i (00001111)")
	}
}
