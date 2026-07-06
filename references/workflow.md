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

## Alternative: Effect

```bash
pnpm add effect
```

Swap when: you need typed error channels, concurrency control, retries with backoff, dependency injection, or resource management. Production reliability layer.

```typescript
import { Effect, pipe } from "effect";

const workflow = pipe(
  analyze(input),
  Effect.flatMap(summarize),
  Effect.retry({ times: 3 }),
  Effect.timeout("30 seconds"),
);
```

## Alternative: OpenAI Agents SDK

```bash
pnpm add @openai/agents zod
```

Swap when: you need multi-agent delegation — agents handing off to other agents, tool routing, guardrails. The orchestration framework for complex agent systems. Package is `@openai/agents` (not `@openai/agents-sdk`) and requires Zod v4.

## Alternative: durable execution

Swap when: a workflow is long-running or multi-step and needs to survive crashes — pause/resume, automatic retries, and persisted step state (the "runs for minutes, must not lose progress" case).

- **AI SDK `WorkflowAgent`** (built into AI SDK 7, mid-2026) — durable agent runs with first-class timeouts and tool approvals, no extra service. Reach for this first if you're already on the AI SDK.
- **Vercel Workflow (WDK)** — durable steps that ship with the same deploy; the managed service only holds queue/retry/step state.
- **Inngest / Trigger.dev** — same shape from a third-party runtime.

All keep the workflow *definition* in your repo — an upgrade of the Workflow contract's implementation, not a migration away from it.

## Decision guide

| Need | Use |
|------|-----|
| Sequential LLM calls | async functions |
| Error recovery, retries, timeouts | Effect |
| Multi-agent delegation | Agents SDK (`@openai/agents`) |
| Long-running, crash-safe, pause/resume | durable execution (AI SDK `WorkflowAgent`, Vercel Workflow, Inngest) |
| All of the above | Effect for the operational layer, Agents SDK for delegation, a durable runtime for long jobs, async for simple paths |

## Contract shape

Surfaces call workflow functions, not orchestration primitives. A route handler calls `analyzeAndSummarize()`, not `Effect.runPromise(pipe(...))`.
