# CLI Surface

## Framework
Incur is the default CLI framework for agent-aware commands. It provides typed
schemas, structured output, MCP exposure, generated skills, and machine-readable
command manifests. Keep Ink when the CLI needs interactive terminal rendering.

For a minimal human-first CLI, Commander is a valid lower-opinion alternative:

```bash
pnpm add commander
```

Do not install Commander and incur unless the project has a deliberate reason to
use both.

## Extra deps
```bash
pnpm add incur
```

Add Ink only for interactive terminal UIs:

```bash
pnpm add ink @inkjs/ui
pnpm add -D @types/ink
```

## tsdown.config.ts
```typescript
import { defineConfig } from "tsdown";

export default defineConfig({
  entry: { cli: "src/bin/cli.ts" },
  format: "esm",
  target: "node22",
  outDir: "dist",
  clean: true,
  sourcemap: true,
  banner: { js: "#!/usr/bin/env node" },
});
```

## package.json additions
```json
{
  "type": "module",
  "bin": {
    "<project-name>": "dist/cli.js"
  }
}
```

## Directory structure
```
src/
  bin/
    cli.ts
  commands/
```

## Entry file: src/bin/cli.ts
```typescript
import { Cli, z } from "incur";

const cli = Cli.create("<project-name>", {
  version: "0.1.0",
  description: "<description>",
});

cli.command("status", {
  output: z.object({
    ready: z.boolean(),
  }),
  run() {
    return { ready: true };
  },
});

cli.serve();
```

## Scripts override
```json
{
  "dev": "tsx src/bin/cli.ts"
}
```
