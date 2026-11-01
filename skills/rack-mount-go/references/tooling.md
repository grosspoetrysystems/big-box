# Go Tooling

Use the native Go toolchain first. Add helper tools only where they remove friction.

## Bootstrap

Initialize the module, set the supported Go floor, and record development tools
with Go tool directives. The versions below were verified against
`proxy.golang.org` on 2026-11-01; keep the version in the command when
upgrading deliberately.

```bash
go mod init <module-path>
go mod edit -go=1.26

go get -tool github.com/evilmartians/lefthook/v2@v2.1.8
go get -tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.15.0
go get -tool golang.org/x/vuln/cmd/govulncheck@v1.9.0
```

Lefthook is pinned to v2.1.8 because the newer v2.2.x line declares a Go 1.27
floor; this preserves the skill's Go 1.26 floor. Revisit the pin when the
project raises its language floor.

For a long-running application, also add the development runner:

```bash
go get -tool github.com/air-verse/air@v1.67.4
```

Run tools from the module so the recorded versions are used:

```bash
go tool lefthook install
go tool golangci-lint config verify
go tool golangci-lint fmt ./...
go tool golangci-lint run ./...
go tool govulncheck ./...
```

Libraries do not need `air`. GoReleaser is an optional tool for a CLI that
publishes cross-platform binaries; add
`github.com/goreleaser/goreleaser/v2@v2.19.0` with `go get -tool` only for that
case.

## Copy these files

- `references/gitignore` -> `.gitignore`
- `references/golangci.yml` -> `.golangci.yml`
- `references/lefthook.yml` -> `lefthook.yml`
- `references/ci.yml` -> `.github/workflows/ci.yml`
- `scripts/commit-msg.sh` -> `scripts/commit-msg.sh`

## After copying

```bash
chmod +x scripts/commit-msg.sh
go tool lefthook install
go tool golangci-lint config verify
go tool golangci-lint fmt ./...
go tool golangci-lint run ./...
go build ./...
go vet ./...
go test -race -cover ./...
go tool govulncheck ./...
```

Retrofitting an existing repo that still has a v1 `.golangci.yml`? Run
`go tool golangci-lint migrate` to convert it (it backs up the original as
`.golangci.yml.bck.yml`), then review the generated exclusions.
