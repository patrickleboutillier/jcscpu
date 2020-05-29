// Package helloworld provides a set of Cloud Functions samples.
package function

import (
	"fmt"
	"net/http"
	"strings"

	j "github.com/patrickleboutillier/jcscpu/internal/jcscpu"
)

func JCSCPU8(w http.ResponseWriter, r *http.Request) {
	JCSCPU(8, 8092, w, r)
}

func JCSCPU(bits int, maxinsts int, w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		req := strings.Replace(r.URL.RawQuery, ";", "\n", -1)
		w.Header().Set("Content-Type", "text/plain")
		err := j.RunProgram(false, bits, maxinsts, false, strings.NewReader(req), w)
		if err != nil {
			fmt.Println(err)
		}
		defer func() {
			if r := recover(); r != nil {
				fmt.Println(err)
			}
		}()
	case "POST":
		switch r.Header.Get("Content-Type") {
		case "application/json":
			w.Header().Set("Content-Type", "application/json")
			err := j.RunProgram(true, bits, maxinsts, false, r.Body, w)
			if err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
			}
			defer func() {
				if r := recover(); r != nil {
					http.Error(w, err.Error(), http.StatusInternalServerError)
				}
			}()
		case "text/plain":
			w.Header().Set("Content-Type", "text/plain")
			err := j.RunProgram(false, bits, maxinsts, false, r.Body, w)
			if err != nil {
				fmt.Fprintln(w, err)
			}
			defer func() {
				if r := recover(); r != nil {
					fmt.Fprintln(w, err)
				}
			}()
		default:
			http.Error(w, r.Method, http.StatusBadRequest)
		}
	default:
		http.Error(w, "Bad Content-Type", http.StatusMethodNotAllowed)
	}
}
