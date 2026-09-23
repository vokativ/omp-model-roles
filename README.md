# OMP model-role setup — import instructions

**Snapshot: 2026-09-23 · v25.** Stale after ~4-6 weeks, or immediately if any subscription
changed — check `research/RESEARCH-PLAYBOOK.md`'s staleness check before importing this blind.

`model-roles.yml` is a config **overlay**: `modelRoles`, `retry.fallbackChains`, and
`retry.usageAwareFallback`/`retry.usageReservePolicy`. No API keys. Safe to copy anywhere,
commit to a repo, or paste into an existing config.

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
| `openai-codex` | ChatGPT Pro, $100/mo | 5x Plus quota; live reading 2026-09-23 was **26%** used (7d) / **74%** remaining (`omp usage`) | **structurally abundant, healthy headroom** — backs `task`/`smol`/`slow`/`plan`/`architect`/`review`/`security`/`good_worker`; `task` and `good_worker` upgraded from Terra to GPT-6 Sol in v26 |
| `google-antigravity` | free preview (multiple credentials) | Google lane weekly 14% used (5h 41% used); **Claude & GPT shared proxy 10.7% weekly (0% 5h)** | **primary everyday lane & free pressure release** — `default`/`vision` primary + Claude proxy |
| `xai-oauth` | X Premium, $8/mo (bundled SuperGrok credits) | Small, weekly-reset credit pool | **primary for `designer` & `commit`** + depth-tier late fallback |
| `nvidia` | free NIM catalog | unmetered $0 floor | **last-resort $0 floor** — use `nvidia/nemotron-3-super-120b-a12b` (262K ctx, 262K out). `minimax-m3` was EOL 2026-09-09 |
| `openrouter` | prepaid credit balance | Pay-per-token, subscription-independent | **high-capability tier & vision fallback** — `z-ai/glm-5.3-flash` (58.2 agentic, 1.31M ctx, $0.075/$0.25) & `google/gemini-3.8-flash` |

