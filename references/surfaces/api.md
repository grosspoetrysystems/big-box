# API Surface

## Extra deps
```bash
go get github.com/go-chi/chi/v5@latest github.com/go-chi/httplog/v2@latest
```

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
package main

import (
	"log"
	"net/http"

	apphttp "<module-path>/internal/http"
)

func main() {
	addr := ":3000"
	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, apphttp.NewRouter()); err != nil {
		log.Fatal(err)
	}
}
```

## Starter: internal/http/router.go
```go
package http

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/httplog/v2"
)

func NewRouter() http.Handler {
	r := chi.NewRouter()
	r.Use(httplog.RequestLogger(httplog.NewLogger("app", httplog.Options{})))
	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ready"))
	})
	return r
}
```

## Notes
- Use `air` during development for long-running services
- Keep transport concerns in `internal/http/`; push domain logic elsewhere
