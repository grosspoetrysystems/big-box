# Agent Surface

## Extra deps
```bash
pnpm add ai @modelcontextprotocol/sdk zod
```
Add a provider package (`@ai-sdk/openai`, `@ai-sdk/anthropic`, …) only if you need provider-specific options; otherwise a Gateway model string needs no provider dep.

## tsdown.config.ts
```typescript
import { defineConfig } from "tsdown";

export default defineConfig({
  entry: ["src/index.ts"],
  format: "esm",
  target: "node22",
  outDir: "dist",
  clean: true,
  sourcemap: true,
  dts: true,
});
```

## package.json additions
```json
{
  "type": "module",
  "main": "dist/index.js",
  "types": "dist/index.d.ts"
}
```

## Directory structure
```
src/
  index.ts
  agent.ts
  tools/
```

## Entry file: src/index.ts
```typescript
export { createAgent } from "./agent.js";
```

## Starter: src/agent.ts
```typescript
import { generateText } from "ai";

// Gateway-resolved model string — swap providers by changing one string.
const MODEL = "anthropic/claude-haiku-4-5";

export async function createAgent() {
  const result = await generateText({ model: MODEL, prompt: "ready" });
  return result.text;
}
```

## Notes
- Vercel AI SDK provides the unified LLM interface. As of AI SDK 7 (mid-2026) it also ships a first-class `Agent` class and durable `WorkflowAgent` for tool loops — prefer those over hand-rolling a loop around `generateText` when the agent has tools. `generateText`/`streamText` remain the primitives underneath.
- Tool definitions use `inputSchema`/`outputSchema` (renamed from `parameters`/`result` in AI SDK 5).
- MCP SDK for tool/resource server integration
- Zod (v4) for structured I/O validation
- Add `@ai-sdk/anthropic`, `@ai-sdk/google` etc. as needed for multi-provider
- Model IDs move fast — resolve them through the AI Gateway (a provider-prefixed string like `openai/…` or `anthropic/…`) rather than pinning a hardcoded model in code, so a model swap stays a one-string change.
- For multi-agent delegation specifically, the OpenAI Agents SDK is a separate package (`@openai/agents`) — see the `/cable-run` Workflow contract.
