// Command app is the entry point of the service.
package main

import (
	"fmt"
	"io"
	"os"
)

// version is set at build time: -ldflags "-X main.version=v1.2.3".
var version = "dev"

func run(w io.Writer) error {
	_, err := fmt.Fprintf(w, "hello from template-go %s\n", version)
	return err
}

func main() {
	if err := run(os.Stdout); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
