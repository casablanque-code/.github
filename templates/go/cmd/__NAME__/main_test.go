package main

import (
	"bytes"
	"strings"
	"testing"
)

func TestRun(t *testing.T) {
	var buf bytes.Buffer
	if err := run(&buf); err != nil {
		t.Fatalf("run() error = %v", err)
	}
	if got := buf.String(); !strings.Contains(got, "hello from template-go") {
		t.Errorf("run() output = %q, want greeting", got)
	}
}
