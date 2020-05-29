// Package helloworld provides a set of Cloud Functions samples.
package function

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func JCSCPU8(w http.ResponseWriter, r *http.Request) {
	JCSCPU(8, 8092, w, r)
}

/*
	Here's what we need to do here:
	- Get the instructions in a JSON POST
	- Create the computer
	- fiddle BB Logger and TTYWriter to be able to capture there output and add it to a JSON structure (or stream it?)
	- Feed it the instructions
	- return 40X error is anythig goes wrong anywhere above
	- return 50X error if a panic is thrown (dev error)
*/
func JCSCPU(bits int, maxinsts int, w http.ResponseWriter, r *http.Request) {
	var req struct {
		insts []int
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err == nil {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprint(w, err)
		return
	}

	/*
		C := c.NewComputer(bits, maxinsts)
		insts := ParseInstructions(bits)
		if len(insts) == 0 {
			log.Fatal("No valid instructions provided!")
		}
	*/
}
