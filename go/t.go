package main

import (
	"fmt"
	"time"
)

var n int = 0

func f() {
	n++
}

func main() {
	start := time.Now()

	for n < 10000000 {
		f()
	}

	end := time.Now()
	elapsed := end.Sub(start)
	fmt.Printf("Elapsed: %d %d ms", n, elapsed/1000000)
}
