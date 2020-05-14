package parts

import (
	"testing"

	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

func TestMemory(t *testing.T) {
	wi := g.NewWire()
	ws := g.NewWire()
	wo := g.NewWire()
	NewMemory(wi, ws, wo)

	if wo.GetPower() {
		t.Errorf("M(i:0,s:0)=o:0, s=off, o should be initialized at 0")
	}
	ws.SetPower(true)
	if wo.GetPower() {
		t.Errorf("M(i:0,s:1)=o:0, s=on, o should equal i")
	}
	wi.SetPower(true)

	if !wo.GetPower() {
		t.Errorf("M(i:1,s:1)=o:1, s=on, o should equal i")
	}
	ws.SetPower(false)
	if !wo.GetPower() {
		t.Errorf("M(i:1,s:0)=o:1, s=off, o still equal to i")
	}
	wi.SetPower(false)
	if !wo.GetPower() {
		t.Errorf("M(i:0,s:0)=o:1, s=off and i=off, o stays at 1")
	}
	ws.SetPower(true)
	if wo.GetPower() {
		t.Errorf("M(i:0,s:1)=o:0, s=on, o goes to 0 since i is 0")
	}
	ws.SetPower(false)
	if wo.GetPower() {
		t.Errorf("M(i:0,s:0)=o:0, s=off, i and o stay at 0")
	}
	wi.SetPower(true)
	if wo.GetPower() {
		t.Errorf("M(i:1,s:0)=o:0, s=off, o stays at 0")
	}

	// More specific cases...
	wi = g.NewWire()
	ws = g.NewWire()
	wo = g.NewWire()
	m := NewMemory(wi, ws, wo)

	if wo.GetPower() {
		t.Errorf("M(i:0,[0],s:0)=o:0")
	}
	if m.GetM() {
		t.Errorf("M(i:0,[0],s:0)=o:0")
	}
	ws.SetPower(true)
	if wo.GetPower() {
		t.Errorf("M(i:0,[0],s:0)=o:0")
	}
	if m.GetM() {
		t.Errorf("M(i:0,[0],s:0)=o:0")
	}
	ws.SetPower(false)
	wi.SetPower(true)
	if wo.GetPower() {
		t.Errorf("M(i:0,[0],s:0)=o:0")
	}
	if m.GetM() {
		t.Errorf("M(i:i,[0],s:0)=o:0")
	}

	wi = g.NewWire()
	ws = g.NewWire()
	wo = g.NewWire()
	m = NewMemory(wi, ws, wo)

	if wo.GetPower() {
		t.Errorf("M(i:0,[0],s:0)=o:0")
	}
	if m.GetM() {
		t.Errorf("M(i:0,[0],s:0)=o:0")
	}
	ws.SetPower(true)
	if wo.GetPower() {
		t.Errorf("M(i:0,[0],s:0)=o:0")
	}
	if m.GetM() {
		t.Errorf("M(i:0,[0],s:0)=o:0")
	}

	wi.SetPower(true)
	ws.SetPower(false)
	if !wo.GetPower() {
		t.Errorf("M(i:1,[1],s:0)=o:1")
	}
	if !m.GetM() {
		t.Errorf("M(i:1,[1],s:0)=o:1")
	}
}
