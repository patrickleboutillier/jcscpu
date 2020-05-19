package parts

import (
	"testing"

	ta "github.com/patrickleboutillier/jcscpu/go/internal/testalu"
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

var nb_tests_per_part int = 256

func TestShiftRight(t *testing.T) {
	wci := g.NewWire()
	wco := g.NewWire()
	bis := g.NewBus()
	bos := g.NewBus()
	NewShiftRight(bis, wci, bos, wco)

	ta.RunRandomALUTests(t, nb_tests_per_part, 1, func(tc ta.ALUTestCase) ta.ALUTestCase {
		bis.SetPower(tc.A)
		wci.SetPower(tc.CI)
		tc.C = bos.GetPower()
		tc.CO = wco.GetPower()
		return tc
	}, ta.ShiftRight)
}

func TestShiftLeft(t *testing.T) {
	wci := g.NewWire()
	wco := g.NewWire()
	bis := g.NewBus()
	bos := g.NewBus()
	NewShiftLeft(bis, wci, bos, wco)

	ta.RunRandomALUTests(t, nb_tests_per_part, 2, func(tc ta.ALUTestCase) ta.ALUTestCase {
		bis.SetPower(tc.A)
		wci.SetPower(tc.CI)
		tc.C = bos.GetPower()
		tc.CO = wco.GetPower()
		return tc
	}, ta.ShiftLeft)
}
