# Model Contract

LLM access — chat, stream, embed, generate structured output.

## Default: Vercel AI SDK

```bash
pnpm add ai
```

Fastest path to multi-provider + streaming. On AI SDK 5+ you can pass a **provider-prefixed model string** and let the AI Gateway resolve it — no per-provider package to install, and a model swap is genuinely one string:

```typescript
// src/ai/model.ts
import { generateText, streamText } from "ai";

const MODEL = "anthropic/claude-haiku-4-5"; // Gateway resolves the provider

export async function chat(prompt: string) {
  const result = await generateText({ model: MODEL, prompt });
  return result.text;
}

export async function* stream(prompt: string) {
  const result = streamText({ model: MODEL, prompt });
  for await (const chunk of result.textStream) {
    yield chunk;
  }
}
```

Prefer the Gateway string over hardcoding a provider instance — model IDs move fast, and this keeps "model = one string" literally true. Install a provider package (`@ai-sdk/openai`, `@ai-sdk/anthropic`, `@ai-sdk/google`) only when you need provider-specific options not exposed through the Gateway.

Version note: AI SDK v7 includes `ToolLoopAgent` as the concrete reusable tool-loop implementation; `Agent` is the interface. Durable `WorkflowAgent` is a separate export from `@ai-sdk/workflow` and runs on the Workflow DevKit. The `chat`/`stream`/`output`/`embed` contract below is unaffected by API churn — which is the point of wrapping it.

## Alternative: Provider-native SDK

```bash
pnpm add @anthropic-ai/sdk openai @google/genai
```

Swap when: you need direct control over the API (custom headers, raw responses, features not yet in AI SDK).

## Alternative: Local inference wrapper

Swap when: running local models via llama.cpp, Ollama, or llama-swap. The wrapper speaks OpenAI-compatible API.

```typescript
// src/ai/model.ts
import { generateText } from "ai";
import { createOpenAICompatible } from "@ai-sdk/openai-compatible";

const local = createOpenAICompatible({
  baseURL: "http://localhost:8080/v1",
  name: "local",
  apiKey: "not-needed",
});

export async function chat(prompt: string) {
  const result = await generateText({
    model: local("model-name"),
    prompt,
  });
  return result.text;
}
```

## Structured output

Use `Output.object` with `generateText` for a complete typed value or with `streamText` for partial objects. In AI SDK 7, the option is `output` and the final value is `result.output`; do not use the deprecated `generateObject`/`streamObject` functions.

```typescript
import { generateText, Output, streamText } from "ai";
import { z } from "zod";

const Reply = z.object({
  answer: z.string(),
  confidence: z.number().min(0).max(1),
});
const MODEL = "anthropic/claude-haiku-4-5";

export async function reply(prompt: string) {
  const result = await generateText({
    model: MODEL,
    output: Output.object({ schema: Reply }),
    prompt,
  });
  return result.output;
}

export async function* streamReply(prompt: string) {
  const result = streamText({
    model: MODEL,
    output: Output.object({ schema: Reply }),
    prompt,
  });
  for await (const partial of result.partialOutputStream) {
    yield partial;
  }
}
```

The schema contract can use the Standard Schema interface so the model adapter does not depend on Zod:

```typescript
import type { StandardSchemaV1 } from "@standard-schema/spec";

export interface Model {
  chat(prompt: string): Promise<string>;
  stream(prompt: string): AsyncIterable<string>;
  output<T>(prompt: string, schema: StandardSchemaV1<unknown, T>): Promise<T>;
  embed(input: string): Promise<number[]>;
}
```

## Contract shape

Surfaces call `chat()`, `stream()`, `output()`, and `embed()` — never construct a model instance directly.
