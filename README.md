# OMP model roles: a reasoned setup you can adapt

**Snapshot: 2026-11-14 · v44** (verified on omp 18.18.8). Stale after ~4-6 weeks, or right away if
a model below is missing from `omp models`.

This is the owner's [OMP](https://github.com/can1357/oh-my-pi) role and fallback configuration
([model-roles.yml](model-roles.yml)), with the reasoning behind every pick. It assumes seven logins.
If your subscriptions differ, don't copy it as-is: keep the reasoning and swap the models, as
described below. The **built-in roles** are the part worth reusing. The **custom roles** and agents
fit the owner's own workflow and are optional.

## Quick start: let your OMP do it

Open OMP in a clone of this repo and paste:

```text
Read README.md and follow its "Instructions for OMP" section. My subscriptions are:
<e.g. Claude Pro, ChatGPT Plus, no Google, no API keys>. Propose my setup, ask me
whether I want the optional custom roles, and apply nothing until I confirm.
```

## Instructions for OMP

1. **Inventory, read-only:** run `omp usage`, `omp models`, `omp models --kind judge`,
   `omp models --kind image`, `omp config get modelRoles --json`, and
   `omp config get retry.fallbackChains --json`. Only providers that show up there are usable.
2. **Built-in roles:** for each row of [the reference setup](#the-reference-setup-built-in-roles),
   keep the model if the user has its login. Otherwise follow
   [Swapping models by login](#swapping-models-by-login), and keep the [principles](#principles).
   If a referenced model is no longer in the catalog, substitute the closest current model from
   the same provider and tier, and say so.
3. **Custom roles:** explain [the optional custom roles](#optional-the-owners-custom-roles) in
   one line each, and include them only if the user says yes.
4. **Propose:** show the user's complete overlay as YAML in the same shape as `model-roles.yml`,
   with one line of reasoning per role and a list of everything dropped or substituted.
5. **Apply only after explicit confirmation:** merge the keys into the user's `config.yml`
   (see [Install](#install)) without touching unrelated settings. Never change logins, buy
   plans, or add API credit. Then run [Verify](#verify).

## Principles

- **Put the heavy roles on the biggest pool.** Each subscription has its own 5-hour/weekly meters.
  Here Claude Max 5x is the workhorse. Frequent, cheap work (commit messages, titles, widgets)
  goes to small models so it doesn't drain the expensive pool.
- **Alternate providers in a fallback chain.** Hops on the same provider share one quota, so a
  depleted meter would take them all out together. Most chains use one entry per provider.
- **Match the tier.** Deep roles fall back to the depth model on each other subscription; cheap
  roles fall back to cheap models.
- **Review with a different model family than the author.** Claude writes the code, GPT reviews
  it (see the custom roles).
- **Measure in OMP, not on leaderboards.** Speeds below come from OMP tool-task probes on the
  owner's machine; the evidence is in [OWNER-NOTES.md](OWNER-NOTES.md) and `research/`.
- **Let OMP skip depleted accounts.** `retry.usageAwareFallback: true` with
  `usageReservePolicy: auto` skips an account that is near its limit before calling it.

## The reference setup (built-in roles)

| Role | Used by OMP for | Primary → fallbacks | Why |
|---|---|---|---|
| `default` | the main session | GLM-5.3 (`mistral/zai-glm-5-3`) → Sonnet 5.5 | Fastest in the OMP tool probe (7.6 s vs 21.6/34.6 s for Gemini 3.8 Flash low/high, ~9 s for Sonnet), and it keeps everyday turns off the Claude pool. It is text-only, so images go through `vision`. |
| `smol` | prewalk / plan-yolo execution target, Ctrl+P cycle, agents bound to `@smol` | Sonnet 5.5 → GLM-5.3 Flash → GPT-6 Luna → Grok Build | Here `smol` implements after Opus has planned, so it needs a capable model. With a small main pool, use GLM-5.3 Flash or Luna instead. |
| `slow` | deep reasoning (`@slow`), the `architect` agent | Opus 5.5 → Sol 6.1 → Grok 4.7 | Strongest depth model on the largest pool. Each fallback is the depth model of another subscription. |
| `plan` | the model used while plan mode is active | same chain as `slow` | Planning gets the same depth as `slow`. |
| `task` | `task` subagents | Sonnet 5.5 → Sol 6.1 → GLM-5.3 → Grok Build | Kept over GLM-5.3 and Gemini 3.8 Flash after a head-to-head ([research](research/TASK-ROLE-EVALUATION.md)). |
| `vision` | answering image questions for text-only models (`read` on an image) | Sonnet 5.5 → Sol 6.1 → Mistral Large 4 → Grok 4.7 | Reads images natively, so `read` on an image works for text-only default models. |
| `commit` | `omp commit` messages | Haiku 5.5 (low) → Luna → Grok Build | 5.6 s vs 44.8 s for Grok Build on the same commit. Short, bounded work. |
| `tiny` | session titles and small jobs; `sonic` subagents (override below) | Haiku 5.5 (low) → GLM-5.3 Flash → Luna → Grok Composer 2.5 Fast | Cheapest capable model for frequent tiny calls. |
| `widget` | live widgets for background jobs | Haiku 5.5 (low) → Grok Composer 2.5 Fast | If unassigned, it resolves like `smol` (Sonnet), which is wasteful for status widgets. |
| `advisor` | the per-turn advisor, **only if `advisor.enabled`** (off by default and here) | Haiku 5.5 (low) → Luna → Grok Build | A cheap reviewer. It does nothing unless you enable it. |
| `judge` | semantic `find`, the `auto` thinking level, auto-prewalk, `judge()` in eval, smart stop detection | TypeSafe Jev 1.14 → OpenRouter Jev 1.14 → Jev 1.13 → Liquid d1.1 | Needs a native judgment API. No chat subscription includes one; see [Judge options](#judge-options). |

Overrides: `task.agentModelOverrides.sonic: "@tiny"` sends bundled `sonic` workers to Haiku
instead of Sonnet.

Other settings in the overlay:
- `extendedContext: false` caps Codex Sol at 500K, Luna at 272K, and Haiku at 100K to limit quota
  burn; 1M-context models are unaffected.
- `compaction.modelThresholds` compacts GLM-5.3 at 150k, because turning off extended context
  doesn't shrink GLM's 1M window.
- `defaultThinkingLevel: auto` lets the judge pick the thinking effort per prompt.
- `update.auto: false` because an automatic update (omp 18.18.6) once dropped the
  `google-antigravity` provider; update deliberately instead.
- `generate_image.enabled: true` turns on image generation; no `image` role is set, so OMP picks the image model itself.
- `cycleOrder` sets the Ctrl+P order: `smol`, `default`, `slow`, `sage`.

## Swapping models by login

| Login (owner's plan) | What it carries here | Without it |
|---|---|---|
| `anthropic` (Claude Max 5x, $100) | `smol`/`slow`/`plan`/`task` primaries, Haiku for `commit`/`tiny`/`widget`, many hops | `slow`/`plan` → `openai-codex/gpt-6.1-sol`; `task`/`smol` → Sol or GLM-5.3; `commit`/`tiny`/`widget` → Luna or GLM-5.3 Flash. Remove the `anthropic/*` hops. Claude Pro is a fifth of Max 5x, so keep it to one or two roles. |
| `openai-codex` (ChatGPT Plus, $20) | first fallback of the depth chains, Luna hops | Delete those hops; nothing else depends on them. |
| `xai-oauth` (X Premium, $8) | last hop of most chains | Delete those hops. |
| `mistral` (Education plan, $5.99) | `default` primary, GLM hops, Large 4 `vision` hop | `default` → Sonnet 5.5, which is what `default` already runs on whenever Mistral returns 402. Delete the `mistral/*` hops and the GLM compaction threshold. |
| `typesafe` (prepaid API key) | `judge` primary | `judge` → `openrouter/typesafe/jev-1.14` (same price), or one of the other [judge routes](#judge-options). |
| `openrouter` (prepaid API key) | `judge` fallbacks only | Delete them and keep `judge` on TypeSafe alone. |

## Judge options

Judge models answer typed questions with calibrated probabilities. They bill input tokens only,
and **no chat subscription includes one**: ChatGPT Plus/Codex, Claude, and Google AI
Pro/Antigravity logins expose zero judge models. Pick one route and verify it with
`omp models --kind judge`.

| Route | Selector | Billed to | Input price |
|---|---|---|---|
| TypeSafe | `typesafe/jev-1.14.0` (this setup's primary) | TypeSafe prepaid key | $0.042/M |
| OpenRouter | `openrouter/typesafe/jev-1.14`, `…/jev-1.13` (this setup's fallbacks) | OpenRouter prepaid key | $0.042/M |
| OpenRouter | `openrouter/openai/gpt-6-luna-decisions`, `openrouter/google/gemini-decision-1` | OpenRouter prepaid key | $0.10/M |
| OpenAI direct | `openai/gpt-6-luna-decisions` | `OPENAI_API_KEY` (platform billing, separate from ChatGPT) | $0.10/M |
| Google direct | `google/gemini-decision-1` | `GEMINI_API_KEY` from AI Studio (separate from Google AI Pro) | $0.10/M, or a free tier |
| Others | Cloudflare Workers AI Clef, Liquid, Nace | their own keys | see `omp models --kind judge` |

Judges are cheap: the owner's OpenRouter key spent $0.06 from 2026-11-01 to 11-13, with judge
fallbacks as its only configured use. Without any native judge, semantic `find` and
auto-prewalk stay off.

## Optional: the owner's custom roles

These fit one workflow: Claude writes the code, a different model family reviews it, and a
thinking partner on Fable. Skip them unless you want that workflow.

| Role / agent | Model → fallbacks | Purpose |
|---|---|---|
| `review` + bundled `reviewer` (`task.agentModelOverrides.reviewer: "@review"`) | Sol 6.1 → Grok 4.7 → GLM-5.3 | PR/diff review by a family other than the author's ([evaluation](research/REVIEW-ROLE-EVALUATION.md)) |
| `security` + bundled `security-reviewer` | Sonnet 5.5 → Sol 6.1 → Grok 4.7 | vulnerability hunting |
| `critical` + [agents/critical.md](agents/critical.md) | Sol 6.1 → Grok 4.7 | adversarial go/no-go before releases, migrations, and destructive commands |
| `sage` + [agents/sage.md](agents/sage.md) | Fable 5.2 → Opus 5.5 → Sol 6.1 → Grok 4.7 (model-level `anthropic/claude-fable-*` chains) | thinking partner; Fable needs Claude Max |
| [agents/architect.md](agents/architect.md) | binds to `@slow` (no extra role) | read-only design/implementation review |

**To skip them:** remove `review`, `security`, `critical`, and `sage` from `modelRoles`. Remove their
chains and the three `anthropic/claude-fable-*` chains from `retry.fallbackChains`. Remove
`reviewer` and `security-reviewer` from `task.agentModelOverrides` (keep `sonic`), and drop `sage`
from `cycleOrder`. **To take them:** also copy `agents/*.md` to `~/.omp/agent/agents/`.

## Install

1. Log in to each provider you kept (`/login <provider>`). `omp usage` shows meters for
   `anthropic`, `openai-codex`, `google-antigravity`, and `xai-oauth`. `mistral`, `typesafe`, and
   `openrouter` have no meter; check them with `omp models mistral` and `omp models --kind judge`.
2. Optional trial without installing: `omp --config ./model-roles.yml`. This only works with all
   seven logins, or with an edited copy.
3. Run `omp config path`, open `config.yml`, and merge the top-level keys from your (edited)
   `model-roles.yml`. Keep unrelated settings.
4. Restart running `omp` sessions; they keep cached routes until then.

## Verify

```bash
omp config get modelRoles --json
omp config get retry.fallbackChains --json
omp models --kind judge        # your judge primary must be listed
omp models --kind image        # if generate_image is on
./scripts/check-live.sh        # unedited import only: OK per key (needs ruby + jq)
```

Every selector in your config should appear in `omp models` output.

## Repo map

```
model-roles.yml        the overlay (import this)
agents/                custom agents: architect, critical, sage (optional)
OWNER-NOTES.md         owner's evidence and history: meters, incidents, probes, plan billing, daily workflow
CHANGELOG.md           per-version history of model-roles.yml
research/              dated investigations; RESEARCH-PLAYBOOK.md re-derives the setup from scratch
instructions/SELECT-MODEL-MIX.md   stricter preview-only contract for four-provider mixes (last updated for v38)
scripts/check-live.sh  diff model-roles.yml against the live config
scripts/omp-spend.sh   per-day recorded spend for one provider from session logs
scripts/omp-wt/        Git worktree helper for parallel OMP sessions (see its README)
```
