// Some functions to facilitate Instruction testing
package testinst

import (
	"fmt"
	"math/rand"
	"testing"

	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
)

type INSTSetup func(INSTTestCase)
type INSTTest func(INSTTestCase)
type INSTDo func(INSTTestCase)

type INSTTestCase struct {
	INST   int    // The actual instruction
	RA, RB string // The resigters that are arguments for this instruction
	IADDR  int    // Where will the instruction will be stored?
	IDADDR int    // Where will the data used in the instruction de stored (must be IADDR+1)
	IDATA  int    // Random data used by the instruction (LD, ST, JUMP, ...)

	ADDR int // Random address used by the instruction (LD, ST, JUMP, ...)
	DATA int // Random data used by the instruction
}

func NewRandomINSTTestCase(inst int) INSTTestCase {
	ra := rand.Intn(4)
	rb := rand.Intn(4)
	regs := []string{"R0", "R1", "R2", "R3"}

	inst = (inst << 4) + (ra << 2) + rb

	max := a.GetMaxByteValue()
	iaddr := rand.Intn(max - 2)
	idaddr := iaddr + 1
	idata := rand.Intn(max)
	addr := rand.Intn(max)
	data := rand.Intn(max)

	// Make sure instruction addr is different from iaddr and idaddr
	for (addr == iaddr) || (addr == idaddr) {
		addr = rand.Intn(max)
	}

	return INSTTestCase{INST: inst, RA: regs[ra], RB: regs[rb],
		IADDR: iaddr, IDADDR: idaddr, IDATA: idata, ADDR: addr, DATA: data}
}

func RunRandomINSTTest(t *testing.T, inst int, setup INSTSetup, do INSTDo, ok INSTTest) {
	tc := NewRandomINSTTestCase(inst)
	testname := fmt.Sprintf("INST(inst:%d,ra:%s,rb:%s,iaddr:%d,idata:%d,addr:%d,data:%d)", inst, tc.RA, tc.RB, tc.IADDR, tc.IDATA, tc.ADDR, tc.DATA)

	t.Run(testname, func(t *testing.T) {
		setup(tc)
		do(tc)
		ok(tc)
	})
}

func RunRandomINSTTests(t *testing.T, n int, inst int, setup INSTSetup, do INSTDo, ok INSTTest) {
	for j := 0; j < n; j++ {
		RunRandomINSTTest(t, inst, setup, do, ok)
	}
}

/*
func RunFullRandomINSTTests(t *testing.T, n int, result INSTTest) {
	for j := 0; j < n; j++ {
		op := rand.Intn(8)
		RunRandomINSTTest(t, op, result, func(tc INSTTestCase) INSTTestCase {
			var f INSTTest = nil
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
*/
