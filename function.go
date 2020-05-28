// Package helloworld provides a set of Cloud Functions samples.
package function

import (
	"encoding/json"
	"fmt"
	"html"
	"net/http"
)

/*
	Here's what we need to do here:
	- Get the instructions in a JSON POST
	- Create the computer
	- fiddle BB Logger and TTYWriter to be able to capture there output and add it to a JSON structure (or stream it?)
	- Feed it the instructions
	- return 40X error is anythig goes wrong anywhere above
	- return 50X error if a panic is thrown (dev error)
*/
func JCSCPU(w http.ResponseWriter, r *http.Request) {
	var d struct {
		Name string `json:"name"`
	}
	if err := json.NewDecoder(r.Body).Decode(&d); err != nil {
		fmt.Fprint(w, "Hello, World!")
		return
	}
	if d.Name == "" {
		fmt.Fprint(w, "Hello, World!")
		return
	}
	fmt.Fprintf(w, "Hello, %s!", html.EscapeString(d.Name))
}
