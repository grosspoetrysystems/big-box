# Library Surface

## Extra deps
None beyond the substrate.

## Directory structure
```
pkg/
  <package>/
    <package>.go
internal/
  testutil/
```

## Starter: pkg/<package>/<package>.go
```go
package <package>

type Service struct{}

func New() Service {
	return Service{}
}
```

## Notes
- Keep the public API in `pkg/`
- Put helpers and unstable implementation details under `internal/`
- Export the smallest surface you can defend
