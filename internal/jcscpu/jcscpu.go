package jcscpu

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"strings"

	c "github.com/patrickleboutillier/jcscpu/pkg/computer"
)

type Output struct {
	TTY   string `json:"TTY,omitempty"`
	Debug string `json:"DEBUG,omitempty"`
}

type FuncWriter struct {
	WriteWith func([]byte)
}

func (this FuncWriter) Write(p []byte) (n int, err error) {
	this.WriteWith(p)
	return len(p), nil
}

func ParseTextInstructions(input io.Reader) ([]int, error) {
	ret := make([]int, 0, 64)

	scanner := bufio.NewScanner(input)
	nbline := 0
	for scanner.Scan() {
		nbline++
		line := strings.TrimSpace(scanner.Text())
		if len(line) == 0 || line[0] == '#' {
			continue
		}
		var inst int
		_, err := fmt.Sscanf(line, "%b", &inst)
		if err != nil {
			return nil, fmt.Errorf("Error parsing line %d: %v", nbline, err)
		}

		ret = append(ret, inst)
	}

	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("Error parsing line %d: %v", nbline, err)
	}

	return ret, nil
}

func ParseJSONInstructions(input io.Reader) ([]int, error) {
	ret := make([]int, 0, 64)

	if err := json.NewDecoder(input).Decode(&ret); err != nil {
		return nil, err
	}

	return ret, nil
}

func RunProgram(jsonio bool, bits int, maxinsts int, debugonstop bool, input io.Reader, output io.Writer) error {
	var insts []int
	var err error
	if jsonio {
		if insts, err = ParseJSONInstructions(input); err != nil {
			return err
		}
	} else {
		if insts, err = ParseTextInstructions(input); err != nil {
			return err
		}
	}

	C := c.NewComputer(bits, maxinsts)

	var out []Output
	out = make([]Output, 0, 64)
	if jsonio {
		// Make debug statements append to resp
		C.BB.LogWith(func(msg string) {
			out = append(out, Output{Debug: msg})
		})
		C.TTYWriter = FuncWriter{func(msg []byte) {
			out = append(out, Output{TTY: string(msg)})
		}}
	} else {
		C.BB.LogWith(func(msg string) {
			fmt.Fprint(output, "DEBUG: "+msg)
		})
		C.TTYWriter = output
	}

	if err := C.BootAndRun(insts); err != nil {
		log.Fatal(err)
	}

	if debugonstop {
		C.BB.Debug()
	}

	if jsonio {
		bytes, err := json.Marshal(out)
		if err != nil {
			log.Panic(err)
		}
		fmt.Fprint(output, string(bytes))
	}

	return nil
}
