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
	this := &Byte{bis, bos, ws}
	for j := 0; j < 8; j++ {
		NewMemory(bis.GetWire(j), ws, bos.GetWire(j))
	}
	return this
}
