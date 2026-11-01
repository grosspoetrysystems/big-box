# Library Surface

## Extra deps
None beyond substrate.

## tsdown.config.ts
```typescript
import { defineConfig } from "tsdown";

export default defineConfig({
  entry: ["src/index.ts"],
  format: ["esm"],
  target: "node24",
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
  "main": "dist/index.mjs",
  "types": "dist/index.d.mts",
  "files": ["dist"]
}
```

## Entry file: src/index.ts
```typescript
export {};
```
