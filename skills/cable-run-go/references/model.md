# Model Contract

LLM access in Go should stay provider-aware at the adapter layer and provider-agnostic at the surface boundary.

## Default: Official provider SDKs behind a thin local interface

```bash
go get github.com/openai/openai-go/v3@latest
go get github.com/anthropics/anthropic-sdk-go/v2@latest
go get google.golang.org/genai@latest
```

Verified 2026-11-01: the current majors are `openai-go/v3` (the Responses API is its primary surface), `anthropic-sdk-go/v2` (the bare import path still resolves the older v1 line, so pin `/v2`), and `google.golang.org/genai` (the unified Google SDK that replaced the retired `generative-ai-go`). Each exposes native structured-output/auto-parse helpers — prefer those over hand-rolled JSON coercion when a provider offers them, and still validate locally at the adapter boundary per the Schema contract.

```go
// internal/ai/model.go
package ai

import (
	"context"
	"encoding/json"
	"fmt"
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

// GenerateAs runs Generate and decodes the model's JSON reply into T.
// It is the structured-output seam: validate the decoded value against the
// Schema contract before trusting it.
func GenerateAs[T any](ctx context.Context, c Client, req GenerateRequest) (T, error) {
	var out T
	res, err := c.Generate(ctx, req)
	if err != nil {
		return out, err
	}
	if err := json.Unmarshal([]byte(res.Text), &out); err != nil {
		return out, fmt.Errorf("decode structured output: %w", err)
	}
	return out, nil
}
```

Put provider-specific code in `internal/ai/openai`, `internal/ai/anthropic`, and `internal/ai/google`. Surfaces consume the `Client` interface only.

Disable SDK-managed retries when wrapping provider calls and apply your own retry, timeout, and telemetry policy at the adapter boundary.

## Streaming

`Stream` returns `iter.Seq2[Chunk, error]`, so a consumer is an ordinary `for ... range` loop — no channels to close:

```go
func printStream(ctx context.Context, client Client, req GenerateRequest) error {
	for chunk, err := range client.Stream(ctx, req) {
		if err != nil {
			return err
		}
		fmt.Print(chunk.Delta)
		if chunk.Done {
			break
		}
	}
	return nil
}
```

## Tools / MCP

When a model needs to call tools, expose them over the Model Context Protocol with the official SDK rather than inventing a wire format:

```bash
go get github.com/modelcontextprotocol/go-sdk/mcp@latest
```

```go
// cmd/mcpserver/main.go
package main

import (
	"context"
	"log"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

type GreetInput struct {
	Name string `json:"name" jsonschema:"the name of the person to greet"`
}

type GreetOutput struct {
	Greeting string `json:"greeting"`
}

func SayHi(ctx context.Context, req *mcp.CallToolRequest, in GreetInput) (*mcp.CallToolResult, GreetOutput, error) {
	return nil, GreetOutput{Greeting: "Hi " + in.Name}, nil
}

func main() {
	server := mcp.NewServer(&mcp.Implementation{Name: "greeter", Version: "v1.0.0"}, nil)
	mcp.AddTool(server, &mcp.Tool{Name: "greet", Description: "say hi"}, SayHi)
	if err := server.Run(context.Background(), &mcp.StdioTransport{}); err != nil {
		log.Fatal(err)
	}
}
```

The same SDK's `mcp.NewClient` connects to third-party MCP servers. MCP's authorization spec expects explicit user consent around tool calls — keep that gate at the surface, not inside the adapter.

## Telemetry

Emit the standard `gen_ai.*` semantic conventions so traces and token/cost metrics match other instrumented clients. OpenTelemetry ships a Go package for them (`go.opentelemetry.io/otel/semconv/<v>/genaiconv`). The example uses semconv v1.41.0, verified 2026-11-01; create the instrument once and keep the hot path a bare `Record`:

```go
// internal/ai/telemetry.go
package ai

import (
	"context"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/semconv/v1.41.0/genaiconv"
)

type Telemetry struct {
	tokens genaiconv.ClientTokenUsage
}

func NewTelemetry() (*Telemetry, error) {
	tokens, err := genaiconv.NewClientTokenUsage(otel.Meter("internal/ai"))
	if err != nil {
		return nil, err
	}
	return &Telemetry{tokens: tokens}, nil
}

func (t *Telemetry) RecordInputTokens(ctx context.Context, n int64) {
	t.tokens.Record(ctx, n, genaiconv.OperationNameChat, genaiconv.ProviderNameOpenAI, genaiconv.TokenTypeInput)
}
```

## Alternative: Genkit (opt-in)

Use Genkit (`github.com/firebase/genkit/go`) when the team explicitly wants a larger framework with a local developer UI, built-in prompt tooling, and opinionated abstractions.

## Alternative: Google ADK (opt-in)

Use the Google Agent Development Kit (`google.golang.org/adk/v2`) for Google-centered agent graphs with built-in MCP and telemetry. It brings a large cloud/runtime surface, so reach for it only when that cost is justified.

## Alternative: Local inference

For Ollama, llama.cpp, or another local runtime, use its OpenAI-compatible endpoint and keep the same `Client` interface — point `openai-go` at the local base URL instead of importing a server module:

```go
import (
	"github.com/openai/openai-go/v3"
	"github.com/openai/openai-go/v3/option"
)

func localClient() openai.Client {
	return openai.NewClient(option.WithBaseURL("http://localhost:11434/v1"))
}
```

## Contract shape

Surfaces call `Generate`, `Stream`, `Embed`, and the `GenerateAs[T]` structured-output helper. They never construct provider clients directly.
