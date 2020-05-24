package arch

import (
	"fmt"
	"os"
	"strconv"
)

// Maybe set from env var?
var archBits int = defaultArchBits()

func checkArchBits(n int) int {
	// TODO: Should be a multiple of 2
	if (n < 8) || (n > 32) {
		panic(fmt.Errorf("Arch bits must be between 8 and 32 inclusively"))
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
	return archBits
}

func SetArchBits(n int) {
	archBits = checkArchBits(n)
}

func GetMaxByteValue() int {
	return (1 << archBits) - 1
}
