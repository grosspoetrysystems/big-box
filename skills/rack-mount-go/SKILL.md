---
name: rack-mount-go
description: >
  Use when the user wants to set up or retrofit a Go project with a
  production-grade dev stack. "set up a Go project", "init a Go repo",
  "add linting and testing", "modernize Go tooling",
  "scaffold a Go service", "scaffold a Go CLI",
  "what tooling should I use for Go".
metadata:
  version: "2.0"
  author: Gross Poetry Systems
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

## The substrate

Every project gets the native substrate. Add surface-specific tools only when
the project needs them.

| Layer | Tool |
|-------|------|
| Module | Go modules |
| Language | Go 1.26+; CI covers Go 1.26 and Go 1.27 |
| Build | `go build ./...` |
| Dev runner | `air` for long-running apps; skip for libraries |
| Format | `gofumpt` + `gci` via `go tool golangci-lint fmt` |
| Lint | `golangci-lint` v2, pinned with a Go tool directive |
| Test | `go test -race -cover ./...` |
| Vulnerability scan | `govulncheck ./...` |
| Git hooks | Lefthook v2 |
| CI | Copy `references/ci.yml` to `.github/workflows/ci.yml` |
| Commits | Conventional, enforced by `scripts/commit-msg.sh` |

The linter uses the standard set plus `bodyclose`, `gosec`, and `misspell`.
`gocritic` and `revive` are opt-in when a project is ready to own their style
rules.

## Surfaces (recommended, not required)

The substrate is the product. Surfaces are opinionated starting points for
common project types. Presets are in `references/surfaces/`.

| Surface | Reference |
|---------|-----------|
| Library | `surfaces/library.md` |
| CLI | `surfaces/cli.md` |
| API | `surfaces/api.md` |

## Instructions

1. Ask: what are you building? Choose a surface from the menu above.
2. For greenfield work, run `git init`, then `go mod init <module-path>`.
3. Read `references/tooling.md`. Copy its config, hook, gitignore, and CI
   templates, then add the pinned tools with `go get -tool`.
4. Read the chosen surface reference and install only its extra dependencies.
   The API starter uses `http.ServeMux` and `log/slog`; add chi only when
   route grouping or middleware makes it worthwhile.
5. For a retrofit, map what already exists before changing it:
   - `go.mod`: the `go`/`toolchain` lines, `tool` directives, `tools.go`, and
     dependency entries for chi, cobra, httplog, or testify.
   - Lint files: `.golangci.yml`, `.golangci.yaml`, or `.golangci.toml`;
     migrate a v1 config with `go tool golangci-lint migrate` and review it.
   - Hooks: `lefthook.yml`, `.pre-commit-config.yaml`, `.husky/`, existing
     hook paths, and `commitlint`/`commitsar` config.
   - Workflow/task files: `.github/workflows/`, `Makefile`, `Taskfile.yml`,
     `magefile.go`, `.air.toml`, and `.goreleaser.yaml`.
   - Code layout: `cmd/`, `internal/`, `pkg/`, router/logger imports, and
     existing build, test, race, and coverage commands.
   Merge with what exists; remove conflicting tools and duplicate wrappers
   instead of creating a second convention.
6. Make the hook executable, install Lefthook, and run the full checks:
   `go tool lefthook install`, `go tool golangci-lint config verify`,
   `go tool golangci-lint fmt ./...`, `go build ./...`, `go vet ./...`,
   `go test -race -cover ./...`, `go tool golangci-lint run ./...`, and
   `go tool govulncheck ./...`.
7. Create the selected entry files, then commit the formatted, linted, tested
   project. The commit hook validates the first non-comment line, accepts
   bodies and footers, and passes through Merge, Revert, `fixup!`, and
   `squash!` messages.

## Companion skills

- [rack-mount-ts](https://github.com/grosspoetrysystems/big-box/tree/main/skills/rack-mount-ts)
- [cable-run-go](https://github.com/grosspoetrysystems/big-box/tree/main/skills/cable-run-go)
- [cable-run-ts](https://github.com/grosspoetrysystems/big-box/tree/main/skills/cable-run-ts)
