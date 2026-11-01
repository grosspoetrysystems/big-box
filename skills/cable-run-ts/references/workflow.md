# Workflow Contract

Multi-step orchestration — how inference calls compose into larger behaviors.

## Default: async functions

No extra deps. Plain TypeScript async/await.

```typescript
// src/ai/workflow.ts
import { chat } from "./model.js";

export async function analyzeAndSummarize(input: string) {
  const analysis = await chat(`Analyze: ${input}`);
  const summary = await chat(`Summarize this analysis: ${analysis}`);
  return { analysis, summary };
}
```

Swap when: you need more than sequential calls.

## Opt-in: Effect

```bash
pnpm add effect
```

Swap when: the project already uses Effect or its reliability needs justify the conceptual cost of typed error channels, concurrency control, retries with backoff, dependency injection, or resource management. It is not the default for a simple call/retry path.

```typescript
import { Effect, pipe } from "effect";

const analyze = (input: string) => Effect.succeed(`Analyze: ${input}`);
const summarize = (analysis: string) => Effect.succeed(`Summarize: ${analysis}`);

const workflow = pipe(
  analyze("input"),
  Effect.flatMap(summarize),
  Effect.retry({ times: 3 }),
  Effect.timeout("30 seconds"),
);
```

## Alternative: multi-agent delegation

```bash
pnpm add @openai/agents zod
```

Swap when: you need agents handing off to other agents, tool routing, or guardrails. For a single-agent tool loop, use `ToolLoopAgent` from `ai`. The package is `@openai/agents` (not `@openai/agents-sdk`) and requires Zod v4.

## Alternative: durable execution

Swap when: a workflow is long-running or multi-step and needs to survive crashes — pause/resume, automatic retries, and persisted step state (the "runs for minutes, must not lose progress" case).

- **WorkflowAgent on the Workflow DevKit** — `WorkflowAgent` from `@ai-sdk/workflow` runs on the `workflow` package and adds durable, resumable agent runs to the AI SDK loop. Install both packages; this is one stack, not two alternatives.
- **Inngest / Trigger.dev / Temporal** — choose a separate durable runtime when its deployment and operations model fits the project.

All keep the workflow *definition* in your repo — an upgrade of the Workflow contract's implementation, not a migration away from it.

## Decision guide

| Need | Use |
|------|-----|
| Sequential LLM calls | async functions |
| Error recovery, retries, timeouts | plain async + a retry helper; Effect when already adopted |
| Multi-agent delegation | Agents SDK (`@openai/agents`) |
| Long-running, crash-safe, pause/resume | WorkflowAgent on WDK, Inngest, Trigger.dev, or Temporal |
| All of the above | Keep async for simple paths; combine only the reliability, delegation, and durable-runtime pieces the project actually needs |

## Contract shape

Surfaces call workflow functions, not orchestration primitives. A route handler calls `analyzeAndSummarize()`, not `Effect.runPromise(pipe(...))`.
