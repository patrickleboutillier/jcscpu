package parts

import (
	"testing"

	ta "github.com/patrickleboutillier/jcscpu/go/internal/testalu"
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

var nb_tests_per_part int = 256

func TestAdder(t *testing.T) {
	wci := g.NewWire()
	wco := g.NewWire()
	bas := g.NewBus()
	bbs := g.NewBus()
	bcs := g.NewBus()
	NewAdder(bas, bbs, wci, bcs, wco)

	ta.RunRandomALUTests(t, nb_tests_per_part, 0, func(tc ta.ALUTestCase) ta.ALUTestCase {
		bas.SetPower(tc.A)
		bbs.SetPower(tc.B)
		wci.SetPower(tc.CI)
		tc.C = bcs.GetPower()
		tc.CO = wco.GetPower()
		return tc
	}, ta.Add)
}

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

func TestNotter(t *testing.T) {
	bis := g.NewBus()
	bos := g.NewBus()
	NewNotter(bis, bos)

	ta.RunRandomALUTests(t, nb_tests_per_part, 3, func(tc ta.ALUTestCase) ta.ALUTestCase {
		bis.SetPower(tc.A)
		tc.C = bos.GetPower()
		return tc
	}, ta.Not)
}

func TestAndder(t *testing.T) {
	bas := g.NewBus()
	bbs := g.NewBus()
	bcs := g.NewBus()
	NewAndder(bas, bbs, bcs)

	ta.RunRandomALUTests(t, nb_tests_per_part, 4, func(tc ta.ALUTestCase) ta.ALUTestCase {
		bas.SetPower(tc.A)
		bbs.SetPower(tc.B)
		tc.C = bcs.GetPower()
		return tc
	}, ta.And)
}

func TestOrrer(t *testing.T) {
	bas := g.NewBus()
	bbs := g.NewBus()
	bcs := g.NewBus()
	NewOrrer(bas, bbs, bcs)

	ta.RunRandomALUTests(t, nb_tests_per_part, 5, func(tc ta.ALUTestCase) ta.ALUTestCase {
		bas.SetPower(tc.A)
		bbs.SetPower(tc.B)
		tc.C = bcs.GetPower()
		return tc
	}, ta.Or)
}
