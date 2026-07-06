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

Version note: AI SDK is at v7 as of mid-2026 (v5 was the big architectural break — SSE streaming, `inputSchema`/`outputSchema` for tools, `UIMessage`/`ModelMessage` split; v7 adds the `Agent`/`WorkflowAgent` classes). The `chat`/`stream`/`embed` contract below is unaffected by that churn — which is the point of wrapping it.

## Alternative: Provider-native SDK

```bash
pnpm add @anthropic-ai/sdk    # or openai, @google/generative-ai
```

Swap when: you need direct control over the API (custom headers, raw responses, features not yet in AI SDK).

## Alternative: Local inference wrapper

Swap when: running local models via llama.cpp, Ollama, or llama-swap. The wrapper speaks OpenAI-compatible API.

```typescript
// src/ai/model.ts
import { createOpenAI } from "@ai-sdk/openai";

const local = createOpenAI({
  baseURL: "http://localhost:8080/v1",
  apiKey: "not-needed",
});

export async function chat(prompt: string) {
  // same AI SDK interface, local inference
}
```

## Contract shape

Surfaces call `chat()`, `stream()`, `embed()` — never construct a model instance directly.
