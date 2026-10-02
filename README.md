# OMP model-role setup — import instructions

**Snapshot: 2026-10-02 · v29.** Stale after ~4-6 weeks, or immediately if any subscription
changed — check `research/RESEARCH-PLAYBOOK.md`'s staleness check before importing this blind.

`model-roles.yml` is a config **overlay**: `modelRoles`, `task.agentModelOverrides`,
`retry` policies/chains, `cycleOrder`, and owner-approved `extendedContext: true`.
No API keys. Merge into an existing config; do not replace unrelated local preferences.

Subscriptions or workload change? Don't hand-edit this file — see
`research/RESEARCH-PLAYBOOK.md` for the methodology and the questions to re-run before updating it.

## Repo layout

The repo root holds only what you actually import. Everything explaining *why* lives in
`research/`, so you can ignore it unless you're re-deriving the allocation.

```
model-roles.yml       <- the config overlay: modelRoles + retry.fallbackChains   (import this)
models-overlay.yml    <- companion models.yml overlay: per-model maxTokens fixes (import this too)
agents/               <- custom agent definitions: architect, critical, and sage (thinking partner) (import this too)
scripts/omp-wt/       <- cross-platform Git Worktree helper (Linux, macOS, Quest, Windows)
README.md             <- you are here: import steps + the rationale for the current values
research/
  RESEARCH-PLAYBOOK.md            <- how to re-derive the allocation from scratch; staleness check
  GEMINI-QUOTA-OPTIONS.md         <- 2026-08-15 investigation: Gemini/Antigravity quota burnout options
  META-MUSE-EVALUATION.md         <- 2026-08-25 evaluation: the `meta` provider, and why it wasn't adopted
  ARCHITECT-CRITICAL-AGENTS.md    <- 2026-08-26: wiring architect/critical into real subagent dispatch
  FABLE-EVALUATION.md         <- 2026-09-03: Claude Fable 5 / 5.1 evaluation for architect & critical
  THINKING-PARTNER-ROLE.md   <- 2026-09-04 · v19: Thinking Partner (`sage`) architecture, debate, and allocation
  SAGE-CREATIVE-INSTRUCTIONS.md <- 2026-09-04 · v19.1: cognitive divergence, anti-slop catalogs, and subtractive taste
```

Just importing the config? You need the two `.yml` files, `agents/`, and the import steps below —
nothing in `research/`.

## Design rationale (why these specific models, not just "the best ones")

This isn't a "use the top-benchmark model everywhere" config — it's balanced against real
subscription capacity, confirmed via `omp usage` on the source machine:

| Login | Plan | Capacity signal | Treat as |
|---|---|---|---|
| `anthropic` | Claude Pro, $20/mo | Smallest raw pool by tier; live reading 2026-09-23 was **10%** (5h) / **2%** (7d) used — currently has headroom (`omp usage`), eligible for launch reset credit | **structurally scarce, currently available** — kept off `default` entirely; reserved for `sage`/`critical` primaries (`anthropic/claude-opus-5-5`). Re-check `omp usage` before reallocating: point-in-time readings swing fast |
| `openai-codex` | ChatGPT Pro, $100/mo | 5x Plus quota; live reading 2026-10-01 was **27%** used (7d) / **73%** remaining (`omp usage`) | **structurally abundant, healthy headroom** — backs `task`/`smol`/`slow`/`plan`/`architect`/`review`/`security`/`good_worker`; `task`, `good_worker`, `slow`, `plan`, `review`, and `security` upgraded to GPT 6.1 Sol in v28 |
| `google-antigravity` | free preview (multiple credentials) | Google lane weekly 14% used (5h 41% used); **Claude & GPT shared proxy 10.7% weekly (0% 5h)** | **primary everyday lane & free pressure release** — `default`/`vision` primary + Claude proxy |
| `xai-oauth` | X Premium, $8/mo (bundled SuperGrok credits) | Small, weekly-reset credit pool | **primary for `designer` & `commit`** + depth-tier late fallback |
| `nvidia` | free NIM catalog | unmetered $0 floor | **last-resort $0 floor** — use `nvidia/nemotron-3-super-120b-a12b` (262K ctx, 262K out). `minimax-m3` was EOL 2026-09-09 |
| `openrouter` | prepaid credit balance | Pay-per-token, subscription-independent | **high-capability tier & vision fallback** — `z-ai/glm-5.3-flash` (58.2 agentic, 1.31M ctx, $0.075/$0.25) & `google/gemini-3.8-flash` |

