# Web (Astro 7) Surface

Astro is an optional static-content surface for documentation, marketing, and
content-heavy sites. Keep Astro's own build system; do not add tsdown for the
app.

## Setup

Use the Astro CLI for initial scaffolding, then layer the substrate:

```bash
pnpm create astro <project-name>
cd <project-name>
npx ultracite init --pm pnpm --linter oxlint --frameworks astro
```

## Extra deps

Tailwind 4 uses the Vite plugin directly:

```bash
pnpm add -D @tailwindcss/vite tailwindcss
```

## astro.config.mjs

```javascript
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "astro/config";

export default defineConfig({
  output: "static",
  vite: {
    plugins: [tailwindcss()],
  },
});
```

## src/styles/global.css

```css
@import "tailwindcss";
```

Import the stylesheet from the shared layout used by each page. Astro emits
static HTML and assets into `dist/`; deploy that directory to any static host.

## Notes

- Astro owns the app build and routing; do not override it with tsdown.
- Keep `tsdown.config.ts` only for a separate library or CLI entry.
- Use `@astrojs/sitemap` or other integrations only when the site needs them.
- Keep provider keys and other server-only secrets out of static page code.
