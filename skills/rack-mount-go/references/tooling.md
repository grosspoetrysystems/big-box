# Go Tooling

Use the native Go toolchain first. Add helper tools only where they remove friction.

## Bootstrap

```bash
go mod init <module-path>
go install github.com/air-verse/air@latest
go install github.com/evilmartians/lefthook@latest
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
```

golangci-lint v2 bundles the formatters (`gofmt`, `goimports`) and runs them via `golangci-lint fmt`, so a standalone `goimports` install is no longer needed. If you prefer a pinned, reproducible binary over `go install @latest`, use the official script instead: `curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.12.2`.

If the project is a library and does not need a long-running dev process, skip `air`.

## Copy these files

- `references/gitignore` -> `.gitignore`
- `references/golangci.yml` -> `.golangci.yml`
- `references/lefthook.yml` -> `lefthook.yml`
- `scripts/commit-msg.sh` -> `scripts/commit-msg.sh`

## After copying

```bash
chmod +x scripts/commit-msg.sh
lefthook install
golangci-lint fmt ./...
golangci-lint run ./...
go test -cover ./...
```

Retrofitting an existing repo that still has a v1 `.golangci.yml`? Run `golangci-lint migrate` to convert it (it backs up the original as `.golangci.yml.bck.yml`).
