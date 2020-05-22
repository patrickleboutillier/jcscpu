// Some functions to facilitate ALU testing
package testalu

import (
	"fmt"
	"math/rand"
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
)

type ALUTest func(ALUTestCase) ALUTestCase

type ALUTestCase struct {
	A, B, C, OP         int
	CI, CO, ALO, EQO, Z bool
}

func NewALUTestCase(a int, b int, ci bool) ALUTestCase {
	return ALUTestCase{A: a, B: b, CI: ci}
}

func NewRandomALUTestCase(op int) ALUTestCase {
	max := a.GetMaxByteValue()
	rb := false
	if rand.Intn(2) == 1 {
		rb = true
	}
	return ALUTestCase{A: rand.Intn(max), B: rand.Intn(max), CI: rb, OP: op}
}

func bool2int(b bool) int {
	if b {
		return 1
	} else {
		return 0
	}
}

func int2bool(i int) bool {
	if i == 0 {
		return false
	} else {
		return true
	}
}

// Add simulates an ADDer
func Add(tc ALUTestCase) ALUTestCase {
	tc.C = tc.A + tc.B + bool2int(tc.CI)
	tc.CO = false
	if tc.C > a.GetMaxByteValue() {
		tc.C -= (a.GetMaxByteValue() + 1)
		tc.CO = true
	}
	return tc
}

func ShiftRight(tc ALUTestCase) ALUTestCase {
	tc.C = (tc.A >> 1) + (bool2int(tc.CI) * ((a.GetMaxByteValue() + 1) / 2))
	tc.CO = int2bool(tc.A % 2)
	return tc
}

// ShiftLeft simulates a ShiftLeftter
func ShiftLeft(tc ALUTestCase) ALUTestCase {
	tc.C = (tc.A << 1) + bool2int(tc.CI)
	tc.CO = false
	if tc.C > a.GetMaxByteValue() {
		tc.C -= (a.GetMaxByteValue() + 1)
		tc.CO = true
	}
	return tc
}

// Not simulates a NOTter
func Not(tc ALUTestCase) ALUTestCase {
	tc.C = ^tc.A + a.GetMaxByteValue() + 1
	return tc
}

// And simulates an ANDder
func And(tc ALUTestCase) ALUTestCase {
	tc.C = tc.A & tc.B
	return tc
}

// Or simulates an ORrer
func Or(tc ALUTestCase) ALUTestCase {
	tc.C = tc.A | tc.B
	return tc
}

// Xor simulates an XORrer
func XOr(tc ALUTestCase) ALUTestCase {
	tc.C = tc.A ^ tc.B
	tc.EQO = (tc.A == tc.B)
	tc.ALO = (tc.A > tc.B)
	return tc
}

// Cmp simulates a Comparer
func Cmp(tc ALUTestCase) ALUTestCase {
	tc.EQO = (tc.A == tc.B)
	tc.ALO = (tc.A > tc.B)
	return tc
}

// Zero simulates a Comparer
func Zero(tc ALUTestCase) ALUTestCase {
	tc.Z = (tc.C == 0)
	return tc
}

func RunRandomALUTest(t *testing.T, op int, result ALUTest, expected ALUTest) {
	tc := NewRandomALUTestCase(op)
	testname := fmt.Sprintf("ALU(op:%d,a:%d,b:%d,ci:%d)", tc.OP, tc.A, tc.B, bool2int(tc.CI))
	t.Run(testname, func(t *testing.T) {
		tm.Is(t, result(tc), expected(tc), testname)
	})
}

func RunRandomALUTests(t *testing.T, n int, op int, result ALUTest, expected ALUTest) {
	for j := 0; j < n; j++ {
		RunRandomALUTest(t, op, result, expected)
	}
}

func RunFullRandomALUTests(t *testing.T, n int, result ALUTest) {
	for j := 0; j < n; j++ {
		op := rand.Intn(8)
		RunRandomALUTest(t, op, result, func(tc ALUTestCase) ALUTestCase {
			var f ALUTest = nil
			switch op {
			case 0:
				f = Add
			case 1:
				f = ShiftRight
			case 2:
				f = ShiftLeft
			case 3:
				f = Not
			case 4:
				f = And
			case 5:
				f = Or
			case 6:
				f = XOr
			case 7:
				f = Cmp
			}
			return Zero(f(tc))
		})
	}
}