Consequences baked into this file:
- **`default` stays primary on `google-antigravity/gemini-3.8-flash`** (fastest measured model and user daily preference), falling back to `openai-codex/gpt-6-sol` $\to$ `openrouter/z-ai/glm-5.3-flash` $\to$ `nvidia/nvidia/nemotron-3-super-120b-a12b`. With `retry.usageAwareFallback: true`, OMP automatically hops to Sol when the Google daily/weekly meter fills.
- **`openrouter/z-ai/glm-5.3-flash` added as the capability tier across 8 chains**: Tested #1 on OpenRouter's Tau2-Bench Airline/Agentic benchmark (58.2 agentic, 71.5 coding), with 1.31M context, 131K output, and fast tool calling at $0.075/$0.25 per million tokens.
- **`nvidia/nvidia/nemotron-3-super-120b-a12b` replaces dead MiniMax M3**: Provides an unmetered zero-cost floor in 8 chains (262K context, 262K native max-out, sub-second TTFT). Unlike MiniMax M3, it has no 16K server-side token cap and supports the full thinking ladder and tool calling. Deliberately excluded from depth roles (`slow`, `plan`, `architect`, `review`, `security`, `critical`) and `vision` to reserve them for flagship reasoning and multimodal models.
- **`vision`** retains `google-antigravity/gemini-3.8-flash` primary, with `openrouter/google/gemini-3.8-flash` (2026-08-22 A/B winner) as first fallback, followed by `openai-codex/gpt-6-sol` and `grok-4.6`.
- **`critical` first fallback changed to `openrouter/z-ai/glm-5.3-flash`**: Closes the open v14 defect where Sol collided with `slow`/`plan`/`review`/`security` producer roles; GLM is independent of all role primaries.
- **`anthropic/claude-sonnet-5` and `grok-4.6` dropped from `default`**: Preserves scarce Anthropic 5h quotas for `sage`/`critical` and avoids Grok tool-churn latency on daily turns.
- `slow`/`plan` remain on `openai-codex/gpt-6-sol` falling back to `anthropic/claude-opus-5-5` $\to$ `google-antigravity/claude-opus-4-6` $\to$ `google-antigravity/claude-sonnet-4-6` $\to$ `xai-oauth/grok-4.6` $\to$ `openrouter/z-ai/glm-5.3-flash`.
- `advisor` points at `google-antigravity/claude-sonnet-4-6` — free Claude access via Antigravity's untouched Anthropic-proxy lane.
- **`architect`** is primary on `openai-codex/gpt-6-astra`, backed by `google-antigravity/claude-opus-4-6` $\to$ `anthropic/claude-opus-5-5` $\to$ `openai-codex/gpt-6-sol` $\to$ `google-antigravity/claude-sonnet-4-6` $\to$ `xai-oauth/grok-4.6` $\to$ `openrouter/z-ai/glm-5.3-flash`, using the open OpenAI main pool without adding a standalone Astra role.
- **`sage` (Thinking Partner)** stays on `anthropic/claude-opus-5-5` for provider diversity, backed by `google-antigravity/claude-opus-4-6` $\to$ `openai-codex/gpt-6-astra` $\to$ `openai-codex/gpt-6-sol` $\to$ `google-antigravity/claude-sonnet-4-6` $\to$ `xai-oauth/grok-4.6` $\to$ `openrouter/z-ai/glm-5.3-flash`. Emits no rigid JSON schema.
- **`task` / `good_worker` upgraded to `openai-codex/gpt-6-sol`**: Following Simon Willison's 2026-09-22 pricing analysis, GPT-6 Sol is $2/M input, $0.20/M cached input, and $10/M output (cheaper than Terra's $12/M output and without long-context surcharges). Subagent implementation runs on Sol with 872K context and 128K output.
- **`tiny` and `fast_worker` (sonic) moved off retired `openai-codex/gpt-5.3-codex-spark` in v24** to `xai-oauth/grok-composer-2.5-fast` and `xai-oauth/grok-build` respectively: OpenAI retired Spark the week of 2026-09-13 (confirmed via `omp models find gpt-5.3-codex-spark` returning zero catalog hits, plus community reports of it vanishing from the Codex CLI selector while its dedicated quota meter stayed visible). Both roles now run on healthy `xai-oauth` capacity (9% of the weekly SuperGrok pool used) and each promotes its former tier-1 fallback to primary, dropping the now-dead leading fallback entry.

### Optional: GPT-6 long context

`openai-codex` GPT-6 models support up to an 872K-token context window, but OMP's default
`extendedContext: false` caps them at 272K to avoid premium long-context consumption.
This is intentionally an owner decision, not a default for every authenticated OpenAI login:

- **Enable it** when the account owner confirms a ChatGPT Pro-or-higher plan (roughly $100/month)
  and has comfortable Codex quota (currently `extendedContext: true` on this machine). It does not pre-allocate 872K tokens; it only permits a session
  to grow beyond 272K when it actually needs to.
- **Leave it off** for Plus/basic/unknown plans or when preserving Codex quota matters more than
  unusually large repository or conversation context.

Ask the owner before changing the setting. After approval:

```bash
omp config set extendedContext true
omp config get extendedContext --json
omp models find gpt-6-sol --json
```

The final command reports `openai-codex/gpt-6-sol` with
`contextWindow: 872000`. Start a new OMP session after changing the setting. Do not set
`contextWindow` or `maxTokens` manually in `models.yml`; those do not expand a provider limit.
## Prerequisite: auth

The mapping references six providers: `anthropic`, `openai-codex`, `google-antigravity`,
`xai-oauth`, `nvidia`, `openrouter`. Run `omp usage` on the target machine to confirm each provider
is logged in.

## Installation

### Option A — merge into the global config (affects every project on that machine)
1. Run `omp config path`, then open `config.yml` in the printed agent directory.
2. Copy in the `modelRoles:` and `retry:` blocks from `model-roles.yml`.
3. In the same directory, open `models.yml` (create if missing) and copy in `models-overlay.yml`'s `providers:` block.
4. Copy `agents/*.md` (`architect.md`, `critical.md`, and `sage.md`) into `~/.omp/agent/agents/`.
5. Restart any running `omp` session.

