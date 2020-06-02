package computer

import (
	"fmt"
	"io"

	b "github.com/patrickleboutillier/jcscpu/pkg/board"
)

var iodevHandlers = make(map[string]func(*Computer))

/*
COMPUTER
*/
type Computer struct {
	BB        *b.Breadboard
	IOAdapter *IOAdapter
	bits      int
	maxinsts  int

	TTYWriter   io.Writer
	RNGLast     int
	ROMAddrLast int
	ROM         []int
}

func newVanillaComputer(bits int, maxinsts int) *Computer {
	BB := b.NewBreadboard(bits)
	ioa := NewIOAdapter(BB.GetBus("DATA.bus"), BB.GetBus("IO.bus"))

	this := &Computer{BB: BB, IOAdapter: ioa, bits: bits, maxinsts: maxinsts}
	BB.ExtraDebug = this.IOAdapter.String

	return this
}

func NewComputer(bits int, maxinsts int) *Computer {
	this := newVanillaComputer(bits, maxinsts)

	for _, f := range iodevHandlers {
		f(this)
	}

	return this
}

// Place the instructions in the ROM and calls Run() with the booloader program.
// A HALT instruction is appeneded at the end to make sure the computer stops when the program is over.
func (this *Computer) BootAndRun(insts []int) error {
	this.ROM = append(insts, b.HALT())
	// Install Bootloader program at the *end* of the RAM.
	max := 1 << this.bits
	// We want to keep the last 6 bytes of RAM uninitialized, as they may be used by higher-level
	// mechanisms lie a program stack.
	slack := 1
	pos, start, bl := bootLoader(max, slack)

	if len(insts) == 0 {
		return fmt.Errorf("No valid instructions provided!")
	}

	if len(insts) > pos {
		return fmt.Errorf("Program will overwrite bootloader code!")
	}

	for i, inst := range insts {
		if inst >= (1 << this.bits) {
			return fmt.Errorf("Instruction #%d, '%b', is too large for architecture size (%d bits)", i+1, inst, this.bits)
		}
	}

	// Install bootloader code at address pos.
	this.BB.SetRAMBlock(pos, bl)
	// Set IAR to start
	this.BB.SetReg("IAR", start)
	// Clear the bus and start the computer, which will stop right after the bootloader has run.
	this.BB.GetBus("DATA.bus").SetPower(0)
	this.BB.Start()

	// Boot loader is done, reset the clock and restart
	this.BB.CLK.Reset()
	if this.maxinsts > 0 {
		// Use maxinsts + 1 to account for the forst JUMP instruction
		this.BB.CLK.SetMaxTicks((this.maxinsts + 1) * 6)
	}

	this.BB.Start()

	return nil
}

