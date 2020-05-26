package computer

import (
	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
	b "github.com/patrickleboutillier/jcscpu/pkg/board"
)

/*
COMPUTER
*/
type Computer struct {
	BB *b.Breadboard
}

func NewComputer(bits int) *Computer {
	a.SetArchBits(bits)
	BB := b.NewBreadboard()
	return &Computer{BB}
}

// Place the instructions in the ROM and calls Run() with the booloader program.
// A HALT instruction is appeneded at the end to make sure the computer stops when the program is over.
// An END instruction is appeneded at the end to make sure the bootloader stops knows when to stop reading the program.
func (this *Computer) Boot(insts []int) {
}
