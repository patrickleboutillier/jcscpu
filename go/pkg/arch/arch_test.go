package arch

import (
	"os"
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
)

func TestArch(t *testing.T) {
	t.Logf("Arch bits is %d", GetArchBits())

	// Ignore ARCH_BITS if is set in the environment
	os.Setenv("ARCH_BITS", "")
	tm.Is(t, defaultArchBits(), 8, "Defaut arch bits is 8")
	SetArchBits(8)
	tm.Is(t, GetMaxByteValue(), 255, "Max byte for 8 bits is 255")
}

func TestArchErrors(t *testing.T) {
	tm.TPanic(t, func() {
		checkArchBits(5)
	})
	tm.TPanic(t, func() {
		checkArchBits(45)
	})
}
