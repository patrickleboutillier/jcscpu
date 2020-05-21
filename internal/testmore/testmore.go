package testmore

import (
	"reflect"
	"testing"

	"gopkg.in/yaml.v2"
)

func Ok(t *testing.T, result bool, name string) {
	if !result {
		t.Errorf("Failed test '%s'", name)
	}
}

func Is(t *testing.T, result interface{}, expected interface{}, name string) {
	if !reflect.DeepEqual(result, expected) {
		ry, _ := yaml.Marshal(result)
		ey, _ := yaml.Marshal(expected)
		t.Errorf("Failed test '%s':\ngot:\n%sexpected:\n%s", name, ry, ey)
	}
}

func TPanic(t *testing.T, f func()) {
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("Not panicking!")
		}
	}()
	f()
}