Consequences baked into this file:
- **`default` stays primary on `google-antigravity/gemini-3.8-flash`** (fastest measured model and user daily preference), falling back to `openai-codex/gpt-6.1-sol` $\to$ `openrouter/z-ai/glm-5.3-flash` $\to$ `nvidia/nvidia/nemotron-3-super-120b-a12b`. With `retry.usageAwareFallback: true`, OMP automatically hops to Sol when the Google daily/weekly meter fills.
- **`openrouter/z-ai/glm-5.3-flash` added as the capability tier across 8 chains**: Tested #1 on OpenRouter's Tau2-Bench Airline/Agentic benchmark (58.2 agentic, 71.5 coding), with 1.31M context, 131K output, and fast tool calling at $0.075/$0.25 per million tokens.
- **`nvidia/nvidia/nemotron-3-super-120b-a12b` replaces dead MiniMax M3**: Provides an unmetered zero-cost floor in 8 chains (262K context, 262K native max-out, sub-second TTFT). Unlike MiniMax M3, it has no 16K server-side token cap and supports the full thinking ladder and tool calling. Deliberately excluded from depth roles (`slow`, `plan`, `architect`, `review`, `security`, `critical`) and `vision` to reserve them for flagship reasoning and multimodal models.
- **`vision`** retains `google-antigravity/gemini-3.8-flash` primary, with `openrouter/google/gemini-3.8-flash` (2026-08-22 A/B winner) as first fallback, followed by `openai-codex/gpt-6.1-sol` and `grok-4.7`.
- **`critical` keeps cross-provider review as its normal path**: primary Opus 5.5, then Antigravity Opus 4.6, Antigravity Sonnet 4.6, GLM, Sol, and Grok. Fallbacks can collide with a producer, so actual resolved model provenance—not role names—controls the independence guard.
- **`anthropic/claude-sonnet-5` and `grok-4.6` dropped from `default`**: Preserves scarce Anthropic 5h quotas for `sage`/`critical` and avoids Grok tool-churn latency on daily turns.
- `slow`/`plan` remain on `openai-codex/gpt-6.1-sol` falling back to `anthropic/claude-opus-5-5` $\to$ `google-antigravity/claude-opus-4-6` $\to$ `google-antigravity/claude-sonnet-4-6` $\to$ `xai-oauth/grok-4.7` $\to$ `openrouter/z-ai/glm-5.3-flash`.
- `advisor` points at `google-antigravity/claude-sonnet-4-6` — free Claude access via Antigravity's untouched Anthropic-proxy lane.
- **`architect` moves to `openai-codex/gpt-6.1-sol` in v29** for frequent technical reviews as well as architecture decisions. Its read-only agent returns proportional Markdown rather than a mandatory RFC-shaped JSON object. The installed catalog lists Sol at $2/$10 per million input/output tokens versus Astra at $10/$50; cached input is $0.10 versus $1. These are catalog prices, not measured subscription-quota multipliers or proof of review-quality parity. Its fallbacks remain Antigravity Opus 4.6 → direct Opus 5.5 → Antigravity Sonnet 4.6 → Grok 4.7 → GLM. Astra remains available by explicit model selection and in Sage's existing fallback chain.
- **`sage` (Thinking Partner)** stays on `anthropic/claude-opus-5-5` for provider diversity, backed by `google-antigravity/claude-opus-4-6` $\to$ `openai-codex/gpt-6-astra` $\to$ `openai-codex/gpt-6.1-sol` $\to$ `google-antigravity/claude-sonnet-4-6` $\to$ `xai-oauth/grok-4.7` $\to$ `openrouter/z-ai/glm-5.3-flash`. Emits no rigid JSON schema.
- **`task` / `good_worker` use `openai-codex/gpt-6.1-sol`**: $2/M input, $0.10/M cached input, $10/M output, and 128K max output in the installed catalog. The shared v29 overlay enables extended context, giving Codex Sol an effective **922K** window; turning it off would cap it at **272K**.
- **`designer` and fallback chains upgraded to `xai-oauth/grok-4.7`**: Grok 4.7 (2026-09-21) delivers higher benchmark performance (DeepSWE 71.0% vs 65.2%, Terminal-Bench 37.6% vs 20.3%) and improved presentation/document design at identical pricing ($2/$6), operating within the existing X Premium SuperGrok credit pool. `commit` and `fast_worker` remain on `xai-oauth/grok-build` and `tiny` on `xai-oauth/grok-composer-2.5-fast`.
- **`tiny` and `fast_worker` (sonic) moved off retired `openai-codex/gpt-5.3-codex-spark` in v24** to `xai-oauth/grok-composer-2.5-fast` and `xai-oauth/grok-build` respectively: OpenAI retired Spark the week of 2026-09-13 (confirmed via `omp models find gpt-5.3-codex-spark` returning zero catalog hits, plus community reports of it vanishing from the Codex CLI selector while its dedicated quota meter stayed visible). Both roles now run on healthy `xai-oauth` capacity (9% of the weekly SuperGrok pool used) and each promotes its former tier-1 fallback to primary, dropping the now-dead leading fallback entry.

