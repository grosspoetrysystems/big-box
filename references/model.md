# Model Contract

LLM access in Go should stay provider-aware at the adapter layer and provider-agnostic at the surface boundary.

## Default: Official provider SDKs behind a thin local interface

```bash
go get github.com/openai/openai-go/v3@latest
go get github.com/anthropics/anthropic-sdk-go@latest
go get google.golang.org/genai@latest
```

```go
// internal/ai/model.go
package ai

import (
	"context"
	"iter"
)

type Message struct {
	Role    string
	Content string
}

type GenerateRequest struct {
	System   string
	Messages []Message
}

type Result struct {
	Text string
}

type Chunk struct {
	Delta string
	Done  bool
}

type Client interface {
	Generate(ctx context.Context, req GenerateRequest) (Result, error)
	Stream(ctx context.Context, req GenerateRequest) iter.Seq2[Chunk, error]
	Embed(ctx context.Context, texts []string) ([][]float32, error)
}
```

Put provider-specific code in `internal/ai/openai`, `internal/ai/anthropic`, and `internal/ai/google`. Surfaces consume the `Client` interface only.

Disable SDK-managed retries when wrapping provider calls and apply your own retry, timeout, and telemetry policy at the adapter boundary.

## Alternative: Genkit

Use Genkit when the team explicitly wants a larger framework with a local developer UI, built-in prompt tooling, and opinionated abstractions.

## Alternative: Local inference wrapper

Use a local adapter when the project targets Ollama, llama.cpp, or another OpenAI-compatible local runtime. Keep the same `Client` interface.

## Contract shape

Surfaces call `Generate`, `Stream`, `Embed`, and structured-output helpers. They never construct provider clients directly.
