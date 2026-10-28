# OMP model-role setup — import instructions

**Snapshot: 2026-10-28 · v36.** Stale after ~4-6 weeks, or immediately if any subscription
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
| `anthropic` | Claude Max 5x, $100/mo | Primary workhorse pool. 2026-10-20 reading: 5h **8%** used, 7d **41%** used (resets 2026-10-23 16:00Z), Fable 7d meter **13%** used — a sub-cap inside the shared weekly pool (up to 50% of it); so far moved only by Claude Code usage, not OMP | **heavy workhorse and depth pool** — `task`, `smol`, `review`, and `security` on Sonnet 5.5; `slow` and `plan` (plus the `architect` agent) on Opus 5.5; `sage` on Fable 5.1 (v35); `commit`, `tiny`, `widget`, and Vibe/`sonic` workers on Haiku 5.5:low |
| `openai-codex` | ChatGPT Plus, $20/mo | OpenAI rate card: ~15-160 Sol 6.1 local messages per 5h (Astra 5-45). One chat 5h + one 7d meter shared by Sol, Astra, and Luna (`omp usage`, plan: plus). 2026-10-20 15:35 reading: 5h **0%** / 7d **0%** used — both windows had just reset (reset time ≈ fetch time + full window; inference), so this is not a headroom signal | **independent critical reviewer & first fallback of most chains** — `critical` on Sol 6.1 guarantees independent provenance against Anthropic producers; Sol 6.1 / Luna are the first fallbacks of most chains. The only OpenAI-primary role |
| `google-antigravity` | Google AI Pro, ~$20/mo | 2026-10-20 reading: Gemini 5h **99.6%** remaining; weekly Flash **87%** remaining; Gemini 4 Argon weekly meter **100% used (exhausted) until ~2026-10-24**; shared Claude & GPT weekly pool **2.3%** used (one pool for Antigravity Claude and Antigravity GPT) | **primary everyday lane, vision, advisor** — `default`, `vision`, and `advisor` primary on Gemini 3.8 Flash; Antigravity Opus 5.5 is a depth fallback and sage's second hop; Argon is `critical`'s first fallback and a middle hop in `slow`/`plan`/`review`/`security` (those hops are wasted until the meter resets); Gemini 3.5 Flash-Lite / 3.8 Flash as lightweight fallbacks |
| `xai-oauth` | X Premium, $8/mo (bundled SuperGrok credits) | Small weekly credit pool; 2026-10-20 reading: **1%** used (99% remaining) | **last-tier fallback** — Grok 4.7 ends depth/vision/critical chains; `grok-build` and `grok-composer-2.5-fast` end the cheap chains; select Grok 4.7 directly for one-off design work |

**Binding constraint: the OpenAI Plus 5h window, not the 7d window.** Plus's 5h meter hit
100% five times between 2026-10-17 and 2026-10-19, with 26 `usage_limit_reached` errors on
Sol (10-17: 6, 10-18: 17, 10-19: 3). `critical` accounts for 135 of ~182 task dispatches
(74%) over 2026-10-06..10-20, mostly PR-review swarms. The weekly pools (Anthropic 41%
used, Antigravity 2.3%, xAI 1%) are not the bottleneck; bursts on Plus are. Chain order
therefore avoids sending routine fallback traffic to Sol where a different pool is idle
(see `sage` below). The 2026-10-20 Plus 0% reading is a fresh-window snapshot and does not
contradict this. Percent meters are whole-percent and point-in-time.

