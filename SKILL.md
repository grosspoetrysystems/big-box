---
name: cable-run-ts
description: >
  Use after rack-mount-ts (or on an existing TypeScript or Node.js
  project) when the user needs to wire up AI/inference architecture.
  "add AI to this project", "wire up inference", "set up model access",
  "add LLM support", "set up structured output",
  "how should I structure the AI layer in TypeScript".
metadata:
  version: "1.0"
  author: whomst
license: MIT
---

# Cable Run TS

Wire the signal chain for AI-capable projects. Rack-mount sets up the physical gear — cable-run connects the inference layer.

## When to use
- Adding AI/LLM capabilities to an existing project
- Setting up structured I/O, model access, or agent workflows
- Choosing between schema libraries, model SDKs, or orchestration patterns
- "How should I structure the AI layer?"

## When NOT to use
- Project setup (use rack-mount first)
- Go projects: use `cable-run-go`
- No AI/inference needs

## The contracts

Cable-run is built on three contracts. Each has a default and alternatives. The contracts are the stable part — the implementations are the cables you swap.

| Contract | What it does | Default | Swap when |
|----------|-------------|---------|-----------|
| **Schema** | Structured I/O validation | Zod | Valibot (bundle size), ArkType (type-level validation) |
| **Model** | LLM access — chat, stream, embed | Vercel AI SDK | Provider-native SDK (direct control), custom wrapper (local inference) |
| **Workflow** | Multi-step orchestration | async functions | Effect (reliability, error channels), OpenAI Agents SDK (multi-agent delegation), durable execution (AI SDK `WorkflowAgent` / Vercel Workflow / Inngest — long-running, crash-safe) |

## Instructions

1. Ask: which contracts does this project need? (most need Schema + Model at minimum)
2. For each contract, use the default unless the user has a specific constraint
3. Read the contract reference in `references/` for the wiring details
4. Create `src/ai/` as the inference home — contracts live here, surfaces import from here
5. Wire the chosen implementations into the contract interfaces

## Contract references

| Contract | Reference |
|----------|-----------|
| Schema | `references/schema.md` |
| Model | `references/model.md` |
| Workflow | `references/workflow.md` |

## Architecture principle

Surfaces (CLI, web, API, MCP) import contracts, not implementations. A surface should never `import { openai } from "@ai-sdk/openai"` directly — it imports from `src/ai/` which resolves the provider behind the contract.

```
src/
  ai/
    schema.ts      ← SchemaAdapter (Zod, Valibot, etc.)
    model.ts       ← ModelAdapter (AI SDK, native SDK, etc.)
    workflow.ts    ← WorkflowAdapter (async, Effect, Agents SDK)
  commands/        ← surface: imports from ai/
  routes/          ← surface: imports from ai/
  server.ts        ← surface: imports from ai/
```

## Decision rule

Use defaults for speed. Swap when optimizing for a named constraint, not preemptively. If you're not sure, use the default — you can swap later because you're building around contracts, not libraries.

## Companion skill

For project setup and dev tooling substrate, see `/rack-mount-ts`.
For Go AI architecture, use the sibling `cable-run-go` skill.
