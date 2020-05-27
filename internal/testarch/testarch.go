package testarch

import (
	"log"
	"os"
	"strconv"
)

// Maybe set from env var?
var archBits int = defaultArchBits()

func checkArchBits(n int) int {
	max := 32
	if strconv.IntSize < 64 {
		max = 16
	}
	if (n < 8) || (n > 30) {
		log.Panicf("Arch bits must be between 8 and %d inclusively", max)
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

func GetMaxByteValue() int {
	return (1 << archBits) - 1
}
