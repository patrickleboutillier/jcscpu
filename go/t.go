package main

import (
	"fmt"
)

var n int = 0

func f() {
	n++
}

func main() {
	for j := 0; j < 256; j++ {
		n := int8(j)
		//if random {
		//	n = int8(rand.Intn(256))
		//}
		//we.SetPower(false)
		//bis.SetPowerInt(n)
		fmt.Printf("%08b\n", n)
		//we.SetPower(true)
		//if bos.GetPowerInt() != n {
		//	t.Errorf("ENABLER(%d, 1)=%d", n, n)
		//}
	}
	fmt.Printf("%08b\n", 256)
}