### Extended context: one enabled configuration everywhere

After the 2026-10-02 cross-machine review, the owner chose **one configuration
everywhere: `extendedContext: true`**. This supersedes both the initial off trial
and the interim machine-local proposal. The portable overlay and CLI import
commands now enable it explicitly. The Ubuntu development server was already on;
the Mac was subsequently enabled to match. No separate profile is necessary.

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
| Build/fix with a useful exploration phase and routine implementation | Sol → Luna prewalk, explicitly opted in |
| Hard reasoning remains throughout implementation | Stay on `@slow`; no forced downgrade |
| Review a design, implementation, plan, or configuration | Ask for the `architect` agent; define the question and scope |
| Focused code defects / security issues | Bundled `reviewer` / `security-reviewer` |
| Challenge the premise or explore a different direction | `sage` |
| Adversarial check before a high-risk release/migration | `critical`, with producer identity and validation evidence |
| Human approval required before any implementation | `/plan`; prewalk is not an approval boundary |

**Roles select models; agents select instructions.** `/model @architect` or
Ctrl+P selects Sol, not `agents/architect.md`'s read-only review contract.
Request "use the architect agent to review X" for that contract. `slow`,
`architect`, `review`, and implementation workers currently share Sol; `sage` and
`critical` share Opus. Different prompts can help but are not independent model votes.
Keep reviews targeted; do not run all four by habit. Retain `critical`'s structured
verdict/provenance schema; architect's schema was removed for human usability, not
because its performance overhead was measured.

### Implementation with prewalk

Start a new implementation session:

```bash
omp --model @slow --prewalk-into @smol "Implement X; preserve Y; verify Z."
```

