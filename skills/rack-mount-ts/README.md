# Rack Mount TS

Bootstrap production-ready TypeScript and Node.js repositories with a complete development substrate.

Rack Mount TS is an opinionated project setup for TypeScript work: libraries, CLIs, APIs, web apps, monorepos, and agentic systems. It gives a repo the boring parts that should be right from day one: strict TypeScript, fast builds, linting, formatting, tests, coverage, hooks, commit rules, and unused-code detection.

## What It Provides

- pnpm for package management
- TypeScript with strict ES2022 ESM defaults
- tsdown for builds
- tsx for local execution
- Biome via Ultracite for linting and formatting
- Vitest with v8 coverage
- Lefthook for Git hooks
- Commitlint for conventional, single-line commits
- Knip for unused files, exports, and dependencies

## Project Shapes

Reference presets live in `references/surfaces/`:

- Library
- CLI
- Agent
- API
- Web app with TanStack
- Web app with Next.js
- Monorepo

## Layout

- `SKILL.md` defines the setup workflow and decision rules.
- `references/` contains copyable config templates.
- `references/surfaces/` contains notes for common repository shapes.

Use this when you want a TypeScript repo to start with working project hygiene instead of accumulating it later.

## Companion skills

Part of a four-skill set — mix and match by language and layer:

| | Project substrate | AI / inference layer |
|---|---|---|
| **TypeScript** | [rack-mount-ts](https://github.com/grosspoetrysystems/rack-mount-ts) | [cable-run-ts](https://github.com/grosspoetrysystems/cable-run-ts) |
| **Go** | [rack-mount-go](https://github.com/grosspoetrysystems/rack-mount-go) | [cable-run-go](https://github.com/grosspoetrysystems/cable-run-go) |

`rack-mount` sets up the project substrate; `cable-run` wires the inference layer on top.
