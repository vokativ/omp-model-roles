# OMP model-role setup — import instructions

**Snapshot: 2026-11-03 · v37.2.** Stale after ~4-6 weeks, or immediately if any subscription
changed — check `research/RESEARCH-PLAYBOOK.md`'s staleness check before importing this blind.

`model-roles.yml` is a config **overlay**: `modelRoles`, `task.agentModelOverrides`,
`retry` policies/chains, `cycleOrder`, and owner-approved `extendedContext: true`.
No API keys. Merge into an existing config; do not replace unrelated local preferences.

Subscriptions or workload change? Don't hand-edit this file — see
`research/RESEARCH-PLAYBOOK.md` for the methodology and the questions to re-run before updating it.

## Repo layout

The root overlays and `agents/` are what you import. Selection instructions live in
`instructions/`; source research and rationale live in `research/`.

```
model-roles.yml       <- the config overlay: modelRoles + retry.fallbackChains   (import this)
models-overlay.yml    <- companion models.yml overlay: per-model maxTokens fixes (import this too)
agents/               <- custom agent definitions: architect, critical, and sage (thinking partner) (import this too)
scripts/omp-wt/       <- cross-platform Git Worktree helper (Linux, macOS, Quest, Windows)
instructions/SELECT-MODEL-MIX.md <- instructions for OMP to preview a four-provider allocation
profiles/anthropic-heavy.yml <- optional run-only alternative, NOT the current setup
README.md             <- you are here: import steps + the rationale for the current values
research/
  RESEARCH-PLAYBOOK.md            <- how to re-derive the allocation from scratch; staleness check
  SUBSCRIPTION-MIXES.md           <- 2026-10-08: sourced SKUs/prices, tier mixes, API-credit/auth caveats
  GEMINI-QUOTA-OPTIONS.md         <- 2026-08-15 investigation: Gemini/Antigravity quota burnout options
  META-MUSE-EVALUATION.md         <- 2026-08-25 evaluation: the `meta` provider, and why it wasn't adopted
  ARCHITECT-CRITICAL-AGENTS.md    <- 2026-08-26: wiring architect/critical into real subagent dispatch
  FABLE-EVALUATION.md         <- 2026-10-08: web-only Fable 5.1 vs Opus 5.5 for plan/architect; historical local metrics withdrawn
  THINKING-PARTNER-ROLE.md   <- 2026-09-04 · v19: Thinking Partner (`sage`) architecture, debate, and allocation
  SAGE-CREATIVE-INSTRUCTIONS.md <- 2026-09-04 · v19.1: cognitive divergence, anti-slop catalogs, and subtractive taste
  SAGE-FABLE-ASTRA-EVALUATION.md <- 2026-10-20: Astra vs Sol and Fable vs Opus for sage; probes, blinded A/B with caveats, adversarial review
  MISTRAL-EVALUATION.md      <- 2026-11-03: Mistral EDU plan, model evaluation, OMP probes, judge regression
```

Just importing the config? You need the two `.yml` files, `agents/`, and the import steps below —
nothing in `research/`.

## Optional subscription mixes — preview without changing this setup

[Subscription mixes](research/SUBSCRIPTION-MIXES.md) covers major OpenAI, Anthropic,
Google, and SpaceX/xAI/X plans, prices and caveats. The single selection behavior
contract is [instructions/SELECT-MODEL-MIX.md](instructions/SELECT-MODEL-MIX.md):
**instructions for OMP to follow, not a standalone program**.
It includes an **Anthropic-heavy alternative** (Max 5x $100 + ChatGPT Plus $20,
optionally Google AI Pro and X Premium), not a replacement for the current overlay.
The source notes distinguish native subscription allowances from permitted OMP/API
use: Max's newly offered monthly API credits must be claimed after seven days and
used through an allowed API-key route. Existing OAuth remains untouched.

Paste this request into an OMP session, supplying your actual plans, workload, and
budget rather than assuming the example describes your account:

```text
Read instructions/SELECT-MODEL-MIX.md and follow it. Preview a complete conditional
future allocation for Claude Max 5x, ChatGPT Plus, non-trial Google AI Pro, and X Premium.
My workload is frequent implementation, planning, and architecture review,
with occasional vision/design work and one active machine. Subscription budget:
about $148/month; no additional paid API spend or top-ups. Max API credits are not
yet claimed and route permissions are unconfirmed; mark those as prerequisites,
not verified access. Inspect state/catalog read-only if available and ask only for
material missing information. Show all 15 roles, ordered fallbacks, agent bindings,
the full proposed overlay, rationale, provenance/independence limits, and budget
caveats. Compare Fable 5.1 with Opus 5.5 separately for plan and slow (architect agent) using
web evidence only. Do not apply changes, modify files/auth, install a profile,
buy anything, or send Fable/selected-model probe requests.
```

Reading the instruction file offline sends no model request. Asking OMP to follow
it uses the existing OMP session/model and may consume that model's allowance;
preview does not mean a zero-inference offline executable.
[profiles/anthropic-heavy.yml](profiles/anthropic-heavy.yml) remains an opt-in static
alternative, **not automatically installed**. Any later run needs the notes'
isolated-profile API-auth and provider-enforced spending prerequisites.
The [2026-10-08 Fable 5.1-versus-Opus 5.5 evaluation](research/FABLE-EVALUATION.md)
supports **provisional Opus 5.5 for both `plan` and `architect` in that alternative**.
Fable remains a credible conditional choice, with correctness/rubric counterevidence,
not a promised upgrade or an excluded family; no direct controlled OMP plan/read-only
architect comparison was found in the reviewed sources. Historical local Fable
speed/depletion metrics are withdrawn because those runs fell back to OpenAI.
Fable 5.1 access itself was probe-verified on 2026-10-20 (delivered model ids checked
from events): accepted via Max 5x OAuth with no `credits_required`, unlike the
2026-09-04 Claude Pro 429. That does not change the FABLE-EVALUATION.md conclusion
(provisional Opus 5.5 for `plan`/`architect`); `sage` is the one role on Fable in v35
(below). The preview prompt above still authorizes no Fable or selected-model trial
calls. **No Max trial or alternative quality/quota benchmark is claimed.**
The current setup and its evidence below stay unchanged; subscription planning alone
does not by itself bump the snapshot version.

## Design rationale (why these specific models, not just "the best ones")

This isn't a "use the top-benchmark model everywhere" config — it's balanced against real
subscription capacity, confirmed via `omp usage` on the source machine:

