package arch

import (
	"testing"
)

func TestArch(t *testing.T) {
	t.Logf("Arch bits is %d", GetArchBits())
}
