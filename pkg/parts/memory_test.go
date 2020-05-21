package parts

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

func TestMemory(t *testing.T) {
	wi := g.NewWire()
	ws := g.NewWire()
	wo := g.NewWire()
	NewMemory(wi, ws, wo)

	tm.Is(t, wo.GetPower(), false, "M(i:0,s:0)=o:0, s=off, o should be initialized at 0")
	ws.SetPower(true)
	tm.Is(t, wo.GetPower(), false, "M(i:0,s:1)=o:0, s=on, o should equal i")
	wi.SetPower(true)

	tm.Is(t, wo.GetPower(), true, "M(i:1,s:1)=o:1, s=on, o should equal i")
	ws.SetPower(false)
	tm.Is(t, wo.GetPower(), true, "M(i:1,s:0)=o:1, s=off, o still equal to i")
	wi.SetPower(false)
	tm.Is(t, wo.GetPower(), true, "M(i:0,s:0)=o:1, s=off and i=off, o stays at 1")
	ws.SetPower(true)
	tm.Is(t, wo.GetPower(), false, "M(i:0,s:1)=o:0, s=on, o goes to 0 since i is 0")
	ws.SetPower(false)
	tm.Is(t, wo.GetPower(), false, "M(i:0,s:0)=o:0, s=off, i and o stay at 0")
	wi.SetPower(true)
	tm.Is(t, wo.GetPower(), false, "M(i:1,s:0)=o:0, s=off, o stays at 0")

	// More specific cases...
	wi = g.NewWire()
	ws = g.NewWire()
	wo = g.NewWire()
	m := NewMemory(wi, ws, wo)

	tm.Is(t, wo.GetPower(), false, "M(i:0,[0],s:0)=o:0")
	tm.Is(t, m.GetM(), false, "M(i:0,[0],s:0)=o:0")
	ws.SetPower(true)
	tm.Is(t, wo.GetPower(), false, "M(i:0,[0],s:0)=o:0")
	tm.Is(t, m.GetM(), false, "M(i:0,[0],s:0)=o:0")
	ws.SetPower(false)
	wi.SetPower(true)
	tm.Is(t, wo.GetPower(), false, "M(i:0,[0],s:0)=o:0")
	tm.Is(t, m.GetM(), false, "M(i:i,[0],s:0)=o:0")

	wi = g.NewWire()
	ws = g.NewWire()
	wo = g.NewWire()
	m = NewMemory(wi, ws, wo)

	tm.Is(t, wo.GetPower(), false, "M(i:0,[0],s:0)=o:0")
	tm.Is(t, m.GetM(), false, "M(i:0,[0],s:0)=o:0")
	ws.SetPower(true)
	tm.Is(t, wo.GetPower(), false, "M(i:0,[0],s:0)=o:0")
	tm.Is(t, m.GetM(), false, "M(i:0,[0],s:0)=o:0")

	wi.SetPower(true)
	ws.SetPower(false)
	tm.Is(t, wo.GetPower(), true, "M(i:1,[1],s:0)=o:1")
	tm.Is(t, m.GetM(), true, "M(i:1,[1],s:0)=o:1")
}
