package function

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestJCSCPU8(t *testing.T) {
	tests := []struct {
		method string
		url    string
		ctype  string
		body   string
		code   int
		want   string
	}{
		{method: "POST", url: "/8", ctype: "application/json", body: `[32,20,33,22,129,32,0,124,121,97]`, want: `[{"TTY":"*"}]`, code: http.StatusOK},
		{method: "POST", url: "/8", ctype: "text/plain", body: `00100000 # DATA  R0, 00010100 (20)
00010100 # ...   20
00100001 # DATA  R1, 00010110 (22)
00010110 # ...   22
10000001 # ADD   R0, R1
00100000 # DATA  R0, 00000000 (0)
00000000 # ...   0
01111100 # OUTA  R0
01111001 # OUTD  R1
01100001 # HALT`, want: `*`, code: http.StatusOK},
		{method: "GET", url: "/8?00100000;00010100;00100001;00010110;10000001;00100000;00000000;01111100;01111001;01100001", ctype: "", body: ``, want: `*`, code: http.StatusOK},
		{method: "GET", url: "/", ctype: "", body: ``, want: `*`, code: http.StatusNotFound},
	}

	for _, test := range tests {
		var body io.Reader
		if test.body != "" {
			body = strings.NewReader(test.body)
		}
		req := httptest.NewRequest(test.method, test.url, body)
		if test.ctype != "" {
			req.Header.Add("Content-Type", test.ctype)
		}

		rr := httptest.NewRecorder()
		JCSCPU(rr, req)

		if rr.Code != test.code {
			t.Errorf("JCSCPU8(%q) = %d, want %d", test.body, rr.Code, test.code)
		}
		if rr.Code == http.StatusOK {
			if got := rr.Body.String(); got != test.want {
				t.Errorf("JCSCPU8(%q) = %q, want %q", test.body, got, test.want)
			}
		}
	}
}