This starts on Sol and targets Luna with the current role mappings (fallbacks may
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
  Its reported costs/pass rates are not measurements of our Sol/Luna pair.
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

The mapping references six providers: `anthropic`, `openai-codex`, `google-antigravity`,
`xai-oauth`, `nvidia`, `openrouter`. Run `omp usage` on the target machine to confirm each provider
is logged in.

## Installation

### Option A — merge into the global config (affects every project on that machine)
1. Run `omp config path`, then open `config.yml` in the printed agent directory.
2. Merge all top-level keys from `model-roles.yml` into `config.yml`, including `task`, `cycleOrder`, and `extendedContext: true`, preserving unrelated settings.
3. In the same directory, open `models.yml` (create if missing) and copy in `models-overlay.yml`'s `providers:` block.
4. Copy `agents/*.md` (`architect.md`, `critical.md`, and `sage.md`) into `~/.omp/agent/agents/`.
5. Restart any running `omp` session.

Equivalent CLI commands for `config.yml`:
```bash
omp config set modelRoles '{"default":"google-antigravity/gemini-3.8-flash","smol":"openai-codex/gpt-6-luna","slow":"openai-codex/gpt-6.1-sol","vision":"google-antigravity/gemini-3.8-flash","plan":"openai-codex/gpt-6.1-sol","commit":"xai-oauth/grok-build","designer":"xai-oauth/grok-4.7","task":"openai-codex/gpt-6.1-sol","advisor":"google-antigravity/claude-sonnet-4-6","tiny":"xai-oauth/grok-composer-2.5-fast","architect":"openai-codex/gpt-6.1-sol","review":"openai-codex/gpt-6.1-sol","security":"openai-codex/gpt-6.1-sol","critical":"anthropic/claude-opus-5-5","fast_worker":"xai-oauth/grok-build","good_worker":"openai-codex/gpt-6.1-sol","sage":"anthropic/claude-opus-5-5"}'

omp config set task.agentModelOverrides '{"security-reviewer":"@security","reviewer":"@review","sonic":"@fast_worker","task":"@good_worker"}'

omp config set retry.fallbackChains '{"default":["openai-codex/gpt-6.1-sol","openrouter/z-ai/glm-5.3-flash","nvidia/nvidia/nemotron-3-super-120b-a12b"],"smol":["google-antigravity/gemini-3.1-flash-lite","nvidia/nvidia/nemotron-3-super-120b-a12b"],"slow":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.7","openrouter/z-ai/glm-5.3-flash"],"plan":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.7","openrouter/z-ai/glm-5.3-flash"],"task":["google-antigravity/gemini-3.8-flash","openrouter/z-ai/glm-5.3-flash","nvidia/nvidia/nemotron-3-super-120b-a12b"],"designer":["openai-codex/gpt-6.1-sol","google-antigravity/gemini-3.8-flash","openrouter/z-ai/glm-5.3-flash"],"vision":["openrouter/google/gemini-3.8-flash","openai-codex/gpt-6.1-sol","xai-oauth/grok-4.7"],"commit":["openai-codex/gpt-6-luna","nvidia/nvidia/nemotron-3-super-120b-a12b"],"advisor":["openai-codex/gpt-6.1-sol","nvidia/nvidia/nemotron-3-super-120b-a12b"],"tiny":["google-antigravity/gemini-3.1-flash-lite","nvidia/nvidia/nemotron-3-super-120b-a12b"],"architect":["google-antigravity/claude-opus-4-6","anthropic/claude-opus-5-5","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.7","openrouter/z-ai/glm-5.3-flash"],"review":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.7","openrouter/z-ai/glm-5.3-flash"],"security":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.7","openrouter/z-ai/glm-5.3-flash"],"critical":["google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","openrouter/z-ai/glm-5.3-flash","openai-codex/gpt-6.1-sol","xai-oauth/grok-4.7"],"fast_worker":["google-antigravity/gemini-3.1-flash-lite","nvidia/nvidia/nemotron-3-super-120b-a12b"],"good_worker":["google-antigravity/gemini-3.8-flash","openrouter/z-ai/glm-5.3-flash","nvidia/nvidia/nemotron-3-super-120b-a12b"],"sage":["google-antigravity/claude-opus-4-6","openai-codex/gpt-6-astra","openai-codex/gpt-6.1-sol","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.7","openrouter/z-ai/glm-5.3-flash"],"anthropic/claude-fable-5-1":["anthropic/claude-opus-5-5","openai-codex/gpt-6.1-sol","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","openrouter/z-ai/glm-5.3-flash","xai-oauth/grok-4.7"],"anthropic/claude-fable-5":["anthropic/claude-opus-5-5","openai-codex/gpt-6.1-sol","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","openrouter/z-ai/glm-5.3-flash","xai-oauth/grok-4.7"]}'

omp config set retry.usageAwareFallback true
omp config set retry.usageReservePolicy auto
omp config set cycleOrder '["smol","default","slow","architect","sage"]'
omp config set extendedContext true
```

## Verify
```bash
omp config get modelRoles --json
omp config get retry.fallbackChains --json
omp config get extendedContext --json  # true on every machine
omp models find gpt-6.1-sol --json      # Codex contextWindow: 922000
omp models find openrouter/google/gemini-3.8-flash  # must show `google/gemini-3.8-flash` with 66K max-out
omp models find nemotron-3-super
omp models find openrouter/z-ai/glm-5.3-flash
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
