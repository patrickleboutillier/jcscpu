package arch

import (
	"fmt"
	"os"
	"strconv"
)

// Maybe set from env var?
var arch_bits int = defaultArchBits()

func checkArchBits(n int) int {
	if (n < 8) || (n > 16) {
		panic(fmt.Errorf("Arch bits ust be between 8 and 16 inclusively"))
	}
	return n
}

func defaultArchBits() int {
	env := os.Getenv("ARCH_BITS")
	if i, err := strconv.ParseInt(env, 10, 32); err == nil {
		return checkArchBits(int(i))
	}
	return 8
}

func GetArchBits() int {
	return arch_bits
}

func SetArchBits(n int) {
	arch_bits = checkArchBits(n)
}

func GetMaxByteValue() int {
	return (1 << arch_bits) - 1
}
