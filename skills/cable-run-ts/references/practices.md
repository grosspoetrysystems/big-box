# AI operations

These are small additions to the three contracts, not a second framework.

## MCP

Consume MCP tools with `@ai-sdk/mcp`; expose servers with the official `@modelcontextprotocol/sdk`. Close clients, authenticate remote servers, and validate host/origin on HTTP transports.

```typescript
import { createMCPClient } from "@ai-sdk/mcp";
import { generateText } from "ai";

const client = await createMCPClient({
  transport: { type: "http", url: "https://example.com/mcp" },
});

try {
  const tools = await client.tools();
  const result = await generateText({
    model: "anthropic/claude-haiku-4-5",
    tools,
    prompt: "Summarize the available data.",
  });
  console.log(result.text);
} finally {
  await client.close();
}
```

## Evals

Start with the existing Vitest setup and a deterministic mock model. Assert behavior and keep prompts and expected outputs versioned with the code. Use promptfoo for provider/model matrices; add a hosted evaluator only when collaboration or long-term result storage is a named requirement.

```typescript
import { generateText } from "ai";
import { MockLanguageModelV4 } from "ai/test";
import { describe, expect, it } from "vitest";

const model = new MockLanguageModelV4({
  doGenerate: {
    content: [{ type: "text", text: "green" }],
    finishReason: { unified: "stop", raw: undefined },
    usage: {
      inputTokens: { total: 1, noCache: 1, cacheRead: 0, cacheWrite: 0 },
      outputTokens: { total: 1, text: 1, reasoning: 0 },
    },
    warnings: [],
  },
});

describe("model behavior", () => {
  it("returns the expected answer", async () => {
    const result = await generateText({ model, prompt: "What color?" });
    expect(result.text).toBe("green");
  });
});
```

## Tracing

Use OpenTelemetry first. Register the AI SDK integration from `@ai-sdk/otel`, export to the collector already used by the service, and use the AI SDK 7 `telemetry` option for function IDs and input/output recording. Disable or redact inputs and outputs at trust boundaries. Langfuse is an optional viewer, not the contract.

```typescript
import { registerTelemetry } from "ai";
import { OpenTelemetry } from "@ai-sdk/otel";

registerTelemetry(new OpenTelemetry());
```

## Prompt caching

Keep prompts named and versioned in the repository. For expensive stable prefixes, use the provider's prompt-cache controls through AI SDK `providerOptions` and keep dynamic content after the stable prefix. Measure cache reads, latency, and cost; caching options are provider-specific, so do not pretend one setting works everywhere. AI SDK middleware is for shared policy such as logging or limits, not a substitute for provider cache configuration.