Equivalent CLI commands for `config.yml`:
```bash
omp config set modelRoles '{"default":"google-antigravity/gemini-3.8-flash","smol":"openai-codex/gpt-6-luna","slow":"openai-codex/gpt-6-sol","vision":"google-antigravity/gemini-3.8-flash","plan":"openai-codex/gpt-6-sol","commit":"xai-oauth/grok-build","designer":"xai-oauth/grok-4.6","task":"openai-codex/gpt-6-sol","advisor":"google-antigravity/claude-sonnet-4-6","tiny":"xai-oauth/grok-composer-2.5-fast","architect":"openai-codex/gpt-6-astra","review":"openai-codex/gpt-6-sol","security":"openai-codex/gpt-6-sol","critical":"anthropic/claude-opus-5-5","fast_worker":"xai-oauth/grok-build","good_worker":"openai-codex/gpt-6-sol","sage":"anthropic/claude-opus-5-5"}'

omp config set task.agentModelOverrides '{"security-reviewer":"@security","reviewer":"@review","sonic":"@fast_worker","task":"@good_worker"}'

omp config set retry.fallbackChains '{"default":["openai-codex/gpt-6-sol","openrouter/z-ai/glm-5.3-flash","nvidia/nvidia/nemotron-3-super-120b-a12b"],"smol":["google-antigravity/gemini-3.1-flash-lite","nvidia/nvidia/nemotron-3-super-120b-a12b"],"slow":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"plan":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"task":["google-antigravity/gemini-3.8-flash","openrouter/z-ai/glm-5.3-flash","nvidia/nvidia/nemotron-3-super-120b-a12b"],"designer":["openai-codex/gpt-6-sol","google-antigravity/gemini-3.8-flash","openrouter/z-ai/glm-5.3-flash"],"vision":["openrouter/google/gemini-3.8-flash","openai-codex/gpt-6-sol","xai-oauth/grok-4.6"],"commit":["openai-codex/gpt-6-luna","nvidia/nvidia/nemotron-3-super-120b-a12b"],"advisor":["openai-codex/gpt-6-sol","nvidia/nvidia/nemotron-3-super-120b-a12b"],"tiny":["google-antigravity/gemini-3.1-flash-lite","nvidia/nvidia/nemotron-3-super-120b-a12b"],"architect":["google-antigravity/claude-opus-4-6","anthropic/claude-opus-5-5","openai-codex/gpt-6-sol","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"review":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"security":["anthropic/claude-opus-5-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"critical":["google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","openrouter/z-ai/glm-5.3-flash","openai-codex/gpt-6-sol","xai-oauth/grok-4.6"],"fast_worker":["google-antigravity/gemini-3.1-flash-lite","nvidia/nvidia/nemotron-3-super-120b-a12b"],"good_worker":["google-antigravity/gemini-3.8-flash","openrouter/z-ai/glm-5.3-flash","nvidia/nvidia/nemotron-3-super-120b-a12b"],"sage":["google-antigravity/claude-opus-4-6","openai-codex/gpt-6-astra","openai-codex/gpt-6-sol","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"anthropic/claude-fable-5-1":["anthropic/claude-opus-5-5","openai-codex/gpt-6-sol","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","openrouter/z-ai/glm-5.3-flash","xai-oauth/grok-4.6"],"anthropic/claude-fable-5":["anthropic/claude-opus-5-5","openai-codex/gpt-6-sol","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","openrouter/z-ai/glm-5.3-flash","xai-oauth/grok-4.6"]}'

omp config set retry.usageAwareFallback true
omp config set retry.usageReservePolicy auto
omp config set cycleOrder '["smol","default","slow","architect","sage"]'
```

## Verify
```bash
omp config get modelRoles --json
omp config get retry.fallbackChains --json
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
