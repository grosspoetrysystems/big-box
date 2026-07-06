# Workflow Contract

Multi-step orchestration in Go should default to plain Go.

## Default: `context.Context` + small interfaces + `errgroup`

```bash
go get golang.org/x/sync/errgroup@latest
go get golang.org/x/time/rate@latest
go get go.opentelemetry.io/otel@latest
go get github.com/cenkalti/backoff/v5@latest
```

```go
// internal/ai/workflow.go
package ai

import (
	"context"

	"golang.org/x/sync/errgroup"
)

func AnalyzeAndSummarize(ctx context.Context, client Client, input string) (Result, Result, error) {
	var analysis Result
	var summary Result

	analysis, err := client.Generate(ctx, GenerateRequest{
		System: "Analyze the input",
		Messages: []Message{
			{Role: "user", Content: input},
		},
	})
	if err != nil {
		return Result{}, Result{}, err
	}

	g, ctx := errgroup.WithContext(ctx)
	g.Go(func() error {
		var err error
		summary, err = client.Generate(ctx, GenerateRequest{
			System: "Summarize the analysis",
			Messages: []Message{
				{Role: "user", Content: analysis.Text},
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

Use `context.WithTimeout` for deadlines, `rate.Limiter` for backpressure, `backoff/v5` for retries, and OpenTelemetry for spans and token/cost metrics.

## Alternative: Temporal

Use Temporal when the workflow must survive process restarts, run for hours or days, or wait on human approval.

## Alternative: Eino

Use Eino when typed graph workflows and checkpoint/resume behavior are more important than minimal surface area.

## Contract shape

Surfaces call workflow functions, not framework primitives. Keep orchestration logic inside `internal/ai/`.
