# Schema Contract

Structured I/O validation is the typed boundary between your Go code and the model.

## Default: Go structs + JSON Schema

Author the contract as Go structs with `json` and `jsonschema` tags. Treat JSON Schema as the wire contract and Go structs as the local authoring surface.

```bash
go get github.com/invopop/jsonschema@latest
go get github.com/santhosh-tekuri/jsonschema/v6@latest
go get github.com/go-playground/validator/v10@latest
```

```go
// internal/ai/schema.go
package ai

import "github.com/invopop/jsonschema"

type UserInput struct {
	Query   string `json:"query" jsonschema:"required,description=User question"`
	Context string `json:"context,omitempty"`
}

func SchemaFor[T any]() any {
	reflector := jsonschema.Reflector{
		AllowAdditionalProperties: false,
		DoNotReference:            true,
	}
	return reflector.Reflect(new(T))
}
```

Use `santhosh-tekuri/jsonschema/v6` to validate model output locally before decoding it into a struct. Use `validator/v10` for domain rules that are not purely part of the wire schema.

## Alternative: CUE

Use CUE when the schema itself is the product architecture: heavy configuration, policy, composition, or shared schema artifacts across systems.

## Contract shape

Surfaces import typed structs and helper functions from `internal/ai/`, not schema libraries directly.
