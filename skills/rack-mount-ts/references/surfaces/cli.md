# CLI Surface

## Framework

Commander is the default for a small, human-first CLI:

```bash
pnpm add commander
```

Use Incur when the CLI is agent-native and needs typed schemas, structured
output, MCP exposure, generated skills, or machine-readable command manifests:

```bash
pnpm add incur
```

Keep Ink only when the CLI needs interactive terminal rendering:

```bash
pnpm add ink @inkjs/ui
```

Do not install Commander and Incur unless the project has a deliberate reason to
use both. Ink provides its own types; do not add an `@types/ink` stub.

## tsdown.config.ts

```typescript
import { defineConfig } from "tsdown";

export default defineConfig({
  banner: { js: "#!/usr/bin/env node" },
  clean: true,
  entry: { cli: "src/bin/cli.ts" },
  format: "esm",
  outDir: "dist",
  sourcemap: true,
  target: "node24",
});
```

## package.json additions

```json
{
  "type": "module",
  "bin": {
    "<project-name>": "dist/cli.mjs"
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
import { Command } from "commander";

const program = new Command();

program
  .name("<project-name>")
  .description("<description>")
  .version("0.1.0");

program
  .command("status")
  .description("report readiness")
  .action(() => {
    process.stdout.write("ready\n");
  });

program.parse();
```

## Scripts override

```json
{
  "dev": "tsx src/bin/cli.ts"
}
```
