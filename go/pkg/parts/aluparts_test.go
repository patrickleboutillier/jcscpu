package parts

import (
	"fmt"
	"math/rand"
	"testing"

	ta "github.com/patrickleboutillier/jcscpu/go/internal/testalu"
	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
	a "github.com/patrickleboutillier/jcscpu/go/pkg/arch"
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

var nb_tests_per_part int = 1024

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

func TestXOrrer(t *testing.T) {
	bas := g.NewBus()
	bbs := g.NewBus()
	bcs := g.NewBus()
	weqo := g.NewWire()
	walo := g.NewWire()
	NewXORer(bas, bbs, bcs, weqo, walo)

	ta.RunRandomALUTests(t, nb_tests_per_part, 6, func(tc ta.ALUTestCase) ta.ALUTestCase {
		bas.SetPower(tc.A)
		bbs.SetPower(tc.B)
		tc.C = bcs.GetPower()
		tc.EQO = weqo.GetPower()
		tc.ALO = walo.GetPower()
		return tc
	}, ta.XOr)
}

func TestCmp(t *testing.T) {
	bas := g.NewBus()
	bbs := g.NewBus()
	bcs := g.NewBus()
	weqo := g.NewWire()
	walo := g.NewWire()
	NewXORer(bas, bbs, bcs, weqo, walo)

	ta.RunRandomALUTests(t, nb_tests_per_part, 7, func(tc ta.ALUTestCase) ta.ALUTestCase {
		bas.SetPower(tc.A)
		bbs.SetPower(tc.B)
		tc.EQO = weqo.GetPower()
		tc.ALO = walo.GetPower()
		return tc
	}, ta.Cmp)
}

func TestZero(t *testing.T) {
	bis := g.NewBus()
	wz := g.NewWire()
	NewZero(bis, wz)

	ta.RunRandomALUTests(t, nb_tests_per_part, 8, func(tc ta.ALUTestCase) ta.ALUTestCase {
		// Zero takes it's input from C, so we just copy A to C
		tc.C = tc.A
		bis.SetPower(tc.C)
		tc.Z = wz.GetPower()
		return tc
	}, func(tc ta.ALUTestCase) ta.ALUTestCase {
		// Zero takes it's input from C, so we just copy A to C
		tc.C = tc.A
		return ta.Zero(tc)
	})

	tc := ta.NewALUTestCase(0, 0, false)
	tc.OP = 8
	testname := fmt.Sprintf("ALU(op:%d,a:%d,b:%d,ci:%d)", tc.OP, tc.A, tc.B, 0)
	t.Run(testname, func(t *testing.T) {
		result := func(tc ta.ALUTestCase) ta.ALUTestCase {
			bis.SetPower(tc.C)
			tc.Z = wz.GetPower()
			return tc
		}
		expected := func(tc ta.ALUTestCase) ta.ALUTestCase {
			tc.Z = true
			return tc
		}
		tm.Is(t, result(tc), expected(tc), testname)
	})
}

func TestBus1(t *testing.T) {
	bis := g.NewBus()
	wbit1 := g.NewWire()
	bos := g.NewBus()
	NewBus1(bis, wbit1, bos)

	for j := 0; j < nb_tests_per_part; j++ {
		x := rand.Intn(a.GetMaxByteValue())
		y := rand.Intn(2)
		b := false
		res := x
		if y == 1 {
			b = true
			res = 1
		}
		testname := fmt.Sprintf("BUS1(%d, %t)=%d", x, b, res)
		t.Run(testname, func(t *testing.T) {
			wbit1.SetPower(b)
			bis.SetPower(x)
			tm.Is(t, bos.GetPower(), res, testname)
		})
	}
}
