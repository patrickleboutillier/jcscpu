package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	j "github.com/patrickleboutillier/jcscpu/internal/jcscpu"
)

func main() {
	var insts []int
	var err error
	if insts, err = j.ParseTextInstructions(os.Stdin); err != nil {
		log.Fatal(err)
	}

	bytes, err := json.Marshal(insts)
	fmt.Println(string(bytes))
}
