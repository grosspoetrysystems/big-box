---
name: rack-mount-go
description: >
  Use when the user wants to set up or retrofit a Go project with a
  production-grade dev stack. "set up a Go project", "init a Go repo",
  "add linting and testing", "modernize Go tooling",
  "scaffold a Go service", "scaffold a Go CLI",
  "what tooling should I use for Go".
metadata:
  version: "1.0"
  author: whomst
license: MIT
---

# Rack Mount Go

Production-grade Go project substrate. Keep the module native, strict, and boring in the right places.

## When to use
- New Go project
- Retrofitting an existing Go repo with missing tooling
- Upgrading a Go dev stack to current practices

## When NOT to use
- Non-Go projects
- User explicitly wants a different stack

## The substrate (non-negotiable)

Every project gets all of these. Exact commands and config templates are in `references/`.

| Layer | Tool |
|-------|------|
| Module | Go modules |
| Language | Go 1.25+ (1.26 current) |
| Build | `go build` |
| Dev runner | `air` for long-running apps; skip for libraries |
| Format | `gofmt` + `goimports` (run via `golangci-lint fmt`) |
| Lint | `golangci-lint` (v2) |
| Test | `go test -cover ./...` |
| Git hooks | Lefthook |
| Commits | Conventional, enforced by `scripts/commit-msg.sh` |

## Surfaces (recommended, not required)

The substrate is the product. Surfaces are opinionated starting points for common project types. Presets are in `references/surfaces/`.

| Surface | Reference |
|---------|-----------|
| Library | `surfaces/library.md` |
| CLI | `surfaces/cli.md` |
| API | `surfaces/api.md` |

## Instructions

1. Ask: what are you building? (surface menu above)
2. If greenfield: `git init` and `go mod init <module-path>`
3. Read `references/tooling.md`, then install the substrate tools and copy the config files
4. Install surface deps (the chosen surface reference has the specifics)
5. If retrofitting: merge with what exists, don't replace. Remove conflicting tools and duplicate wrappers
6. Initialize lefthook, create the entry files if greenfield, run format/lint/test, commit

Read the reference files for specifics. Don't memorize them.
