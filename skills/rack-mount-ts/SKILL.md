---
name: rack-mount-ts
description: >
  Use when the user wants to set up or retrofit a TypeScript or Node.js
  project with a production-grade dev stack. "set up a project",
  "init a repo", "add linting and testing", "modernize this tooling",
  "scaffold a TS project", "scaffold a Node project",
  "what tooling should I use for TypeScript".
metadata:
  version: "2.0"
  author: Gross Poetry Systems
license: MIT
---

# Rack Mount TS

Production-grade TypeScript project substrate. You bring the idea, this skill racks it in.

## When to use
- New TypeScript project
- Retrofitting an existing project with missing tooling
- Upgrading a dev stack to current practices

## When NOT to use
- Non-TypeScript projects
- Go projects: use rack-mount-go
- User explicitly wants a different stack

## The substrate

Every project gets these layers. Config templates are in `references/`. Resolve
each version at install time (`pnpm add` without a pin takes the current
release) rather than trusting numbers written in prose.

| Layer | Tool |
|-------|------|
| Package manager | pnpm |
| Language | TypeScript (strict, ESM) |
| Build | tsdown |
| Dev runner | tsx |
| Lint/format | oxlint + oxfmt via Ultracite |
| Test | Vitest + v8 coverage |
| Git hooks | Lefthook |
| Commits | Commitlint (conventional, single-line) |
| Unused code | Knip |

The substrate install includes oxlint, oxfmt, and ultracite. `ultracite init`
owns their project setup: it selects oxlint, writes `oxlint.config.*` /
`oxfmt.config.*`, and migrates an existing ESLint/Prettier/Biome config out of
the way. The other layers are copied from `references/`.

Node floor: `engines.node` `>=24.11`; exercise Node 26 in CI as well.

> **Build note:** tsdown (Rolldown-based) is the default bundler, and converts an
> existing tsup setup with `npx tsdown-migrate`. tsup is still maintained, so a
> stable project already on it has no reason to switch; new projects start on
> tsdown. tsdown emits `.mjs` / `.d.mts` for ESM output — point
> `main`/`types`/`bin` at those extensions.

## Surfaces (recommended, not required)

The substrate is the product. Surfaces are opinionated starting points for
common project types — use them, adapt them, or ignore them entirely. Presets
are in `references/surfaces/`.

| Surface | Reference |
|---------|-----------|
| Library | `surfaces/library.md` |
| CLI | `surfaces/cli.md` |
| Agent | `surfaces/agent.md` |
| API | `surfaces/api.md` |
| Web (TanStack) | `surfaces/web-tanstack.md` |
| Web (Next.js) | `surfaces/web-next.md` |
| Web (Astro) | `surfaces/web-astro.md` |
| Monorepo | `surfaces/monorepo.md` |

## Instructions

### Greenfield
1. Ask what you're building (surface menu above).
2. `git init` first — Lefthook's `prepare` script needs a git repo.
3. Copy `references/pnpm-workspace.example.yaml` to `pnpm-workspace.yaml`
   *before* installing, so pnpm is allowed to run Lefthook's and esbuild's build
   scripts.
4. Install the substrate:
   ```bash
   pnpm add -D typescript tsdown tsx vitest @vitest/coverage-v8 \
     lefthook @commitlint/cli @commitlint/config-conventional knip @types/node \
     ultracite oxlint oxfmt
   npx ultracite init --pm pnpm --linter oxlint --frameworks vitest --integrations lefthook
   ```
   Add surface frameworks to the `--frameworks` list (`react`, `next`, `astro`,
   …). Leave off `-y` to review each change interactively.
5. Copy the remaining configs from `references/`: `tsconfig.json`,
   `vitest.config.ts`, `lefthook.yml`, `commitlint.config.js`, `knip.config.ts`,
   and `gitignore` → `.gitignore`. Add the chosen surface's deps and scripts.
6. `pnpm lefthook install`, create the entry file, run the gate, then commit.

Recommended `package.json` scripts:
```json
{
  "build": "tsdown",
  "lint": "ultracite check",
  "fix": "ultracite fix",
  "typecheck": "tsc --noEmit",
  "test": "vitest run --coverage",
  "knip": "knip",
  "prepare": "lefthook install"
}
```

Gate before committing: `pnpm lint && pnpm typecheck && pnpm test && pnpm knip`.

### Retrofit
Detect first, then converge — don't overwrite blindly.
1. Inventory what exists:
   - Linter/formatter: `eslint.config.*`, `.eslintrc*`, `.prettierrc*`, `biome.json*`.
   - Hooks: `.husky/`, `simple-git-hooks`, `lint-staged`, an existing `lefthook.yml`.
   - Build/test/types: `tsup.config.*`, `vite.config.*`, `vitest.config.*`,
     Jest/Mocha configs, `tsconfig*.json`, and the package-manager lockfile.
2. If the lint tools are absent, install them first:
   `pnpm add -D ultracite oxlint oxfmt`. Then run `ultracite init`
   interactively. It migrates an existing ESLint/Prettier/Biome config to
   oxlint/oxfmt and drops their dependencies; review the plan before accepting.
3. Converge the leftovers by hand:
   - Rewrite stale `lint`/`format` scripts to `ultracite check` / `ultracite fix`.
   - Replace Husky with Lefthook: delete `.husky/`, set `prepare` to
     `lefthook install`, and run
     `lefthook install --reset-hooks-path` when Husky left
     `core.hooksPath` configured. Copy `lefthook.yml`, add Commitlint, and keep
     one hook dispatcher only.
   - Convert `tsup.config.ts` with `npx tsdown-migrate`; leave a framework-owned
     build (Next/TanStack/Astro) in place.
   - Add any missing substrate piece (Knip, coverage thresholds, `@types/node`).
4. Run the full gate and a real commit; fix whatever the checks report.

## Vite+ (alternative toolchain)

Vite+ (`vite-plus`) folds lint, format, type-check, test, build, task running,
and hooks into one `vite.config.ts` and the `vp` CLI: `vp check` (oxlint + oxfmt
+ tsgo type checks), `vp test` (Vitest), `vp pack` (tsdown), `vp run` (cached
tasks), and `vp hooks` / `vp staged`. It runs the same engines as the à-la-carte
substrate, so the opinions above still hold.

Install it with `pnpm add -D vite-plus`, then use `vp migrate` to preview the
conversion before accepting it.
Reach for it when one tool beats eight — new Vite apps, libraries, or monorepos.
Keep the à-la-carte substrate for Node-only APIs/CLIs and for framework-owned
builds. Migration preserves an existing Lefthook/Husky setup and leaves
commit-message rules to Commitlint — don't stack two hook dispatchers.

## Companion skill

For the AI/inference layer (model adapters, schema contracts, agent and workflow
patterns), see the companion skill
[cable-run-ts](https://github.com/grosspoetrysystems/big-box/tree/main/skills/cable-run-ts).
For Go projects, use the sibling
[rack-mount-go](https://github.com/grosspoetrysystems/big-box/tree/main/skills/rack-mount-go).
