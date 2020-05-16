package arch

// Maybe set from env var?
var arch_bits int = 16

func GetArchBits() int {
	return arch_bits
}

func SetArchBits(n int) {
	// TODO: Implement limits here
	arch_bits = n
}

func GetMaxByteValue() int {
	return (1 << arch_bits) - 1
}