| Login | Plan | Capacity signal | Treat as |
|---|---|---|---|
| `anthropic` | Claude Max 5x, $100/mo | Primary workhorse pool. 2026-11-03 reading: 5h **8%** used, 7d **43%** used, Fable 7d meter **3%** used — a sub-cap inside the shared weekly pool (up to 50% of it); so far moved only by Claude Code usage, not OMP | **heavy workhorse and depth pool** — `task`, `smol`, `review`, and `security` on Sonnet 5.5; `slow` and `plan` (plus the `architect` agent) on Opus 5.5; `sage` on Fable 5.1 (v35); `commit`, `tiny`, `widget`, and Vibe/`sonic` workers on Haiku 5.5:low |
| `openai-codex` | ChatGPT Plus, $20/mo | OpenAI rate card: ~15-160 Sol 6.1 local messages per 5h (Astra 5-45). One chat 5h + one 7d meter shared by Sol, Astra, and Luna (`omp usage`, plan: plus). 2026-11-03 reading: 5h **16%** / 7d **78%** used, 3 saved resets | **independent critical reviewer & first fallback of most chains** — `critical` on Sol 6.1 guarantees independent provenance against Anthropic producers; Sol 6.1 / Luna are the first fallbacks of most chains (Luna is now second behind Mistral's GLM-5.3 Flash in `smol`/`tiny`, v37). The only OpenAI-primary role. The 7d meter is the tight one now |
| `google-antigravity` | Google AI Pro, ~$20/mo | 2026-11-03 reading, main account: shared Claude & GPT weekly pool **92.9%** used (one pool for Antigravity Claude and Antigravity GPT); Gemini 4 Argon weekly **37.2%** used (no longer exhausted); Gemini weekly **4.5%** used; Gemini 5h **4.2%** used. Four other accounts ~0% | **primary everyday lane, vision, advisor** — `default`, `vision`, and `advisor` primary on Gemini 3.8 Flash; Antigravity Opus 5.5 is a depth fallback and sage's second hop, effectively unavailable until the shared pool resets (inference: 92.9% is inside OMP's 10% usage reserve); Argon is `critical`'s first fallback and a middle hop in `slow`/`plan`/`review`/`security` and is usable again; Gemini 3.5 Flash-Lite / 3.8 Flash as lightweight fallbacks |
| `xai-oauth` | X Premium, $8/mo (bundled SuperGrok credits) | Small weekly credit pool; 2026-11-03 reading: **1%** used (99% remaining) | **last-tier fallback** — Grok 4.7 ends depth/vision/critical chains; `grok-build` and `grok-composer-2.5-fast` end the cheap chains; select Grok 4.7 directly for one-off design work |
| `mistral` | Mistral Education (student Pro), $5.99/mo list (owner reports ~$5/mo; max 12 months) | Monthly usage allowance shared across Mistral Vibe CLI, Studio, and API; size unpublished (pricing card: "$15/mo in API credits"; ~$15/mo at API prices is an inference). Resets with the billing period; no 5h/weekly windows; **no `omp usage` meter** (live meter only in the Mistral console). Exhaustion returns HTTP 402 `billing_vibe_budget_exhausted` | **bounded fallback hops only, no primaries** (v37, vision added v37.2) — `zai-glm-5-3-flash` ahead of Luna in `smol`/`tiny`; `zai-glm-5-3` in `task` (third hop) and `review` (before the same-family Opus hop); `mistral-large-4` in `vision` (after Sol 6.1, before Grok 4.7). Small, unmetered pool shared with the owner's Mistral Vibe CLI use |
| `typesafe` | API key, prepaid credit (console.typesafe.ai; separate balance from OpenRouter) | No `omp usage` meter. `typesafe/jev-1.14.0`: $0.042/M input, output free (same price as via OpenRouter). Verified 2026-11-03 (omp 18.16.0): discovery lists `jev-1.14.0`, `jev-latest`, `jev-preview`; a fresh process judged via `typesafe/jev-1.14.0` (P=0.98, ~4 s whole run) | **judge primary** (v37.1) — direct native TypeSafe Jev judgments; no chat model routes through it |
| `openrouter` | API key, prepaid credit (~$7.5 left, 2026-11-03; separate balance from TypeSafe) | No `omp usage` meter. `typesafe/jev-1.14`: $0.042/M input, output free; 164 judgments cost $0.012 over 2026-09-28..10-28 | **judge fallbacks only** (v37.1; was the judge primary in v37) — Jev via OpenRouter, then Liquid d1.1; no chat model routes through it |

**Binding constraint (2026-10-20): the OpenAI Plus 5h window, not the 7d window.** Plus's 5h meter hit
100% five times between 2026-10-17 and 2026-10-19, with 26 `usage_limit_reached` errors on
Sol (10-17: 6, 10-18: 17, 10-19: 3). `critical` accounts for 135 of ~182 task dispatches
(74%) over 2026-10-06..10-20, mostly PR-review swarms. On 2026-10-20 the weekly pools (Anthropic 41%
used, Antigravity 2.3%, xAI 1%) were not the bottleneck; bursts on Plus were. Chain order
therefore avoids sending routine fallback traffic to Sol where a different pool is idle
(see `sage` below). The 2026-10-20 Plus 0% reading is a fresh-window snapshot and does not
contradict this. Percent meters are whole-percent and point-in-time.

**2026-11-03 update: the weekly meters now bind.** Plus 7d is **78%** used (5h 16%, 3 saved resets), and
Antigravity's shared Claude & GPT weekly pool is **92.9%** used on the main account, so every
`google-antigravity/claude-opus-5-5` hop is effectively unavailable until it resets (inference: it
sits inside OMP's 10% usage reserve). Gemini 4 Argon is **37.2%** used and available again, so Argon
hops work. A scan of the last seven days of this Mac's OMP sessions showed little Plus use (about 59
Sol messages) and no Antigravity Claude calls, so the drain likely comes from another machine or
non-OMP use (inference; the scan counts whole files touched in the window, an upper bound). v37's
Mistral hops in `smol`/`tiny` put a separately metered pool ahead of Luna to take pressure off Plus
(see the Mistral section below).

