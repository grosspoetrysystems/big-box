# Rack Mount Go

Bootstrap production-ready Go repositories with a complete development substrate.

Rack Mount Go is an opinionated project setup for Go services, CLIs, libraries, APIs, and agentic systems. It keeps the module native and predictable while adding the repo hygiene teams expect: formatting, imports, linting, tests, coverage, hooks, and conventional commit checks.

## What It Provides

- Go modules
- Go 1.24+ defaults
- `go build` as the build path
- `air` for long-running development servers
- `gofmt` and `goimports` for formatting
- `golangci-lint` for static checks
- `go test -cover ./...` for tests and coverage
- Lefthook for Git hooks
- A lightweight Conventional Commits hook

## Project Shapes

Reference presets live in `references/surfaces/`:

- Library
- CLI
- API

## Layout

- `SKILL.md` defines the setup workflow and decision rules.
- `references/` contains copyable config templates and tooling notes.
- `scripts/` contains helper scripts used by the substrate.

Use this when you want a Go repo to start with consistent tooling and simple, maintainable guardrails.

## Companion skills

Part of a four-skill set — mix and match by language and layer:

| | Project substrate | AI / inference layer |
|---|---|---|
| **TypeScript** | [rack-mount-ts](https://github.com/grosspoetrysystems/rack-mount-ts) | [cable-run-ts](https://github.com/grosspoetrysystems/cable-run-ts) |
| **Go** | [rack-mount-go](https://github.com/grosspoetrysystems/rack-mount-go) | [cable-run-go](https://github.com/grosspoetrysystems/cable-run-go) |

`rack-mount` sets up the project substrate; `cable-run` wires the inference layer on top.
