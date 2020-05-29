package jcscpu

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"strings"
)

type Request struct {
	Insts []int `json:"insts"`
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
	req := Request{}

	if err := json.NewDecoder(input).Decode(&req); err == nil {
		return nil, err
	}

	return req.Insts, nil
}
