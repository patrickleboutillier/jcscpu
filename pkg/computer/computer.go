package computer

import (
	b "github.com/patrickleboutillier/jcscpu/pkg/board"
)

/*
COMPUTER
*/
type Computer struct {
	BB       *b.Breadboard
	bits     int
	maxinsts int
}

func NewComputer(bits int, maxinsts int) *Computer {
	BB := b.NewBreadboard(bits)
	return &Computer{BB, bits, maxinsts}
}

// Place the instructions in the ROM and calls Run() with the booloader program.
// A HALT instruction is appeneded at the end to make sure the computer stops when the program is over.
// An END instruction is appeneded at the end to make sure the bootloader stops knows when to stop reading the program.
func (this *Computer) BootAndRun(insts []int) {
	this.BB.ROM = append(insts, b.HALT(), b.END())
	// Install Bootloader program at the *end* of the RAM.
	max := 1 << this.bits
	bl := bootLoader()
	pos := max - len(bl)
	// TODO: Warn if len(insts) > pos?

	// Adjust jump address
	bl[len(bl)-2] += pos
	this.BB.SetRAMBlock(pos, bl)

	if this.maxinsts > 0 {
		this.BB.CLK.SetMaxTicks(this.maxinsts * 6)
	}
	this.BB.Run([]int{
		0b01000000, // JUMP
		pos,
		b.HALT(),
	})
}

func bootLoader() []int {
	return []int{
		// Activate ROM
		0b00100000, // DATA  R0, 00000010 (2)
		0b00000010, // ...   2
		0b01111100, // OUTA  R0
		// R0 is our 1, R3 is our HALT instruction, R1 is our ROM address, R2 is our ROM data
		0b00100000, // DATA  R0, 00000001 (1)
		0b00000001, // ...   1
		// Detect mandatory END instruction at program end
		0b00100011, // DATA  R3, 01101111 (111)
		0b01101111, // ...   111
		0b00100001, // DATA  R1, 00000000 (0)
		0b00000000, // ...   0
		// Label 'Ask for address in R1' at position 9
		0b01111001, // OUTD  R1
		// Receive data in R2 and copy it to RAM at address that is in R1
		0b01110010, // IND   R2
		0b00010110, // ST    R1, R2
		// IF R2 == END jump to byte 0 in RAM
		0b11111011, // CMP   R2, R3
		0b01010010, // JE    00000000 (0)
		0b00000000, // ...   0
		// Increment R1 and loop back
		0b10000001, // ADD   R0, R1
		0b01000000, // JMP   00001001 (9)
		0b00001001, // ...   9
		0b01100001, // HALT
	}
}
