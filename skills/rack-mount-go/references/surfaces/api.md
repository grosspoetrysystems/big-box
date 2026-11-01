# API Surface

## Extra deps
None for the starter. Go 1.22+ `http.ServeMux` handles method and wildcard
routing without a router dependency. When route grouping or middleware needs a
third-party router, add chi:

```bash
go get github.com/go-chi/chi/v5@v5.5.0
```

The starter uses the standard-library `log/slog`; add a logging dependency only
when the service has a concrete need beyond it.

## Directory structure
```
cmd/
  server/
    main.go
internal/
  http/
    router.go
    handlers/
```

## Entry file: cmd/server/main.go
```go
// Package main runs the HTTP server.
package main

import (
	"log/slog"
	"net/http"
	"os"
	"time"

	apphttp "<module-path>/internal/http"
)

func main() {
	addr := ":3000"
	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	server := &http.Server{
		Addr:              addr,
		Handler:           apphttp.NewRouter(logger),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      10 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	logger.Info("listening", "addr", addr)
	if err := server.ListenAndServe(); err != nil {
		logger.Error("server stopped", "error", err)
		os.Exit(1)
	}
}
```

## Starter: internal/http/router.go
```go
// Package http owns the API transport.
package http

import (
	"log/slog"
	"net/http"
)

func NewRouter(logger *slog.Logger) http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		logger.Info("request", "method", r.Method, "path", r.URL.Path)
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ready\n"))
	})
	return mux
}
```

## Notes
- Use `air` during development for long-running services.
- Keep transport concerns in `internal/http/`; push domain logic elsewhere.
- Keep the server timeouts explicit; add graceful shutdown when lifecycle
  management is introduced.
