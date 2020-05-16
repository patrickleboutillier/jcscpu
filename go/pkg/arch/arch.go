package arch

var arch_bits int = 8

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
