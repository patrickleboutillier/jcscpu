package parts

import (
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
BYTE
*/
type Byte struct {
	is, os *g.Bus
	s      *g.Wire
}

func NewByte(bis *g.Bus, ws *g.Wire, bos *g.Bus) *Byte {
	g.CheckBusSizes(bis, bos, "Byte input and output buses")
	n := bis.GetSize()
	this := &Byte{bis, bos, ws}
	for j := 0; j < n; j++ {
		NewMemory(bis.GetWire(j), ws, bos.GetWire(j))
	}
	return this
}
