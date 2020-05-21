package parts

import (
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

/*
ENABLER
*/
type Enabler struct {
	is, os *g.Bus
	e      *g.Wire
}

func NewEnabler(bis *g.Bus, we *g.Wire, bos *g.Bus) *Enabler {
	g.CheckBusSizes(bis, bos, "Enabler input and output buses")
	n := bis.GetSize()
	this := &Enabler{bis, bos, we}
	for j := 0; j < n; j++ {
		g.NewAND(bis.GetWire(j), we, bos.GetWire(j))
	}
	return this
}