func bootLoader(max int, slack int) (int, int, []int) {
	ret := []int{
		// line   0, pos   0 - R0 is our ROM address, R1 is our ROM size, R2 is our 1, R3 is our ROM data
		// line   1, pos   0 - Initialize R0 to 0
		0b00100000, // line   2, pos   0 - DATA  R0, 00000000 (0)
		0b00000000, // line   3, pos   1 -       00000000 (0)
		// line   4, pos   2 - Activate ROMSize and place value in R1
		0b00100001, // line   5, pos   2 - DATA  R1, 00000011 (3)
		0b00000011, // line   6, pos   3 -       00000011 (3)
		0b01111101, // line   7, pos   4 - OUTA  R1
		0b01110001, // line   8, pos   5 - IND   R1
		// line   9, pos   6 - Initialize R2 to 1
		0b00100010, // line  10, pos   6 - DATA  R2, 00000001 (1)
		0b00000001, // line  11, pos   7 -       00000001 (1)
		// line  12, pos   8 - Activate ROM
		0b00100011, // line  13, pos   8 - DATA  R3, 00000010 (2)
		0b00000010, // line  14, pos   9 -       00000010 (2)
		0b01111111, // line  15, pos  10 - OUTA  R3
		// line  16, pos  11 - Label 'getnextinst' at pos 11
		0b01111000, // line  17, pos  11 - OUTD  R0
		// line  18, pos  12 - Receive data in R3 and copy it to RAM at address that is in R0
		0b01110011, // line  19, pos  12 - IND   R3
		0b00010011, // line  20, pos  13 - ST    R0, R3
		// line  21, pos  14 - Increment R0
		0b10001000, // line  22, pos  14 - ADD   R2, R0
		// line  23, pos  15 - IF R0 == R1, jump to byte 0 in RAM
		0b11110001, // line  24, pos  15 - CMP   R0, R1
		// Normally the bootloader code would jump directly to RAM 0 here that start the program, but
		// we want to take the opportunity to reset the clock after de bootloader has run to help
		// with debugging, so we jump to the HALT at pos 20 instead
		0b01010010, // line  25, pos  16 - JE    00010100 (20)
		0b00010100, // line  26, pos  17 -       00010100 (20)
		// line  27, pos  18 - (ELSE) Loop back
		0b01000000, // line  28, pos  18 - JMP   00001011 (11)
		0b00001011, // line  29, pos  19 -       00001011 (11)
		0b01100001, // line  30, pos  20 - HALT
		0b01000000, // line  31, pos  21 - JMP   00000000 (00)
		0b00000000, // line  32, pos  22 -       00000000 (00)
		// Initial jump to boot loader start
		0b01000000, // line  33, pos  23 - JMP   00000000 (00)
		0b00000000, // line  34, pos  24 -       00000000 (00)
	}

	pos := max - (len(ret) + slack)

	// Adjust jump relative addresses
	ret[len(ret)-1] += pos
	ret[len(ret)-6] += pos
	ret[len(ret)-8] += pos

	return pos, max - (2 + slack), ret
}

func (this *Computer) String() string {
	str := this.BB.String()
	str += this.IOAdapter.String() + "\n"

	return str
}

/*
// line   0, pos   0 - R0 is our ROM address, R1 is our ROM size, R2 is our 1, R3 is our ROM data
// line   1, pos   0 - Initialize R0 to 0
0b00100000, // line   2, pos   0 - DATA  R0, 00000000 (0)
0b00000000, // line   3, pos   1 -       00000000 (0)
// line   4, pos   2 - Activate ROMSize and place value in R1
0b00100001, // line   5, pos   2 - DATA  R1, 00000011 (3)
0b00000011, // line   6, pos   3 -       00000011 (3)
0b01111101, // line   7, pos   4 - OUTA  R1
0b01110001, // line   8, pos   5 - IND   R1
// line   9, pos   6 - Initialize R2 to 1
0b00100010, // line  10, pos   6 - DATA  R2, 00000001 (1)
0b00000001, // line  11, pos   7 -       00000001 (1)
// line  12, pos   8 - Activate ROM
0b00100011, // line  13, pos   8 - DATA  R3, 00000010 (2)
0b00000010, // line  14, pos   9 -       00000010 (2)
0b01111111, // line  15, pos  10 - OUTA  R3
// line  16, pos  11 - Label 'getnextinst' at pos 11
0b01111011, // line  17, pos  11 - OUTD  R3
// line  18, pos  12 - Receive data in R3 and copy it to RAM at address that is in R0
0b01110011, // line  19, pos  12 - IND   R3
0b00010011, // line  20, pos  13 - ST    R0, R3
// line  21, pos  14 - Increment R0
0b10001000, // line  22, pos  14 - ADD   R2, R0
// line  23, pos  15 - IF R0 == R1, jump to byte 0 in RAM
0b11110001, // line  24, pos  15 - CMP   R0, R1
0b01010010, // line  25, pos  16 - JE    00000000 (0)
0b00000000, // line  26, pos  17 -       00000000 (0)
// line  27, pos  18 - (ELSE) Loop back
0b01000000, // line  28, pos  18 - JMP   00001011 (11)
0b00001011, // line  29, pos  19 -       00001011 (11)
0b01100001, // line  30, pos  20 - HALT
*/
