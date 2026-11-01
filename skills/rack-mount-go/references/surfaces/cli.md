# CLI Surface

## Extra deps
```bash
go get github.com/spf13/cobra@v1.10.2
```

## Directory structure
```
cmd/
  <project-name>/
    main.go
internal/
  cli/
    root.go
  commands/
```

## Entry file: cmd/<project-name>/main.go
```go
// Package main starts the <project-name> command.
package main

import (
	"log"

	"<module-path>/internal/cli"
)

func main() {
	if err := cli.NewRootCommand().Execute(); err != nil {
		log.Fatal(err)
	}
}
```

## Starter: internal/cli/root.go
```go
// Package cli builds the <project-name> command tree.
package cli

import "github.com/spf13/cobra"

func NewRootCommand() *cobra.Command {
	return &cobra.Command{
		Use:   "<project-name>",
		Short: "<description>",
		RunE: func(cmd *cobra.Command, args []string) error {
			cmd.Println("ready")
			return nil
		},
	}
}
```

## Notes
- Keep `cmd/` thin and push behavior into `internal/`
- Add subcommands in `internal/commands/` once the CLI grows
