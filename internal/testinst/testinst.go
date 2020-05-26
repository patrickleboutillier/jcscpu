// Some functions to facilitate Instruction testing
package testinst

import (
	"fmt"
	"math/rand"
	"testing"

	ta "github.com/patrickleboutillier/jcscpu/internal/testarch"
)

type INSTSetup func(INSTTestCase)
type INSTTest func(INSTTestCase)
type INSTDo func(INSTTestCase)

type INSTTestCase struct {
	INST   int    // The actual instruction
	RA, RB string // The resigters that are arguments for this instruction
	IFLAGS int    // Instruction flags, same as RA,RB
	IADDR  int    // Where will the instruction will be stored?
	IDADDR int    // Where will the data used in the instruction de stored (must be IADDR+1)
	IDATA  int    // Random data used by the instruction (LD, ST, JUMP, ...)

	ADDR  int // Random address used by the instruction (LD, ST, JUMP, ...)
	DATA  int // Random data used by the instruction
	FLAGS int // ALU flags

	DATA2 int  // Random data #2 to be used by ALU instruction
	CI    bool // Random carry in to be used by ALU instruction
	IODEV int  // Randon IO Device
}

func NewRandomINSTTestCase(inst int) INSTTestCase {
	ra := rand.Intn(4)
	rb := rand.Intn(4)
	regs := []string{"R0", "R1", "R2", "R3"}

	// The flags for the J* instructions are just the same bits as RA,RB
	iflags := (ra << 2) + rb
	inst = (inst << 4) + (ra << 2) + rb

	max := ta.GetMaxByteValue()
	iaddr := rand.Intn(max - 2)
	idaddr := iaddr + 1
	idata := rand.Intn(max)
	addr := rand.Intn(max)
	data := rand.Intn(max)
	data2 := rand.Intn(max)
	ci := rand.Intn(2) != 0
	iodev := rand.Intn(16)

	// Make sure instruction addr is different from iaddr and idaddr
	for (addr == iaddr) || (addr == idaddr) {
		addr = rand.Intn(max)
	}

	return INSTTestCase{INST: inst, RA: regs[ra], RB: regs[rb],
		IADDR: iaddr, IDADDR: idaddr, IDATA: idata, ADDR: addr, DATA: data,
		FLAGS: rand.Intn(16), IFLAGS: iflags, DATA2: data2, CI: ci, IODEV: iodev,
	}
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
