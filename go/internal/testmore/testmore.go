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

/*
func IsBool(t *testing.T, result bool, expected bool, name string) {
	if result != expected {
		t.Errorf("Failed test '%s' (got: %t, expected: %t)", name, result, expected)
	}
}

func IsInt(t *testing.T, result int, expected int, name string) {
	if result != expected {
		t.Errorf("Failed test '%s' (got: %d, expected: %d)", name, result, expected)
	}
}

func IsString(t *testing.T, result string, expected string, name string) {
	if result != expected {
		t.Errorf("Failed test '%s' (got: %s, expected: %s)", name, result, expected)
	}
}
*/

func Is(t *testing.T, result interface{}, expected interface{}, name string) {
	if !reflect.DeepEqual(result, expected) {
		ry, _ := yaml.Marshal(result)
		ey, _ := yaml.Marshal(expected)
		t.Errorf("Failed test '%s':\ngot:\n%sexpected:\n%s", name, ry, ey)
	}
}
