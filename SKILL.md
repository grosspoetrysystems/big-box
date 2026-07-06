---
name: cable-run-go
description: >
  Use after rack-mount-go (or on an existing Go project) when the user
  needs to wire up AI/inference architecture. "add AI to this Go
  project", "wire up inference in Go", "set up model access in Go",
  "add LLM support", "set up structured output", "how should I structure
  the AI layer in Go".
metadata:
  version: "1.0"
  author: whomst
license: MIT
---

# Cable Run Go

Wire the signal chain for AI-capable Go projects. Rack-mount-go sets up the project substrate — cable-run-go connects the inference layer.

## When to use
- Adding AI/LLM capabilities to an existing Go project
- Setting up structured I/O, model access, embeddings, or agent-like workflows in Go
- Choosing between schema tooling, provider SDKs, or orchestration patterns
- "How should I structure the AI layer in Go?"

## When NOT to use
- Project setup (use rack-mount-go first)
- Non-Go projects
- No AI/inference needs

## The contracts

Cable-run-go is built on three contracts. Each has a default and named deviations. The contracts are stable; the adapters are the cables you swap.

| Contract | What it does | Default | Swap when |
|----------|-------------|---------|-----------|
| **Schema** | Structured I/O validation | Go structs + JSON Schema | CUE when schema-first configuration is the product |
| **Model** | LLM access — chat, stream, structured output, embed | Official provider SDKs behind a thin local interface | Genkit when you explicitly want a larger framework |
| **Workflow** | Multi-step orchestration | `context.Context` + small interfaces + `errgroup` | Temporal for durable execution, Eino for typed graph workflows |

## Instructions

1. Ask: which contracts does this project need? (most need Schema + Model at minimum)
2. Use the defaults unless the user has a named constraint
3. Read the contract reference in `references/` for the wiring details
4. Create `internal/ai/` as the inference home — contracts live here, surfaces import from here
5. Wire the chosen implementations into the contract interfaces
6. Add local validation, timeouts, retries, and telemetry at the adapter boundary

## Contract references

| Contract | Reference |
|----------|-----------|
| Schema | `references/schema.md` |
| Model | `references/model.md` |
| Workflow | `references/workflow.md` |

## Architecture principle

Surfaces (CLI, API, web, worker) import contracts, not provider SDKs. A handler should never construct an OpenAI, Anthropic, or Gemini client directly — it imports from `internal/ai/`, which resolves the provider behind the contract.

```text
internal/
  ai/
    schema.go       <- SchemaFor[T], Parse[T]
    model.go        <- Client interface, request/response types
    workflow.go     <- orchestration helpers and agent loop
    openai/         <- adapter
    anthropic/      <- adapter
    google/         <- adapter
  http/             <- surface: imports from ai/
  cli/              <- surface: imports from ai/
```

## Decision rule

Use defaults for speed. Deviate only when a concrete requirement forces it:
- durable workflows -> Temporal
- framework UX / local prompt tooling -> Genkit
- typed graph orchestration -> Eino

If you're not sure, keep the default. The point is to own the interfaces and swap adapters later.

## Companion skill

For project setup and Go tooling substrate, see `/rack-mount-go`.
