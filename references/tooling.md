# Go Tooling

Use the native Go toolchain first. Add helper tools only where they remove friction.

## Bootstrap

```bash
go mod init <module-path>
go install github.com/air-verse/air@latest
go install github.com/evilmartians/lefthook@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install golang.org/x/tools/cmd/goimports@latest
```

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
goimports -w .
golangci-lint run ./...
go test -cover ./...
```
