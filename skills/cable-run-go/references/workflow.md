# Workflow Contract

Multi-step orchestration in Go should default to plain Go.

## Default: `context.Context` + small interfaces + `errgroup`

```bash
go get golang.org/x/sync/errgroup@latest
go get golang.org/x/time/rate@latest
go get go.opentelemetry.io/otel@latest
go get github.com/cenkalti/backoff/v7@latest
```

```go
// internal/ai/workflow.go
package ai

import (
	"context"

	"golang.org/x/sync/errgroup"
)

func AnalyzeAndSummarize(ctx context.Context, client Client, input string) (Result, Result, error) {
	g, ctx := errgroup.WithContext(ctx)
	var analysis Result
	var summary Result

	g.Go(func() error {
		var err error
		analysis, err = client.Generate(ctx, GenerateRequest{
			System: "Analyze the input",
			Messages: []Message{
				{Role: "user", Content: input},
			},
		})
		return err
	})
	g.Go(func() error {
		var err error
		summary, err = client.Generate(ctx, GenerateRequest{
			System: "Summarize the input",
			Messages: []Message{
				{Role: "user", Content: input},
			},
		})
		return err
	})

	if err := g.Wait(); err != nil {
		return Result{}, Result{}, err
	}
	return analysis, summary, nil
}
```

The two model calls are independent, so this is genuine parallel fan-out rather than a dependent call wrapped in a goroutine. Use `context.WithTimeout` for deadlines, `rate.Limiter` for backpressure, and `backoff/v7` for retries (verified 2026-11-01). Use OpenTelemetry's `genaiconv` package for standard GenAI spans and token/cost metrics.

## Evals with plain `go test`

Keep evals close to the contract and use a fake model for deterministic tests. Ordinary table tests or golden files are enough; add an LLM-as-judge helper only when a human-labeled rubric cannot cover the behavior.

```go
// internal/ai/eval_test.go
package ai

import (
	"context"
	"iter"
	"testing"
)

type fakeClient struct{}

func (fakeClient) Generate(context.Context, GenerateRequest) (Result, error) {
	return Result{Text: `{"answer":"ok"}`}, nil
}

func (fakeClient) Stream(context.Context, GenerateRequest) iter.Seq2[Chunk, error] {
	return func(yield func(Chunk, error) bool) {
		yield(Chunk{Delta: "ok", Done: true}, nil)
	}
}

func (fakeClient) Embed(context.Context, []string) ([][]float32, error) {
	return [][]float32{{1}}, nil
}

func TestAnswerEval(t *testing.T) {
	got, err := GenerateAs[struct {
		Answer string `json:"answer"`
	}](context.Background(), fakeClient{}, GenerateRequest{
		Messages: []Message{{Role: "user", Content: "answer"}},
	})
	if err != nil {
		t.Fatal(err)
	}
	if got.Answer != "ok" {
		t.Fatalf("answer = %q, want %q", got.Answer, "ok")
	}
}
```

Run this with `go test ./...`; no paid model call is needed.

## Durable alternatives

Use Temporal when the workflow must survive process restarts, run for hours or days, or wait on human approval. Use DBOS (`github.com/dbos-inc/dbos-transact-golang`) when you want lighter library-embedded durable execution backed by SQLite or Postgres. Both are deliberate deviations from the plain-Go default.

## Typed graph alternative (evaluate)

Evaluate Eino (`github.com/cloudwego/eino`) when typed graph workflows and checkpoint/resume behavior are more important than minimal surface area. Pin and test the version you choose; it is not the default contract.


## Larger agent frameworks (opt-in)

Use Genkit (`github.com/firebase/genkit/go`) when the team explicitly wants local prompt/eval tooling. Use the Google Agent Development Kit (`google.golang.org/adk/v2`) for Google-centered agent graphs with MCP and telemetry. Both add runtime and dependency surface; choose them only for a concrete requirement.

## Contract shape

Surfaces call workflow functions, not framework primitives. Keep orchestration logic inside `internal/ai/`.
