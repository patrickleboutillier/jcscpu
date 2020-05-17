package parts

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

func TestByte(t *testing.T) {
	bis := g.NewBus()
	ws := g.NewWire()
	bos := g.NewBus()
	NewByte(bis, ws, bos)

	ws.SetPower(true)
	tm.Ok(t, bos.IsPower("00000000"), "B(i:00000000,s:1)=o:00000000, s=on, i should equal o")
	bis.GetBit(7).SetPower(true)
	if !bos.IsPower("10000000") {
		t.Errorf("B(i:10000000,s:1)=o:10000000, s=on, i should equal o")
	}
	bis.GetBit(3).SetPower(true)
	if !bos.IsPower("10001000") {
		t.Errorf("B(i:10001000,s:1)=o:10001000, s=on, i should equal o")
	}
	ws.SetPower(false)
	if !bos.IsPower("10001000") {
		t.Errorf("B(i:10001000,s:0)=o:10001000, s=off, i still equal o")
	}
	bis.GetBit(7).SetPower(false)
	if !bos.IsPower("10001000") {
		t.Errorf("B(i:00001000,s:0)=o:10001000, s=off, o stays at 10001000")
	}
	ws.SetPower(true)
	if !bos.IsPower("00001000") {
		t.Errorf("B(i:00001000,s:1)=o:00001000, s=on, o goes to 00001000 since i is 00001000")
	}
	ws.SetPower(false)
	if !bos.IsPower("00001000") {
		t.Errorf("B(i:00001000,s:0)=o:00001000, s=on, i and o stay at 00001000")
	}
	bis.GetBit(2).SetPower(true)
	bis.GetBit(1).SetPower(true)
	bis.GetBit(0).SetPower(true)
	if !bos.IsPower("00001000") {
		t.Errorf("B(i:00001111,s:0)=o:00001000, s=off, o stays at 00001000")
	}
	ws.SetPower(true)
	if !bos.IsPower("00001111") {
		t.Errorf("B(i:00001111,s:1)=o:00001111, s=on, o goes to i (00001111)")
	}
}
