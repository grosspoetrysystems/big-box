# Rack Mount Go

Bootstrap Go repositories with a complete, native development substrate.

Rack Mount Go is an opinionated project setup for Go services, CLIs, libraries,
and APIs. It keeps the module predictable while adding formatting, imports,
linting, tests, coverage, vulnerability checks, hooks, and CI.

## What It Provides

- Go modules
- Go 1.26+ (CI covers Go 1.26 and Go 1.27)
- `go build ./...` as the build path
- `air` for long-running development servers
- `gofumpt` and `gci` through `golangci-lint fmt`
- Pinned Go development tools through `go get -tool` and `go tool`
- `golangci-lint` v2 for static checks
- `go test -race -cover ./...` for tests and coverage
- `govulncheck ./...` for vulnerability checks
- Lefthook v2 for Git hooks
- A CI workflow template
- A lightweight Conventional Commits hook

## Project Shapes

Reference presets live in `references/surfaces/`:

- Library
- CLI
- API

## Layout

- `SKILL.md` defines the setup workflow and decision rules.
- `references/` contains copyable config, CI, and surface templates.
- `scripts/` contains helper scripts used by the substrate.

Use this when you want a Go repo to start with consistent tooling and simple,
maintainable guardrails.

## Companion skills

Part of a four-skill set — mix and match by language and layer:

| | Project substrate | AI / inference layer |
|---|---|---|
| **TypeScript** | [rack-mount-ts](https://github.com/grosspoetrysystems/big-box/tree/main/skills/rack-mount-ts) | [cable-run-ts](https://github.com/grosspoetrysystems/big-box/tree/main/skills/cable-run-ts) |
| **Go** | [rack-mount-go](https://github.com/grosspoetrysystems/big-box/tree/main/skills/rack-mount-go) | [cable-run-go](https://github.com/grosspoetrysystems/big-box/tree/main/skills/cable-run-go) |

`rack-mount` sets up the project substrate; `cable-run` wires the inference
layer on top.
