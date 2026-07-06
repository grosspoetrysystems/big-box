# Web (Next.js) Surface

Next.js with the **App Router**, shaped for AI apps. This sits alongside the
TanStack Start surface — pick Next when you want the mainstream React
metaframework; it does not replace `web-tanstack.md`.

## Setup
Use the Next CLI for initial scaffolding (App Router), then layer the substrate:

```bash
pnpm create next-app <project-name> --app --ts
cd <project-name>
```

Then install substrate deps and write substrate config files on top.

## Extra deps
```bash
pnpm add zod
```

## Notes
- Next has its own build system (Turbopack/webpack) — do NOT override with tsdown
- Keep `tsdown.config.ts` only if there's a separate library/CLI entry alongside the app
- `vitest.config.ts` thresholds may need adjustment for app code vs library code
- Substrate configs (biome, lefthook, commitlint, knip) layer cleanly on top

## AI best practices (App Router)
- **Stream from Route Handlers.** Put inference in `app/api/*/route.ts` and
  return a streaming `Response` so the UI renders tokens as they arrive.
- **Server-side keys only.** Call model providers from Route Handlers / Server
  Actions — never expose provider keys to the client.
- **Pick the runtime deliberately.** Edge runtime for low-latency streaming;
  Node runtime when you need full SDKs or filesystem access.
- **Validate I/O with zod.** Schema-check request bodies and tool/function-call
  arguments at the boundary; reject before hitting the model.
- **Cache static prompts.** Reuse system prompts and tool definitions across
  requests to benefit from provider prompt caching.
- For model adapters, schema contracts, and workflow/agent architecture, use the
  companion skill `/cable-run` — don't reinvent inference plumbing here.
