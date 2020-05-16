package arch

import (
	"os"
	"strconv"
)

// Maybe set from env var?
var arch_bits int = defaultArchBits()

func defaultArchBits() int {
	env := os.Getenv("ARCH_BITS")
	if i, err := strconv.ParseInt(env, 10, 32); err == nil {
		return int(i)
	}
	return 8
}

func GetArchBits() int {
	return arch_bits
}

func SetArchBits(n int) {
	// TODO: Implement limits here
	arch_bits = 16
}

func GetMaxByteValue() int {
	return (1 << arch_bits) - 1
}