Consequences baked into this file (chains verified against `model-roles.yml`, 2026-10-20):
- **`default` stays primary on `google-antigravity/gemini-3.8-flash`** (fastest measured model and user daily preference), falling back to `anthropic/claude-sonnet-5-5` $\to$ `openai-codex/gpt-6.1-sol` $\to$ `xai-oauth/grok-build`. With `retry.usageAwareFallback: true`, OMP hops automatically when the Google daily/weekly meter fills.
- **No `openrouter` or `nvidia` model appears in any role or chain.** v33 excluded external API tiers (OpenRouter GLM 5.3 Flash, NVIDIA Nemotron) to fit the four paid subscriptions; earlier GLM/Nemotron floors are historical (see the v17-v23 log in `model-roles.yml`).
- **`vision`** keeps `google-antigravity/gemini-3.8-flash` primary, falling back to `anthropic/claude-sonnet-5-5` $\to$ `openai-codex/gpt-6.1-sol` $\to$ `xai-oauth/grok-4.7`. (The 2026-08-22 OpenRouter Gemini 3.8 Flash A/B winner is no longer in the chain.)
- **`critical` keeps strict cross-provider independent provenance**: primary `openai-codex/gpt-6.1-sol`, then `google-antigravity/gemini-4-argon`, then `xai-oauth/grok-4.7`. Independence holds against Anthropic producers; if a producer has failed over to Sol, the producer/reviewer collision must be caught by `critical`'s own provenance check. Argon's weekly meter is exhausted until ~2026-10-24, so a Sol failure currently falls through to Grok 4.7 in practice.
- **`slow` / `plan` run on `anthropic/claude-opus-5-5`**, falling back to `openai-codex/gpt-6.1-sol` $\to$ `google-antigravity/gemini-4-argon` $\to$ `google-antigravity/claude-opus-5-5` $\to$ `xai-oauth/grok-4.7`. `review` and `security` use the same chain (primaries: Sonnet 5.5).
- **The `architect` agent binds to `@slow`** (v36). The redundant `architect` role/chain/carousel entry was collapsed into `@slow` (both ran Opus 5.5 on identical fallback chains). The read-only consultant agent contract lives in `agents/architect.md`.
- **`sage` (Thinking Partner) is on `anthropic/claude-fable-5-1` since v35 — provisional and reversible.** Failover is Opus 5.5 $\to$ Antigravity Opus 5.5 $\to$ Sol 6.1 $\to$ Gemini 4 Argon $\to$ Grok 4.7, owned by the **model-level** `anthropic/claude-fable-5-1` / `claude-fable-5` chains: OMP checks exact model-key chains before role-key chains (`omp://settings.md`; also seen in the binary strings), so the role-level `sage` chain (Antigravity Opus 5.5 $\to$ Sol 6.1 $\to$ Argon $\to$ Grok 4.7) applies only if `sage` reverts to Opus. Antigravity Opus precedes Sol so `sage` does not drain the Plus 5h window that `critical` swarms exhaust; Argon stays late because its weekly meter is exhausted until ~2026-10-24. Emits no rigid JSON schema. **Revert:** set `modelRoles.sage` back to `anthropic/claude-opus-5-5`.
- **Why Fable for `sage`, and what is not proven.** Access: 2026-10-20 probes accepted Fable 5.1 via Max OAuth. Quality is **unresolved**: a blind A/B (3 sage-style prompts × 4 models, one answer per model per prompt, thinking high, delivered ids verified) gave mean rubric scores (1-10) that depend on the judge's family — Sonnet 5.5 ×3: Fable 8.19, Opus 7.98, Astra 6.61, Sol 6.30; Grok 4.7 (neutral): Fable 8.43, Opus 8.13, Astra 7.85, Sol 7.74; Sol 6.1: Astra 8.83, Sol 8.70, Fable 6.35, Opus 6.28. Judge-family self-preference dominates; prompt P1 leaked first-person model identity, and excluding P1 Sonnet's Fable–Opus gap vanishes (8.14 vs 8.19); n = 3 prompts, not 9. Chosen anyway on low volume (4 sessions in 14 days, ~2 completed dispatches/week, all on Opus: $4.50 API-equivalent, ~$1.12/dispatch), the best published pushback evidence (AA-PersonalityBench: Fable #1 of 36 on "constructively pushes back"; Arena creative writing Opus 5.5 #1, Fable 5.1 #9, Sol 6.1 #30, Astra #38), and decorrelation from the Opus-based `plan`/`architect`/`slow` (inference). **Estimates:** Fable ~2.4x cost and ~1.6x latency per answer in the batch (≈$2.6/dispatch, roughly +1.6 weekly-pool points vs Opus at 2 dispatches/week; the $185 ≈ 100% weekly calibration is rough).
- **Fable operational caveats.** Fable reasoning blocks are readable only by Fable/Mythos: a mid-session Fable → Opus failover drops that reasoning, and OMP may skip same-provider fallback when signed thinking history exists (fresh dispatches are unaffected). Fable always thinks, and safeguard classifiers can substitute Opus 4.8/Opus 5 server-side (`providers.anthropic.serverSideFallback` defaults to false). It draws the shared Max weekly pool faster, no published multiplier. Policy risk: OMP presents as Claude Code over Max OAuth (can1357/oh-my-pi issue 12487); Anthropic's 2026-10-07 update says subscription limits remain usable with third-party apps. Max's $100/mo API credits cover API-key use, not OAuth.
- **Astra (`openai-codex/gpt-6-astra`) is in no role and no chain.** Probe-verified accepted on Plus on 2026-10-20, but it draws the same Plus 5h/7d meter as Sol (no failover resilience when Plus saturates); list price is ~5x Sol 6.1 ($10/$50 vs $2/$10 per M tokens; Artificial Analysis cost/task $3.26 vs $0.72) for an Intelligence Index of 53 vs 52, with Coding Agent Index within 1-2 points; Arena creative writing ranks it #38 vs Opus 5.5 #1. A coarse burn probe saw 13.8K Astra tokens = +1 meter point = 40.8K Sol tokens (whole-percent granularity: hypothesis ~3-5x, not a measured ratio). Use only as an explicit one-off — `--model openai-codex/gpt-6-astra` — when stuck and Plus has headroom. Earlier README text placing Astra in sage's fallback chain no longer applies.
- **`task` runs on `anthropic/claude-sonnet-5-5`**, falling back to `openai-codex/gpt-6.1-sol` $\to$ `google-antigravity/gemini-3.8-flash` $\to$ `xai-oauth/grok-build`. The bundled `task` agent (and Vibe's `good` tier) already binds to `@task`, so no override is needed (v36 removed the duplicate `good_worker` role). Sol 6.1 ($2/M input, $0.10/M cached, $10/M output, 128K max output in the installed catalog) serves as `critical` primary and first fallback; the shared overlay enables extended context, giving Codex Sol an effective **922K** window; turning it off would cap it at **272K**.
- **`designer` role removed** (v36). OMP has no built-in designer role or agent; invoke `xai-oauth/grok-4.7` directly via `/model xai-oauth/grok-4.7` when design work is needed.
- **`smol` runs on `anthropic/claude-sonnet-5-5`** (chain: Luna $\to$ Gemini 3.5 Flash-Lite $\to$ Grok Build). **`tiny` runs on `anthropic/claude-haiku-5-5:low`** (chain: Luna $\to$ Gemini 3.5 Flash-Lite $\to$ `grok-composer-2.5-fast`). **Bundled `sonic` (Vibe's `fast` tier) is routed with `task.agentModelOverrides.sonic: "@tiny"`** (v36, replacing the `fast_worker` role): bundled `sonic` otherwise binds to `@smol` (Sonnet 5.5). The override names a role, not a bare model, on purpose: a role-less pinned subagent falls back through the `default` chain (Sonnet first). History: v24 moved the cheap tier off OpenAI's retired `gpt-5.3-codex-spark` onto Grok; v33 moved it onto Haiku.
- **`widget` runs on `anthropic/claude-haiku-5-5:low`** (v36; chain: Gemini 3.5 Flash-Lite $\to$ Grok Composer 2.5 Fast). Resolves OMP 18.12.3's `async.widgets: true` background job author defaulting to `smol` (Sonnet 5.5), protecting frontier quota while providing fast, concise status-line widgets.
- **`judge` runs on `typesafe/jev-1.14.0`** (v36; chain: `typesafe/jev-latest` $\to$ `typesafe/jev-preview` $\to$ `google-antigravity/gemini-3.5-flash-lite`). Uses stored TypeSafe credentials in `agent.db` to activate semantic `find` in `architect` under OMP's `find.enabled: auto` default, and powers typed Eval judgments (`judge()`, `judge_batch()`) without falling back to chat completions.
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
| Focused code defects / security issues | Bundled `reviewer` / `security-reviewer` |
| Challenge the premise or explore a different direction | `sage` |
| Adversarial check before a high-risk release/migration | `critical`, with producer identity and validation evidence |
| Human approval required before any implementation | `/plan`; prewalk is not an approval boundary |

**Roles select models; agents select instructions.** `/model @slow` or
Ctrl+P selects Opus 5.5, not `agents/architect.md`'s read-only review contract.
Request "use the architect agent to review X" for that contract; the agent binds to `@slow`.
`slow` and `plan` share Opus 5.5; `review`, `security`, `smol`, and the workers use Sonnet 5.5;
`sage` is on Fable 5.1; `critical` is the only Sol-primary role. Different prompts on one
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

The mapping references four providers: `anthropic`, `openai-codex`, `google-antigravity`,
`xai-oauth`. Run `omp usage` on the target machine to confirm each provider
is logged in.

## Installation

To use the role/fallback overlay for a new session without changing global settings,
run `omp --config ./model-roles.yml` from this repository. The companion model
overrides and custom agents still use the installation steps below.

### Option A — merge into the global config (affects every project on that machine)
1. Run `omp config path`, then open `config.yml` in the printed agent directory.
2. Merge all top-level keys from `model-roles.yml` into `config.yml`, including `task`, `cycleOrder`, and `extendedContext: true`, preserving unrelated settings.
3. In the same directory, open `models.yml` (create if missing) and copy in `models-overlay.yml`'s `providers:` block. (It only sets an OpenRouter `maxTokens` override; no current chain references OpenRouter, so it is inert until one does — inference.)
4. Copy `agents/*.md` (`architect.md`, `critical.md`, and `sage.md`) into `~/.omp/agent/agents/`. The agents bind to role aliases (`@architect`, `@critical`, `@sage`), so `sage.md` runs on whatever `modelRoles.sage` is — Fable 5.1 after import.
5. Restart any running `omp` session.

Equivalent CLI commands for `config.yml`:
```bash
omp config set modelRoles '{"default":"google-antigravity/gemini-3.8-flash","smol":"anthropic/claude-sonnet-5-5","slow":"anthropic/claude-opus-5-5","plan":"anthropic/claude-opus-5-5","task":"anthropic/claude-sonnet-5-5","vision":"google-antigravity/gemini-3.8-flash","commit":"anthropic/claude-haiku-5-5:low","advisor":"google-antigravity/gemini-3.8-flash","tiny":"anthropic/claude-haiku-5-5:low","widget":"anthropic/claude-haiku-5-5:low","judge":"typesafe/jev-1.14.0","review":"anthropic/claude-sonnet-5-5","security":"anthropic/claude-sonnet-5-5","critical":"openai-codex/gpt-6.1-sol","sage":"anthropic/claude-fable-5-1"}'

omp config set task.agentModelOverrides '{"security-reviewer":"@security","reviewer":"@review","sonic":"@tiny"}'

omp config set retry.fallbackChains '{"default":["anthropic/claude-sonnet-5-5","openai-codex/gpt-6.1-sol","xai-oauth/grok-build"],"smol":["openai-codex/gpt-6-luna","google-antigravity/gemini-3.5-flash-lite","xai-oauth/grok-build"],"slow":["openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","google-antigravity/claude-opus-5-5","xai-oauth/grok-4.7"],"plan":["openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","google-antigravity/claude-opus-5-5","xai-oauth/grok-4.7"],"task":["openai-codex/gpt-6.1-sol","google-antigravity/gemini-3.8-flash","xai-oauth/grok-build"],"vision":["anthropic/claude-sonnet-5-5","openai-codex/gpt-6.1-sol","xai-oauth/grok-4.7"],"commit":["xai-oauth/grok-build","openai-codex/gpt-6-luna","google-antigravity/gemini-3.5-flash-lite"],"advisor":["anthropic/claude-haiku-5-5:low","openai-codex/gpt-6-luna","xai-oauth/grok-build"],"tiny":["openai-codex/gpt-6-luna","google-antigravity/gemini-3.5-flash-lite","xai-oauth/grok-composer-2.5-fast"],"widget":["google-antigravity/gemini-3.5-flash-lite","xai-oauth/grok-composer-2.5-fast"],"judge":["typesafe/jev-latest","typesafe/jev-preview","google-antigravity/gemini-3.5-flash-lite"],"review":["openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","google-antigravity/claude-opus-5-5","xai-oauth/grok-4.7"],"security":["openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","google-antigravity/claude-opus-5-5","xai-oauth/grok-4.7"],"critical":["google-antigravity/gemini-4-argon","xai-oauth/grok-4.7"],"sage":["google-antigravity/claude-opus-5-5","openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","xai-oauth/grok-4.7"],"anthropic/claude-fable-5-1":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-5-5","openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","xai-oauth/grok-4.7"],"anthropic/claude-fable-5":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-5-5","openai-codex/gpt-6.1-sol","google-antigravity/gemini-4-argon","xai-oauth/grok-4.7"]}'

omp config set retry.usageAwareFallback true
omp config set retry.usageReservePolicy auto
omp config set cycleOrder '["smol","default","slow","sage"]'
omp config set extendedContext true
```

## Verify
```bash
omp config get modelRoles --json       # sage must be anthropic/claude-fable-5-1
omp config get retry.fallbackChains --json
omp config get extendedContext --json  # true on every machine
omp models find gpt-6.1-sol --json      # Codex contextWindow: 922000
omp usage
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