Consequences baked into this file (chains verified against `model-roles.yml`, 2026-11-03):
- **`default` stays primary on `google-antigravity/gemini-3.8-flash`** (fastest measured model and user daily preference), falling back to `anthropic/claude-sonnet-5-5` $\to$ `openai-codex/gpt-6.1-sol` $\to$ `xai-oauth/grok-build`. With `retry.usageAwareFallback: true`, OMP hops automatically when the Google daily/weekly meter fills.
- **No `openrouter` or `nvidia` chat model appears in any role or chain; `typesafe` and `openrouter` serve the `judge` role only.** v33 excluded external API tiers (OpenRouter GLM 5.3 Flash, NVIDIA Nemotron) to fit the four paid subscriptions; earlier GLM/Nemotron floors are historical (see the v17-v23 log in `model-roles.yml`). v37 added two logins beyond those four: `mistral` (plan key, fallback hops only) and `openrouter` (prepaid API credit, native judgment routes only); v37.1 adds a seventh, `typesafe` (prepaid API key, judge primary), and demotes `openrouter` to judge fallbacks.
- **`vision`** keeps `google-antigravity/gemini-3.8-flash` primary, falling back to `anthropic/claude-sonnet-5-5` $\to$ `openai-codex/gpt-6.1-sol` $\to$ `mistral/mistral-large-4` $\to$ `xai-oauth/grok-4.7` (the Mistral hop is v37.2, owner decision 2026-11-03: Large 4 read the probe image correctly, the best vision result of the Mistral models, with the cleanest OMP tool run; 1M context, image input; public preview). It sits late because it only runs after Gemini 3.8 Flash, Sonnet, and Sol all fail. (The 2026-08-22 OpenRouter Gemini 3.8 Flash A/B winner is no longer in the chain.)
- **`critical` keeps strict cross-provider independent provenance**: primary `openai-codex/gpt-6.1-sol`, then `google-antigravity/gemini-4-argon`, then `xai-oauth/grok-4.7`. Independence holds against Anthropic producers; if a producer has failed over to Sol, the producer/reviewer collision must be caught by `critical`'s own provenance check. Argon's weekly meter was exhausted until ~2026-10-24 and read 37.2% used on 2026-11-03, so a Sol failure now falls to Argon first. Since v36 it is scoped to irreversible/operational go/no-go decisions only; PR review moved to `reviewer` (next bullets), which removes the PR-review swarms that drove most `critical` dispatches. No Mistral model is in `critical` (hallucination robustness: Artificial Analysis Omniscience +6 for GLM-5.3 vs +42 for Sol and +46 for Argon).
- **`slow` / `plan` run on `anthropic/claude-opus-5-5`**, falling back to `openai-codex/gpt-6.1-sol` $\to$ `google-antigravity/gemini-4-argon` $\to$ `google-antigravity/claude-opus-5-5` $\to$ `xai-oauth/grok-4.7`. `security` uses the same chain (primary: Sonnet 5.5).
- **`review` (bundled `reviewer`, i.e. PR review) runs on `openai-codex/gpt-6.1-sol`** (v36), falling back to `google-antigravity/gemini-4-argon` $\to$ `xai-oauth/grok-4.7` $\to$ `mistral/zai-glm-5-3` $\to$ `google-antigravity/claude-opus-5-5` (the Mistral hop is v37). Rule: the reviewer's model family must differ from the author's. Producers here are Claude, so Sol reviews; Opus sits last because it is same-family (treat a review it produced as non-independent). v37 inserts GLM-5.3 (a Z.ai-family model hosted by Mistral, text-only, 1M context) ahead of it so the last independent hop is not the same-family one, which matters now that the Antigravity shared Claude & GPT pool is at 92.9% and its Opus hop is effectively unavailable. Evidence for it is the OMP edit-tool probe (0 edit errors) and Terminal-Bench 4.0 41.9%, not a review benchmark; no review-precision evidence exists for it. OMP's own `reviewer` default is `@slow` (Opus); the previous `@review` = Sonnet setting was both same-family and a smaller model. If a PR was written on Sol/Codex, select Opus for that review by hand. For high-stakes PRs, run `reviewer` on both Sol and Opus. Do not fan out reviewer swarms on Sol: the Plus 5h window is the binding constraint. [cubic BugBench](https://www.cubic.dev/bugbench/compare/claude-sonnet-5-5-vs-gpt-6-1-sol) (2026-10-26) shows Sonnet 5.5 and Sol 6.1 statistically tied on bugs in code they write; it is not a review benchmark, so the choice rests on family independence, not a measured review-quality gap.
- **The `architect` agent binds to `@slow`** (v36). The redundant `architect` role/chain/carousel entry was collapsed into `@slow` (both ran Opus 5.5 on identical fallback chains). The read-only consultant agent contract lives in `agents/architect.md`.
- **`sage` (Thinking Partner) is on `anthropic/claude-fable-5-1` since v35 — provisional and reversible.** Failover is Opus 5.5 $\to$ Antigravity Opus 5.5 $\to$ Sol 6.1 $\to$ Gemini 4 Argon $\to$ Grok 4.7, owned by the **model-level** `anthropic/claude-fable-5-1` / `claude-fable-5` chains: OMP checks exact model-key chains before role-key chains (`omp://settings.md`; also seen in the binary strings), so the role-level `sage` chain (Antigravity Opus 5.5 $\to$ Sol 6.1 $\to$ Argon $\to$ Grok 4.7) applies only if `sage` reverts to Opus. Antigravity Opus precedes Sol so `sage` does not drain the Plus 5h window that `critical` swarms exhaust; Argon stays late (its weekly meter was exhausted until ~2026-10-24; 37.2% used on 2026-11-03). Emits no rigid JSON schema. No Mistral model is in `sage` (AA Intelligence 32 and below vs the 50+ depth tier). **Revert:** set `modelRoles.sage` back to `anthropic/claude-opus-5-5`.
- **Why Fable for `sage`, and what is not proven.** Access: 2026-10-20 probes accepted Fable 5.1 via Max OAuth. Quality is **unresolved**: a blind A/B (3 sage-style prompts × 4 models, one answer per model per prompt, thinking high, delivered ids verified) gave mean rubric scores (1-10) that depend on the judge's family — Sonnet 5.5 ×3: Fable 8.19, Opus 7.98, Astra 6.61, Sol 6.30; Grok 4.7 (neutral): Fable 8.43, Opus 8.13, Astra 7.85, Sol 7.74; Sol 6.1: Astra 8.83, Sol 8.70, Fable 6.35, Opus 6.28. Judge-family self-preference dominates; prompt P1 leaked first-person model identity, and excluding P1 Sonnet's Fable–Opus gap vanishes (8.14 vs 8.19); n = 3 prompts, not 9. Chosen anyway on low volume (4 sessions in 14 days, ~2 completed dispatches/week, all on Opus: $4.50 API-equivalent, ~$1.12/dispatch), the best published pushback evidence (AA-PersonalityBench: Fable #1 of 36 on "constructively pushes back"; Arena creative writing Opus 5.5 #1, Fable 5.1 #9, Sol 6.1 #30, Astra #38), and decorrelation from the Opus-based `plan`/`architect`/`slow` (inference). **Estimates:** Fable ~2.4x cost and ~1.6x latency per answer in the batch (≈$2.6/dispatch, roughly +1.6 weekly-pool points vs Opus at 2 dispatches/week; the $185 ≈ 100% weekly calibration is rough).
- **Fable operational caveats.** Fable reasoning blocks are readable only by Fable/Mythos: a mid-session Fable → Opus failover drops that reasoning, and OMP may skip same-provider fallback when signed thinking history exists (fresh dispatches are unaffected). Fable always thinks, and safeguard classifiers can substitute Opus 4.8/Opus 5 server-side (`providers.anthropic.serverSideFallback` defaults to false). It draws the shared Max weekly pool faster, no published multiplier. Policy risk: OMP presents as Claude Code over Max OAuth (can1357/oh-my-pi issue 12487); Anthropic's 2026-10-07 update says subscription limits remain usable with third-party apps. Max's $100/mo API credits cover API-key use, not OAuth.
- **Astra (`openai-codex/gpt-6-astra`) is in no role and no chain.** Probe-verified accepted on Plus on 2026-10-20, but it draws the same Plus 5h/7d meter as Sol (no failover resilience when Plus saturates); list price is ~5x Sol 6.1 ($10/$50 vs $2/$10 per M tokens; Artificial Analysis cost/task $3.26 vs $0.72) for an Intelligence Index of 53 vs 52, with Coding Agent Index within 1-2 points; Arena creative writing ranks it #38 vs Opus 5.5 #1. A coarse burn probe saw 13.8K Astra tokens = +1 meter point = 40.8K Sol tokens (whole-percent granularity: hypothesis ~3-5x, not a measured ratio). Use only as an explicit one-off — `--model openai-codex/gpt-6-astra` — when stuck and Plus has headroom. Earlier README text placing Astra in sage's fallback chain no longer applies.
- **`task` runs on `anthropic/claude-sonnet-5-5`**, falling back to `openai-codex/gpt-6.1-sol` $\to$ `google-antigravity/gemini-3.8-flash` $\to$ `mistral/zai-glm-5-3` $\to$ `xai-oauth/grok-build` (the Mistral hop is v37: GLM-5.3 scored Terminal-Bench 4.0 41.9% vs 19.7% for Gemini 3.8 Flash and made 0 edit-tool errors in OMP probes). The bundled `task` agent (and Vibe's `good` tier) already binds to `@task`, so no override is needed (v36 removed the duplicate `good_worker` role). Sol 6.1 ($2/M input, $0.10/M cached, $10/M output, 128K max output in the installed catalog) serves as `critical` primary and first fallback; the shared overlay enables extended context, giving Codex Sol an effective **922K** window; turning it off would cap it at **272K**.
- **`designer` role removed** (v36). OMP has no built-in designer role or agent; invoke `xai-oauth/grok-4.7` directly via `/model xai-oauth/grok-4.7` when design work is needed.
- **`smol` runs on `anthropic/claude-sonnet-5-5`** (chain: `mistral/zai-glm-5-3-flash` $\to$ Luna $\to$ Gemini 3.5 Flash-Lite $\to$ Grok Build). **`tiny` runs on `anthropic/claude-haiku-5-5:low`** (chain: `mistral/zai-glm-5-3-flash` $\to$ Luna $\to$ Gemini 3.5 Flash-Lite $\to$ `grok-composer-2.5-fast`). v37 puts Mistral's GLM-5.3 Flash ahead of Luna in both to relieve the ChatGPT Plus 7d meter (78% used on 2026-11-03): Artificial Analysis Intelligence v5.0 27.8 vs Luna's 21.4, vision, 1M context, $0.15/$0.5 per M, 0 edit-tool errors in 6 turns / 8.2 s in OMP probes. **Bundled `sonic` (Vibe's `fast` tier) is routed with `task.agentModelOverrides.sonic: "@tiny"`** (v36, replacing the `fast_worker` role): bundled `sonic` otherwise binds to `@smol` (Sonnet 5.5). The override names a role, not a bare model, on purpose: a role-less pinned subagent falls back through the `default` chain (Sonnet first). History: v24 moved the cheap tier off OpenAI's retired `gpt-5.3-codex-spark` onto Grok; v33 moved it onto Haiku.
- **`widget` runs on `anthropic/claude-haiku-5-5:low`** (v36; chain: Gemini 3.5 Flash-Lite $\to$ Grok Composer 2.5 Fast). Resolves OMP 18.12.3's `async.widgets: true` background job author defaulting to `smol` (Sonnet 5.5), protecting frontier quota while providing fast, concise status-line widgets.
- **`judge` runs on `typesafe/jev-1.14.0`** (v37.1, direct TypeSafe; chain: `openrouter/typesafe/jev-1.14` $\to$ `openrouter/typesafe/jev-1.13` $\to$ `openrouter/liquid/d1.1`). It activates semantic `find` under OMP's `find.enabled: auto` default (which requires the judge to resolve first to a native judgment model), auto-prewalk, smart `tui.autoGraph`, and typed Eval judgments (`judge()`, `judge_batch()`). **v36 regression and root cause (historical):** v36 set `typesafe/jev-1.14.0` as primary, claiming stored TypeSafe credentials in `agent.db`; no TypeSafe credential ever existed there (likely a misreading of pre-v36 `model_usage` rows whose role was `typesafe` but whose provider was OpenRouter). `typesafe/jev-preview` is not seeded, which logged `Fallback chain for role 'judge' does not resolve to a compatible model`, and the chain had no OpenRouter route. Since 2026-10-28 every judgment therefore fell through to prompted `gemini-3.5-flash-lite` (0/1 probabilities), which disabled `find`, auto-prewalk, and smart `autoGraph`. Before v36 OMP's built-in chain reached OpenRouter Jev: 164 judgments over 2026-09-28..10-28 cost $0.012. **Natives only, on purpose:** once a credentialed native judge fails, OMP never tries a prompted chat model, so a chat tail is dead config (tested). **v37 fix (2026-11-03):** judge on `openrouter/typesafe/jev-1.14` (chain `openrouter/typesafe/jev-1.13` $\to$ `openrouter/liquid/d1.1`); `omp find` answered in ~2 s with 4 relevant hits (baseline 6.3 s, 0 hits); `judge_batch` 0.40-0.56 s per call with graded probabilities 0.89-0.96; the warning was gone and the `find` tool present. **v37.1 (2026-11-03, omp 18.16.0):** the owner stored a TypeSafe API key (`/login typesafe`; `agent.db` `auth_credentials` row `provider=typesafe`, `api_key`), so the direct route now works. TypeSafe discovery lists `typesafe/jev-1.14.0`, `jev-latest`, and `jev-preview`; a fresh process judged via `typesafe/jev-1.14.0` (P=0.98, ~4 s whole run). **Forced failover test** (run-only overlay `judgment.attemptTimeoutMs: 1`): the logs show `typesafe/jev-1.14.0`, `openrouter/typesafe/jev-1.14`, and `openrouter/typesafe/jev-1.13` each `Aborted: The operation timed out.`, then `openrouter/liquid/d1.1` answered (P=0.993), so the full chain walk is verified. `find` with the v37.1 overlay: coverage complete, 4 relevant hits, $0.0018. Same model and price ($0.042/M input, output free) as v37, so the switch is about route diversity, not cost: TypeSafe credit funds the primary and OpenRouter credit is fallback-only (two separately funded prepaid balances). Direct `jev-latest`/`jev-preview` are intentionally **not** in the chain: same provider and endpoint as the primary, and TypeSafe's docs say both currently alias `jev-1.14.0`. **Restart running OMP sessions:** a session started before the TypeSafe login keeps its cached judge route (one such session still judged via OpenRouter); a fresh process picks up the direct route. Mistral is not a judge candidate (no native judgment API; prompted `mistral-small-2603` was ~3x slower).
- **`critical` agent runs with `structured: true` and `read-summarize: false`** (v36). Restores the `yield` tool and output schema validation broken in OMP 18.10.2+ for subagents spawned by `task`, while ensuring adversarial gates inspect raw source without structural line elisions.

### Haiku 5.5: bounded subscription adoption (v32, widened in v33)

`commit` uses `anthropic/claude-haiku-5-5:low`, followed by Grok Build → Luna →
Gemini 3.5 Flash-Lite. It is infrequent, bounded summarization work, not general
implementation. v33 also moved `tiny` and Vibe/`sonic` workers to Haiku 5.5:low and made it
`advisor`'s first fallback; automatic fallback traffic can become sustained load
on the same Claude allowance (now Max 5x) used by every Anthropic-primary role.

At v32, Claude Pro OAuth access and native OMP 18.8.3 tool replay were exercised with model
and usage-aware fallback disabled. No Haiku was listed by any of the five
authenticated Antigravity inventories. OpenRouter lists it as a separately billed
API model, not subscription capacity. No custom model definition is needed.

On one identical staged utility-function addition, actual `omp commit --dry-run
--no-changelog` requests produced faithful, validated messages:

| Model | Wall time | Commit-agent tool calls |
|---|---:|---:|
| Haiku 5.5, low effort | 5.63 s | 3 |
| Grok Build | 44.81 s | 6 |

This is a single-workload screening result, not a general speed, quality, or quota
benchmark. [Haiku's overview](https://platform.claude.com/docs/en/models/haiku-5-5/overview)
specifies 1M context, 128K output, adaptive effort, and text/image input. API
input/output prices are $0.10/$0.50 per million tokens through 100K prompt tokens,
and $0.50/$2.50 above 100K; those are not Claude Pro quota multipliers.
[Anthropic recommends](https://www.anthropic.com/claude-haiku-5-5) narrowly scoped
work for Haiku and larger Sonnet/Opus models for complex agentic coding.

### Antigravity: paid main setup versus free accounts (v31)

The main overlay targets the paid Google AI Pro account's Claude 5.5 lineup.
Authenticated inventories on 2026-10-07 showed one `g1-pro-tier` account with
Opus/Sonnet 5.5 and four free accounts with Opus/Sonnet 4.6. Opus and Sonnet share
the account's Claude pool; they are not independent quota reservoirs.

Both `google-antigravity/claude-opus-5-5` and `google-antigravity/claude-sonnet-5-5`
completed OMP requests at `thinking: high` with retries and model/usage-aware
fallback switching disabled. Both also completed a `read` tool round trip and
returned the file contents with LSP disabled. The then-updated `@advisor` alias resolved
to Sonnet 5.5 (advisor has since moved to Gemini 3.8 Flash, v33), and `@default` completed on Gemini 3.8 Flash without falling back.
The earlier 404 probes no longer describe current access. Free-account 4.6
availability is inventory evidence, not a new inference test.

Do not import the main overlay unchanged on a free-only setup: its depth chains and sage's
Fable chain include Antigravity Opus 5.5, which free accounts do not expose; keep non-Google fallbacks.
The low-capacity free Google accounts can still supplement eligible Gemini models;
they do not provide extra Claude 5.5 capacity. No account-specific routing policy
or credential pinning is added by this overlay.
[Google's model documentation](https://antigravity.google/docs/models.md) limits
Claude 5.5 to non-trial Pro/Ultra subscriptions and schedules Claude 4.6 and
GPT-OSS-120B removal for **2026-11-02**. Historical research files retain their
original 4.6 measurements; they are not the current main-setup allocation.

### Mistral EDU plan: bounded fallback adoption (v37)

Full evidence, probe tables, and sources: [research/MISTRAL-EVALUATION.md](research/MISTRAL-EVALUATION.md).

**Plan facts (observed 2026-11-03).** Mistral's Education plan is the Pro plan with a student
discount: $5.99/mo list (normally $14.99; the owner reports ~$5/mo), at most 12 months, verified
institutional email. It includes Le Chat Pro, Mistral Vibe (CLI, IDE, web), and "$15/mo in API
credits" per the pricing card. "Vibe" in this section means Mistral's product; elsewhere in this
README `Vibe` means OMP's good/fast worker tiers.

**Billing route.** OMP's `/login mistral` key is a "vibe"-scope plan key (Mistral Vibe's `whoami`
reports `plan_name` EDU). Its usage draws the plan's monthly allowance, shared across Mistral Vibe CLI,
Studio, and API, not PAYG credits. The allowance size is unpublished; ~$15/mo at API prices is an
**inference**. It resets with the billing period; no 5h/weekly windows. The `has_paid_vibe_entitlement:
false` in `~/.vibe`'s cache is a client default that only suppresses an upgrade prompt and is
irrelevant to EDU. The owner's own Mistral Vibe CLI usage (default model GLM-5.3, hosted by Mistral)
draws the same budget as OMP.

**Probe matrix (omp 18.16.0, 2026-11-03).** Each model ran the same tool task (run a failing test, fix
the planted bug with `edit`, create and run two new files), a vision prompt, a commit-message prompt,
and two reasoning puzzles at several thinking levels; `n` is 1-3 per cell, so rankings are directional.
List-price spend for the whole session was under $0.30.

| Model | Tool task | `edit` errors | Image | Note |
|---|---|---|---|---|
| `zai-glm-5-3-flash` | 6 turns, 8.2 s | 0 | pass | cheapest; ~1.3 s on the commit prompt |
| `zai-glm-5-3` | 10 turns, 13.8 s | 0 | text-only | three self-fixed assertion errors in its own test |
| `mistral-large-4` | 5 turns, 10.8 s | 0 | pass | cleanest run, best commit message; public preview |
| `deepseek-v4-1-flash-1017` | 4 turns, 5.7 s | 0 | text-only | fastest; emitted thinking-only turns that OMP auto-continued; public preview |
| `mistral-small-2603` | 8 turns, 11.6 s | 0 | misread text | wrong once on a puzzle at high thinking |
| `mistral-medium-latest` | 9 turns, 13.3 s | 3 of 4 malformed | pass | slowest on small prompts |
| `ministral-14b-2512` | 56 turns, 114.8 s | 47 of 47 failed | pass | finished only by rewriting the file with `write` |
| `mistral-medium-3.5` (alias) | 14 turns, 18.6 s | 6 of 7 failed | pass | null catalog metadata; answered a puzzle wrongly (never thinks) |

OMP accepted every thinking level on every model; the effect is weak and non-monotonic, and `off`
sends the lowest effort rather than disabling reasoning on GLM-5.3. Chain entries are bare ids.

**Chosen hops** (one `mistral/*` entry per chain, fallback only, no primaries; `vision` added in v37.2):

- `smol`: `mistral/zai-glm-5-3-flash` $\to$ Luna $\to$ Gemini 3.5 Flash-Lite $\to$ Grok Build
- `tiny`: `mistral/zai-glm-5-3-flash` $\to$ Luna $\to$ Gemini 3.5 Flash-Lite $\to$ `grok-composer-2.5-fast`
- `task`: Sol 6.1 $\to$ Gemini 3.8 Flash $\to$ `mistral/zai-glm-5-3` $\to$ Grok Build
- `review`: Argon $\to$ Grok 4.7 $\to$ `mistral/zai-glm-5-3` $\to$ Antigravity Opus 5.5
- `vision`: Sonnet 5.5 $\to$ Sol 6.1 $\to$ `mistral/mistral-large-4` $\to$ Grok 4.7

GLM-5.3 Flash (AA Intelligence v5.0 27.8, Terminal-Bench 4.0 32.8%, vision, 1M context, $0.15/$0.5)
precedes Luna (AA 21.4). GLM-5.3 (AA 31.7, Terminal-Bench 4.0 41.9% vs Gemini 3.8 Flash's 19.7%, 1M
context, text-only, $1.4/$4.4) is `task`'s third hop and a cross-family reviewer before the
same-family Opus hop. Large 4 (AA 26.0, 1M context, image input, catalog `maxTokens` 262,144; OMP list price $1.36/$4.18 vs Mistral's own $0.70/$2.10) had the cleanest OMP tool run (5 turns, 10.8 s, 0 edit errors) and read the probe image correctly, the best vision result of the Mistral models. It is `vision`'s third hop, after Sol and before Grok 4.7, so it only runs when Gemini 3.8 Flash, Sonnet, and Sol all fail. Its Terminal-Bench 4.0 score is 24.7% in a neutral harness (41% in Mistral's own Vibe harness), which is why it is a vision-only hop. Only one entry per chain, because two entries on one routing provider share one pool.

**Not adopted** (`mistral-large-4` is adopted for `vision` only; elsewhere it stays an explicit `/model` choice):

- `mistral-large-4` for any chain other than `vision`: public preview; AA 26.0; Terminal-Bench 4.0 24.7% in a generic harness (41% in Mistral's own Vibe harness), too weak for the tool-heavy chains.
- `deepseek-v4-1-flash-1017`: public preview; strong AA (32.5) but emitted thinking-only turns OMP had to auto-continue.
- `mistral-medium-3.5`: deprecated 2026-10-31, Terminal-Bench 4.0 0%, 3 of 4 malformed hashline edits (`mistral-medium-latest`).
- Small 4 / Ministral: AA 4.3 / weak; `ministral-14b` failed 47 of 47 edits and looped for 115 s.
- Alias ids (`mistral-medium-3.5`, `zai-glm-5`, `mistral-vibe-cli-*`): no OMP catalog metadata, so no thinking control, null context window, and zero cost accounting.
- No Mistral model in `critical`, `slow`/`plan`/`security` (AA at most 32 vs the 50+ depth tier), `sage`, `judge` (Mistral has no native judgment API), or as any primary (small unmetered monthly pool). `vision` has `mistral/mistral-large-4` as a late fallback only (v37.2).

**Risks.**

- **Unmetered.** No `omp usage` meter, so `retry.usageAwareFallback` cannot skip a depleted Mistral hop in advance (inference: unknown usage fails open); a hop is discovered empty only when it errors.
- **Shared pool.** Mistral Vibe CLI, Studio, and API draw the same monthly allowance; heavy Mistral Vibe CLI use shrinks what OMP fallbacks have. The allowance size is unpublished.
- **Monthly reset.** Exhaustion lasts to the next billing period. It returns HTTP 402 `billing_vibe_budget_exhausted` (documented in mistral-vibe issue 1362 for a Free plan; not reproduced here); OMP's `retry.fallbackOn` default `any` walks the chain on it. Chain walking into the Mistral hop was verified with a forced runtime error (HTTP 410 on the `tiny` primary): the `sonic` subagent answered on `mistral/zai-glm-5-3-flash`.
- **Preview and deprecated models.** The chosen GLM-5.3 models are not previews, but Large 4 (now the `vision` chain's third hop, v37.2) and DeepSeek V4.1 Flash are public previews, so Large 4's availability or behavior could change; DeepSeek is not in any chain; Medium 3.5 is deprecated. Re-check the catalog before widening.
- **Provider vs family.** GLM-5.3 is a third-party model family served by Mistral; for independence, record both the routing provider and the family.
- **Data and terms.** The pricing page lists "Model training: Opt-out" for Pro; that it applies to EDU is an inference and the opt-out setting was not checked. Third-party-harness terms for the student plan were not checked. The renewal price after the 12 months is not stated.

**Check the meter.** Not in `omp usage`. Use https://console.mistral.ai/codestral/cli ("View
organization usage"), https://admin.mistral.ai/subscription (plan, included usage, PAYG toggle), or
https://admin.mistral.ai/organization/usage ("Vibe usage beyond quota"). To confirm the login and
selectors: `omp models mistral --json`.

### Extended context: one enabled configuration everywhere

After the 2026-10-02 cross-machine review, the owner chose **one configuration
everywhere: `extendedContext: true`**. This supersedes both the initial off trial
and the interim machine-local proposal. The portable overlay and CLI import
commands now enable it explicitly. The Ubuntu development server was already on;
the Mac was subsequently enabled to match. No separate profile is necessary.

(Sol 6.1 is now `critical`'s primary and the first fallback of most chains; the analysis
below predates the Anthropic-heavy v33 allocation, when Codex served more roles.)

Evidence: streamed 604 local and 1,022 server session JSONL files, then analyzed
dated usage from 2026-09-02 through the scan on 2026-10-02 (~07:21 UTC). The table
counts **main sessions with recorded Codex calls**, not all providers or subagents.

| Observed Codex usage | Mac | Ubuntu server |
|---|---:|---:|
| Main sessions | 13 | 34 |
| Main sessions with a prompt over 272K | 5 | 10 |
| Main-session calls over 272K | 708 / 1,001 | 1,670 / 5,010 |
| Maximum prompt | 731,425 | 726,966 |
| Main-session prompt cache-hit share | 97.8% | 97.9% |
| Subagent sessions | 171 | 675 |
| Subagent sessions with a prompt over 272K | 0 | 0 |
| Subagent prompt p95 | 117,994 | 114,732 |

Prompt size is per-call `usage.input + cacheRead + cacheWrite`, excluding output,
not cumulative session usage. It matched `contextSnapshot.promptTokens` for every
recorded Codex conversation call in this window. Counts exclude auxiliary
`model_usage` records; no duplicate usage entries or shared session IDs were found.
Only metadata and selected user requests were examined, not every resulting change.
No existing project `.omp/config.yml` overrides were found along recorded cwd
ancestor paths; historical runtime overrides and unrecorded sessions remain unknown.

Representative server sessions covered application modernization through deployment
and branch/database reconciliation. Another repeatedly refreshed the same external
research over several days: that is a better candidate for a fresh session using
persisted findings. Large contexts demonstrate actual demand, not proof that every
retained token was useful or every task required that much memory.

The shared $100 OpenAI account reported **44% weekly usage**, **56% remaining**,
and about **1 day 18 hours until reset** on both machines. These are the same
account allowance, not two budgets. Cached tokens are still metered; API-equivalent
dollars in session records are not actual subscription bills or a quota formula.
This point-in-time headroom supports keeping the capability, not unlimited growth.

Limits: most long Codex requests used earlier Terra/Sol models; this is not a Sol 6.1
quality or quota benchmark. The last seven days contained no Codex prompts over
272K on either machine, so current activity is lighter than the full-month sample.
Five explicit compactions were recorded on the server in the window (three native,
two snapcompact), none on the Mac; this does not count every pruning operation.
There is no controlled on/off comparison proving how much earlier compaction would
cost or lose. With current default reserves, a 272K window can trigger maintenance
around 231K, rather than waiting until the full ceiling.

**Practical policy:** allow large coherent development sessions; start fresh at a
genuine task boundary instead of carrying completed research/debugging indefinitely.
Do not add more review agents just because context is available. Watch shared
`omp usage` over a full reset cycle, plus compaction frequency, lost constraints,
and rework. If quota becomes tight, target repeated discovery and redundant reviews
before assuming the context ceiling is the cause.

To inspect the shared setting and effective model limit:

```bash
omp config get extendedContext --json
omp models find gpt-6.1-sol --json
```

The persistent setting is `omp config set extendedContext true`; start a new
session after importing it. OMP also exposes `/extended-context on` in its
interactive UI. Do not fake a larger provider limit through `models.yml`.
The server and Mac both use extended context under this owner-approved policy.

## Daily workflow: choose the job, not a committee

| Need | Normal choice |
|---|---|
| Small, clear change or everyday conversation | `omp`; stay on the default model |
| Build/fix with a useful exploration phase and routine implementation | Opus 5.5 → Sonnet 5.5 prewalk (`@slow` → `@smol`), explicitly opted in |
| Hard reasoning remains throughout implementation | Stay on `@slow`; no forced downgrade |
| Review a design, implementation, plan, or configuration | Ask for the `architect` agent; define the question and scope |
| PR / diff review | Bundled `reviewer` (Sol 6.1, cross-family to Claude authors); `security-reviewer` for vulnerability hunting |
| Challenge the premise or explore a different direction | `sage` |
| Go/no-go before a release, migration, cutover, or destructive action | `critical`, with producer identity, `reviewer` findings, and validation evidence |
| Human approval required before any implementation | `/plan`; prewalk is not an approval boundary |

**Roles select models; agents select instructions.** `/model @slow` or
Ctrl+P selects Opus 5.5, not `agents/architect.md`'s read-only review contract.
Request "use the architect agent to review X" for that contract; the agent binds to `@slow`.
`slow` and `plan` share Opus 5.5; `security`, `smol`, and `task` use Sonnet 5.5;
`sage` is on Fable 5.1; `review` and `critical` are the Sol-primary roles. Different prompts on one
model, or direct and Antigravity Opus 5.5, are not independent model votes.
Keep reviews targeted; do not run all four by habit. Retain `critical`'s structured
verdict/provenance schema; architect's schema was removed for human usability, not
because its performance overhead was measured.

### Implementation with prewalk

Start a new implementation session:

```bash
omp --model @slow --prewalk-into @smol "Implement X; preserve Y; verify Z."
```

This starts on Opus 5.5 and targets Sonnet 5.5 with the current role mappings (fallbacks may
change the concrete models). Plain `omp --prewalk` instead starts on the default
Gemini model; it does **not** automatically select `@plan`, `@slow`, or `@architect`.

In an existing session, first select `/model @slow`, then run `/prewalk`, then send
the implementation request. `/prewalk` arms a one-shot handoff; it is not an
always-on mode. `/prewalk restart` returns to `@default` (Gemini here), not `@slow`.

The target inherits the conversation and todo state rather than just a prose plan.
It still incurs input processing, can re-read files, and must validate the result.
In installed OMP 18.4.10, any successful todo operation opens the gate; the switch
occurs at the turn boundary after the first eligible edit/write result, **even if
that edit failed**. It is not proof that the approach works. Leave the normal
verification steps in the request. A pure read-only review has no reason to use it.

Global `prewalk.enabled` and `task.prewalk` remain off; the latter is a separate
control for generic task subagents. Trial the explicit command before adopting
automatic handoffs. No new profile or parallel configuration type is needed.

### Subagents: keep useful separation, avoid duplicate discovery

Use subagents for genuinely independent implementation slices, broad research
whose source material would overwhelm the main context, or a deliberately fresh
review. Give each a bounded question, relevant paths, constraints, and evidence.
Prefer one agent to investigate **and implement** a slice rather than passing it
between a scout, planner, and executor. Keep integration and acceptance with one owner.

Read-only review is not wasted implementation planning: independent inspection is
part of its value. For ordinary work, one targeted review is enough; add a second
only for a distinct risk or unresolved disagreement. On overlapping edits, use
explicit ownership or worktrees—not more prompts.

### What the Stencil evidence supports

- [Prewalk](https://stencil.so/blog/prewalk): a trajectory handoff outperformed
  read-only plan → executor on the article's tested tasks/models. This does not
  invalidate RFCs, human approval, independent review, or complex-task orchestration.
  Its reported costs/pass rates are not measurements of our Opus/Sonnet pair.
- [Harness Playbook](https://stencil.so/blog/harness-playbook): small stable tool
  surfaces and explicit state/policy matter. Its permanent-tool grammar results
  do not prove our architect output schema caused latency or constrained reasoning.
- [Snapcompact](https://stencil.so/blog/snapcompact): compaction has fidelity and
  decoding tradeoffs; long coherent sessions can be useful. It is not evidence for
  universally shortening sessions or enabling image compaction on every fallback.
- [Harness Problem](https://stencil.so/blog/the-harness-problem): editing interfaces
  materially affect reliability. Keep using OMP's anchored edits; do not infer that
  every cheaper model now matches a frontier model on arbitrary work.

## Prerequisite: auth

The mapping references seven logins. Four are subscription logins: `anthropic`, `openai-codex`,
`google-antigravity`, `xai-oauth`. Run `omp usage` on the target machine to confirm each is logged in.
Three more were added in v37/v37.1 and **never appear in `omp usage`**:

- `mistral`: run `/login mistral` on **each** machine (the key is per machine; the plan allowance is one
  account-level pool, so load across machines adds up). It must be the Mistral Education/student Pro
  plan key. Used only for the five fallback hops (`smol`, `tiny`, `task`, `review`, `vision`); without it, delete
  those `mistral/*` entries before importing.
- `typesafe` (v37.1): run `/login typesafe` (API key from console.typesafe.ai; needs prepaid credit, no free
  tier). Used by the `judge` role as the primary (`typesafe/jev-1.14.0`). Without it, set `judge` to
  `openrouter/typesafe/jev-1.14` (the v37 setup) before importing.
- `openrouter`: an OpenRouter API key with prepaid credit, funded separately from TypeSafe. Since v37.1 it is
  used only for the `judge` fallbacks (Jev via OpenRouter, then Liquid d1.1); without both it and a working
  TypeSafe login, `find` stays disabled under `find.enabled: auto`.

Verify these three with `omp models mistral --json` and `omp models --kind judge --json` (see Verify).
Restart any running `omp` session after logging in: sessions started before the login keep their cached judge route.

## Installation

To use the role/fallback overlay for a new session without changing global settings,
run `omp --config ./model-roles.yml` from this repository. The companion model
overrides and custom agents still use the installation steps below.

### Option A — merge into the global config (affects every project on that machine)
1. Run `omp config path`, then open `config.yml` in the printed agent directory.
2. Merge all top-level keys from `model-roles.yml` into `config.yml`, including `task`, `cycleOrder`, and `extendedContext: true`, preserving unrelated settings.
3. In the same directory, open `models.yml` (create if missing) and copy in `models-overlay.yml`'s `providers:` block. (It only sets an OpenRouter `maxTokens` override for `google/gemini-3.8-flash`, which no current role or chain references, so it is inert — inference. The `judge` role's OpenRouter routes need no override.)
4. Copy `agents/*.md` (`architect.md`, `critical.md`, and `sage.md`) into `~/.omp/agent/agents/`. The agents bind to role aliases (`@architect`, `@critical`, `@sage`), so `sage.md` runs on whatever `modelRoles.sage` is — Fable 5.1 after import.
5. Restart any running `omp` session.

Equivalent CLI commands for `config.yml`:
```bash
omp config set modelRoles '{"default":"google-antigravity/gemini-3.8-flash","smol":"anthropic/claude-sonnet-5-5","slow":"anthropic/claude-opus-5-5","plan":"anthropic/claude-opus-5-5","task":"anthropic/claude-sonnet-5-5","vision":"google-antigravity/gemini-3.8-flash","commit":"anthropic/claude-haiku-5-5:low","advisor":"google-antigravity/gemini-3.8-flash","tiny":"anthropic/claude-haiku-5-5:low","widget":"anthropic/claude-haiku-5-5:low","judge":"typesafe/jev-1.14.0","review":"openai-codex/gpt-6.1-sol","security":"anthropic/claude-sonnet-5-5","critical":"openai-codex/gpt-6.1-sol","sage":"anthropic/claude-fable-5-1"}'

omp config set task.agentModelOverrides '{"security-reviewer":"@security","reviewer":"@review","sonic":"@tiny"}'

omp config set retry.fallbackChains '{"default":["anthropic/claude-sonnet-5-5","openai-codex/gpt-6.1-sol","xai-oauth/grok-build"],"smol":["mistral/zai-glm-5-3-flash","openai-codex/gpt-6-luna","google-antigravity/gemini-3.5-flash-lite","xai-oauth/grok-build"],"slow":["openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","google-antigravity/claude-opus-5-5","xai-oauth/grok-4.7"],"plan":["openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","google-antigravity/claude-opus-5-5","xai-oauth/grok-4.7"],"task":["openai-codex/gpt-6.1-sol","google-antigravity/gemini-3.8-flash","mistral/zai-glm-5-3","xai-oauth/grok-build"],"vision":["anthropic/claude-sonnet-5-5","openai-codex/gpt-6.1-sol","mistral/mistral-large-4","xai-oauth/grok-4.7"],"commit":["xai-oauth/grok-build","openai-codex/gpt-6-luna","google-antigravity/gemini-3.5-flash-lite"],"advisor":["anthropic/claude-haiku-5-5:low","openai-codex/gpt-6-luna","xai-oauth/grok-build"],"tiny":["mistral/zai-glm-5-3-flash","openai-codex/gpt-6-luna","google-antigravity/gemini-3.5-flash-lite","xai-oauth/grok-composer-2.5-fast"],"widget":["google-antigravity/gemini-3.5-flash-lite","xai-oauth/grok-composer-2.5-fast"],"judge":["openrouter/typesafe/jev-1.14","openrouter/typesafe/jev-1.13","openrouter/liquid/d1.1"],"review":["google-antigravity/gemini-4-argon","xai-oauth/grok-4.7","mistral/zai-glm-5-3","google-antigravity/claude-opus-5-5"],"security":["openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","google-antigravity/claude-opus-5-5","xai-oauth/grok-4.7"],"critical":["google-antigravity/gemini-4-argon","xai-oauth/grok-4.7"],"sage":["google-antigravity/claude-opus-5-5","openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","xai-oauth/grok-4.7"],"anthropic/claude-fable-5-1":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-5-5","openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","xai-oauth/grok-4.7"],"anthropic/claude-fable-5":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-5-5","openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","xai-oauth/grok-4.7"]}'

omp config set retry.usageAwareFallback true
omp config set retry.usageReservePolicy auto
omp config set cycleOrder '["smol","default","slow","sage"]'
omp config set extendedContext true
```

## Verify
```bash
omp config get modelRoles --json       # sage must be anthropic/claude-fable-5-1; judge must be typesafe/jev-1.14.0
omp config get retry.fallbackChains --json
omp config get extendedContext --json  # true on every machine
omp models find gpt-6.1-sol --json      # Codex contextWindow: 922000
omp models mistral --json              # logged in: lists zai-glm-5-3 and zai-glm-5-3-flash (1,048,576 context each) and mistral-large-4 (the vision hop)
omp models --kind judge --json         # lists typesafe/jev-1.14.0 (and jev-latest, jev-preview, openrouter/typesafe/jev-1.14, jev-1.13, liquid/d1.1); the judge fallback chain must resolve with no startup warning
omp usage                              # Anthropic, ChatGPT, Antigravity, xAI meters only; no Mistral, TypeSafe, or OpenRouter meter
```

## Git Worktree Helper (`omp-wt`)

A beginner-friendly cross-platform helper to run multiple parallel OMP sessions or investigations on the same codebase without branch-switching collisions or file conflicts.

### Key Features
- **Parallel Isolation:** Creates isolated worktrees (`.worktrees/<name>`) so OMP agents can edit, build, and test without touching your main workspace.
- **Untracked Config & Secret Detection:** Automatically detects and offers to copy local configuration files ignored by Git (`.env`, Android `local.properties` / keystores / `google-services.json`, iOS `GoogleService-Info.plist`, `.npmrc`).
- **Human-Parsable Listing (`omp-wt list`):** Shows clean status, relative activity age, commit messages, and a cheat sheet of next actions (`merge`, `rm`).
- **Built-in Guide (`omp-wt guide`):** Terminal-friendly visual introduction explaining how worktrees work.

### Installation
- **Linux, macOS, Meta Quest (Termux):**
  ```bash
  ./scripts/omp-wt/install.sh
  ```
- **Windows (PowerShell):**
  ```powershell
  .\scripts\omp-wt\install.ps1
  ```

### Quick Cheat Sheet
```bash
omp-wt                      # Interactive setup wizard
omp-wt investigate-auth     # Create worktree and start OMP
omp-wt list                 # See all active worktrees and status
omp-wt rm investigate-auth  # Delete worktree and its branch when done
omp-wt guide                # Read the visual beginner's guide
```
Full documentation and stack-specific tips: see [`scripts/omp-wt/README.md`](scripts/omp-wt/README.md).
