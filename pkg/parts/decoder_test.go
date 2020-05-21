package parts

import (
	"fmt"
	"math/rand"
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
)

var max_decoder_n_tests int = 4

func TestDecoderMaker(t *testing.T) {
	for n := 2; n <= max_decoder_n_tests; n++ {
		bis := g.NewBusN(n)
		bos := g.NewBusN(1 << n)
		NewDecoder(bis, bos)

		max := 1 << n
		for j := 0; j < max; j++ {
			x := j
			for _, r := range [2]bool{false, true} {
				if r {
					x = rand.Intn(max)
				}

				res := 1 << ((max - 1) - x)
				testname := fmt.Sprintf("DECODER%d(%d)=%d", n, x, res)
				t.Run(testname, func(t *testing.T) {
					bis.SetPower(x)
					tm.Is(t, bos.GetPower(), res, testname)
				})
			}
		}
	}
}

func TestDecoderErrors(t *testing.T) {
	tm.TPanic(t, func() {
		NewDecoder(g.NewBusN(1), g.NewBusN(2))
	})
	tm.TPanic(t, func() {
		NewDecoder(g.NewBusN(2), g.NewBusN(8))
	})
}
