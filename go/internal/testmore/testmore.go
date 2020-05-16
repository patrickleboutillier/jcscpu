package testmore

import (
	"testing"
)

func Ok(t *testing.T, result bool, name string) {
	if !result {
		t.Errorf("Failed test '%s'", name)
	}
}

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
