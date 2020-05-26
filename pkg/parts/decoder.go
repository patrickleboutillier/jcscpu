package parts

import (
	"log"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

/*
DECODER
*/
type Decoder struct {
	is, os *g.Bus
}

func NewDecoder(bis *g.Bus, bos *g.Bus) *Decoder {
	ni := bis.GetSize()
	no := bos.GetSize()
	if ni < 2 {
		log.Panicf("Invalid Decoder number of inputs %d", ni)
	}
	if (1 << ni) != no {
		log.Panicf("Invalid number of wires in Decoder output bus (%d) (2**%d is %d)", no, ni, (1 << ni))
	}

	this := &Decoder{bis, bos}

	wmap := make([][2]*g.Wire, ni, ni)
	for j := 0; j < ni; j++ {
		w1 := bis.GetWire(j)
		w0 := g.NewWire()
		g.NewNOT(w1, w0)

		// Now we want to classify the wires w1 and w0 and store them in a map to be able to
		// hook them up to the ANDn gates later.
		wmap[j][0] = w0
		wmap[j][1] = w1
	}

	// Temporary bus used to convert int power value to a string in order to build the path.
	tbus := g.NewBus(ni)
	for j := 0; j < no; j++ {
		tbus.SetPower(j)
		// What is the "label" (x/x/x...) of this ANDn gate?
		label := tbus.String()
		path := make([]int, ni, ni)
		for k, c := range label {
			if c == '0' {
				path[k] = 0
			} else {
				path[k] = 1
			}
		}

		// Now we must hook up the ni inputs.
		wos := make([]*g.Wire, ni, ni)
		for k := 0; k < ni; k++ {
			idx := path[k]
			// Connect the kth input of our ANDn gate to the proper output wire in the map.
			wos[k] = wmap[k][idx]
		}

		g.NewANDn(g.WrapBus(wos), bos.GetWire(j))
	}

	return this
}
