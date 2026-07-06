# Schema Contract

Structured I/O validation — the typed boundary between your code and the outside world.

## Default: Zod (v4)

```bash
pnpm add zod
```

Best general DX, largest ecosystem, native AI SDK integration, works everywhere. Zod 4 (stable since 2025) is much faster and lighter than v3 (~14× faster parsing, ~57% smaller core), and ships `@zod/mini` (`import * as z from "zod/mini"`) when you need a tree-shakeable subset for edge/browser bundles. The AI SDK and OpenAI Agents SDK both target Zod v4.

```typescript
// src/ai/schema.ts
import { z } from "zod";

export const UserInput = z.object({
  query: z.string(),
  context: z.string().optional(),
});

export type UserInput = z.infer<typeof UserInput>;
```

## Alternative: Valibot

```bash
pnpm add valibot
```

Swap when: bundle size is the primary constraint and `@zod/mini` isn't enough. Valibot's modular design tree-shakes to under ~1KB for simple schemas. Same mental model, different internals. (With Zod 4's `@zod/mini` the gap is smaller than it was against Zod 3 — reach for Valibot when bundle size genuinely dominates, e.g. large schemas in a browser/edge bundle.)

## Alternative: ArkType

```bash
pnpm add arktype
```

Swap when: you want type-level validation that catches errors at compile time, not runtime. More advanced, steeper learning curve.

## Contract shape

Whatever library you use, the surface should import a typed schema, not the library:

```typescript
// surfaces import this, not zod/valibot/arktype directly
export type { UserInput } from "../ai/schema.js";
export { UserInput as UserInputSchema } from "../ai/schema.js";
```
