package parts

import (
	"testing"

	ta "github.com/patrickleboutillier/jcscpu/go/internal/testalu"
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

var nb_alu_tests int = 1024

func TestALU(t *testing.T) {
	wci := g.NewWire()
	wco := g.NewWire()
	weqo := g.NewWire()
	walo := g.NewWire()
	wz := g.NewWire()
	bas := g.NewBus()
	bbs := g.NewBus()
	bcs := g.NewBus()
	bops := g.NewBusN(3)
	NewALU(bas, bbs, wci, bops, bcs, wco, weqo, walo, wz)

	ta.RunFullRandomALUTests(t, nb_alu_tests, func(tc ta.ALUTestCase) ta.ALUTestCase {
		// Reset the ALU before setting the new value.
		// In the final setup this will not be necessary as each instruction will start with empty ALU buses
		bas.SetPower(0)
		bbs.SetPower(0)
		wci.SetPower(false)
		bops.SetPower(0)

		bops.SetPower(tc.OP)
		bas.SetPower(tc.A)
		bbs.SetPower(tc.B)
		wci.SetPower(tc.CI)
		if tc.OP < 7 {
			tc.C = bcs.GetPower()
		}
		if tc.OP < 3 {
			tc.CO = wco.GetPower()
		}
		if tc.OP > 5 {
			tc.EQO = weqo.GetPower()
			tc.ALO = walo.GetPower()
		}
		tc.Z = wz.GetPower()

		return tc
	})
}
