# API Surface

## Extra deps
```bash
pnpm add hono @hono/node-server zod
```

## tsdown.config.ts
```typescript
import { defineConfig } from "tsdown";

export default defineConfig({
  entry: ["src/server.ts"],
  format: "esm",
  target: "node24",
  outDir: "dist",
  clean: true,
  sourcemap: true,
});
```

## package.json additions
```json
{
  "type": "module"
}
```

## Directory structure
```
src/
  server.ts
  routes/
```

## Entry file: src/server.ts
```typescript
import { serve } from "@hono/node-server";
import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => c.json({ status: "ready" }));

serve({ fetch: app.fetch, port: 3000 }, (info) => {
  console.log(`listening on :${info.port}`);
});

export default app;
```

## Scripts override
```json
{
  "dev": "tsx --watch src/server.ts",
  "start": "node dist/server.js"
}
```

## Notes
- Hono for the HTTP layer — works on Node, Deno, Bun, Cloudflare Workers
- Effect is optional for the operational core when the service needs typed errors, concurrency, dependency injection, or tracing.
- Zod for request/response validation
- Add `effect` only when that runtime model is a deliberate choice.
