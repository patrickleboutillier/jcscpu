// Package helloworld provides a set of Cloud Functions samples.
package function

import (
	"net/http"
	"strings"

	j "github.com/patrickleboutillier/jcscpu/internal/jcscpu"
)

func JCSCPU(w http.ResponseWriter, r *http.Request) {
	mux := http.NewServeMux()
	mux.HandleFunc("/8", func(w http.ResponseWriter, r *http.Request) {
		jcscpu(8, 8092, w, r)
	})
	mux.HandleFunc("/16", func(w http.ResponseWriter, r *http.Request) {
		jcscpu(16, 8092, w, r)
	})
	mux.ServeHTTP(w, r)
}

func jcscpu(bits int, maxinsts int, w http.ResponseWriter, r *http.Request) {

	defer func() {
		if e := recover(); e != nil {
			http.Error(w, e.(error).Error(), http.StatusInternalServerError)
		}
	}()

	var err error
	switch r.Method {
	case "GET":
		req := strings.Replace(r.URL.RawQuery, ";", "\n", -1)
		w.Header().Set("Content-Type", "text/plain")
		err = j.RunProgram(false, bits, maxinsts, false, strings.NewReader(req), w)
	case "POST":
		switch r.Header.Get("Content-Type") {
		case "application/json":
			w.Header().Set("Content-Type", "application/json")
			err = j.RunProgram(true, bits, maxinsts, false, r.Body, w)
		case "text/plain":
			w.Header().Set("Content-Type", "text/plain")
			err = j.RunProgram(false, bits, maxinsts, false, r.Body, w)
		default:
			http.Error(w, r.Method, http.StatusBadRequest)
		}
	default:
		http.Error(w, "Unsupported method "+r.Method, http.StatusMethodNotAllowed)
	}

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
	}
}
