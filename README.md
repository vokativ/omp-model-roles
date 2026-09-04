# OMP model-role setup — import instructions

**Snapshot: 2026-09-04 · v19.** Stale after ~4-6 weeks, or immediately if any subscription
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
```

Just importing the config? You need the two `.yml` files, `agents/`, and the import steps below —
nothing in `research/`.

## Design rationale (why these specific models, not just "the best ones")

This isn't a "use the top-benchmark model everywhere" config — it's balanced against real
subscription capacity, confirmed via `omp usage` on the source machine:

| Login | Plan | Capacity signal | Treat as |
|---|---|---|---|
| `anthropic` | Claude Pro, $20/mo | Smallest pool; 5h window peaked at **100% over 7d** (`omp usage --history`) | **scarce** — kept off `default` entirely; reserved for `architect`/`critical` primaries |
| `openai-codex` | ChatGPT Pro, $100/mo | 5x Plus quota; 7d peak at **13%** | **abundant** — absorb high-volume roles (`task`, `smol`, `tiny`, `slow`, `plan`, `review`, `security` + `default` first fallback) |
| `google-antigravity` | free preview (multiple credentials) | Google lane weekly metered; **Anthropic proxy lane abundant (0% used)** | **primary everyday lane & free pressure release** — `default`/`vision` primary + Claude proxy |
| `xai-oauth` | X Premium, $8/mo (bundled SuperGrok credits) | Small, weekly-reset credit pool | **primary for `designer` & `commit`** + depth-tier late fallback |
| `nvidia` | free NIM catalog | unmetered $0 floor | **last-resort $0 floor** — use `minimaxai/minimax-m3` (1M ctx, 16K out). `deepseek-v4-flash` was EOL 2026-08-07 |
| `openrouter` | prepaid credit balance | Pay-per-token, subscription-independent | **high-capability tier & vision fallback** — `z-ai/glm-5.3-flash` (58.2 agentic, 1.31M ctx, $0.075/$0.25) & `google/gemini-3.7-flash` |

Consequences baked into this file:
- **`default` stays primary on `google-antigravity/gemini-3.7-flash`** (fastest measured model and user daily preference), falling back to `openai-codex/gpt-5.6-terra` $\to$ `openrouter/z-ai/glm-5.3-flash` $\to$ `nvidia/minimaxai/minimax-m3`. With `retry.usageAwareFallback: true`, OMP automatically hops to Terra when the Google daily/weekly meter fills.
- **`openrouter/z-ai/glm-5.3-flash` added as the capability tier across 8 chains**: Tested #1 on OpenRouter's Tau2-Bench Airline/Agentic benchmark (58.2 agentic, 71.5 coding), with 1.31M context, 131K output, and fast tool calling at $0.075/$0.25 per million tokens.
- **`nvidia/minimaxai/minimax-m3` replaces dead DeepSeek V4 Flash**: Provides a zero-cost 1M-context floor in 8 chains. Deliberately excluded from depth roles (`slow`, `plan`, `architect`, `review`, `security`, `critical`) and `vision` to avoid silent output truncation against its 16,384 server-side token cap.
- **`vision`** retains `google-antigravity/gemini-3.7-flash` primary, with `openrouter/google/gemini-3.7-flash` (2026-08-22 A/B winner) as first fallback, followed by `gpt-5.6-terra` and `grok-4.6`.
- **`critical` first fallback changed to `openrouter/z-ai/glm-5.3-flash`**: Closes the open v14 defect where Sol collided with `slow`/`plan`/`review`/`security` producer roles; GLM is independent of all role primaries.
- **`anthropic/claude-sonnet-5` and `grok-4.6` dropped from `default`**: Preserves scarce Anthropic 5h quotas exclusively for `architect`/`critical` and avoids Grok tool-churn latency on daily turns.
- `slow`/`plan` remain on `openai-codex/gpt-5.6-sol` falling back to `anthropic/claude-opus-5` $\to$ `google-antigravity/claude-sonnet-4-6` $\to$ `xai-oauth/grok-4.6` $\to$ `openrouter/z-ai/glm-5.3-flash`.
- `advisor` points at `google-antigravity/claude-sonnet-4-6` — free Claude access via Antigravity's untouched Anthropic-proxy lane.
- **`sage` (Thinking Partner)** points at `anthropic/claude-opus-5`, backed by `google-antigravity/claude-opus-4-6` $\to$ `openai-codex/gpt-5.6-sol` $\to$ `google-antigravity/claude-sonnet-4-6` $\to$ `xai-oauth/grok-4.6` $\to$ `openrouter/z-ai/glm-5.3-flash`. Tailored for exploratory ideation, lateral thinking, and challenging orthodox assumptions without a rigid JSON schema.

### Optional: GPT-5.6 long context

`openai-codex` GPT-5.6 models support a 1M-token context window, but OMP's default
`extendedContext: false` caps them at 272K to avoid premium long-context consumption.
This is intentionally an owner decision, not a default for every authenticated OpenAI login:

- **Enable it** when the account owner confirms a ChatGPT Pro-or-higher plan (roughly $100/month)
  and has comfortable Codex quota. It does not pre-allocate 1M tokens; it only permits a session
  to grow beyond 272K when it actually needs to.
- **Leave it off** for Plus/basic/unknown plans or when preserving Codex quota matters more than
  unusually large repository or conversation context.
- Above 272K, OMP's Terra catalog marks input and cache usage at 2x, output at 1.5x, and cache
  writes at 2x. For an `openai-codex` subscription this is expected to consume the plan's usage
  allowance faster; it is not an instruction to add an API key or override `models.yml`.

Ask the owner before changing the setting. After approval:

```bash
omp config set extendedContext true
omp config get extendedContext --json
omp models find gpt-5.6-terra --json
```

The final command must report `openai-codex/gpt-5.6-terra` with
`contextWindow: 1000000`. Start a new OMP session after changing the setting. Do not set
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
omp config set modelRoles '{"default":"google-antigravity/gemini-3.7-flash","smol":"openai-codex/gpt-5.6-luna","slow":"openai-codex/gpt-5.6-sol","vision":"google-antigravity/gemini-3.7-flash","plan":"openai-codex/gpt-5.6-sol","commit":"xai-oauth/grok-build","designer":"xai-oauth/grok-4.6","task":"openai-codex/gpt-5.6-terra","advisor":"google-antigravity/claude-sonnet-4-6","tiny":"openai-codex/gpt-5.6-luna","architect":"anthropic/claude-opus-5","review":"openai-codex/gpt-5.6-sol","security":"openai-codex/gpt-5.6-sol","critical":"anthropic/claude-opus-5","fast_worker":"openai-codex/gpt-5.6-luna","good_worker":"openai-codex/gpt-5.6-terra","sage":"anthropic/claude-opus-5"}'

omp config set task.agentModelOverrides '{"security-reviewer":"@security","reviewer":"@review","sonic":"@fast_worker","task":"@good_worker"}'

omp config set retry.fallbackChains '{"default":["openai-codex/gpt-5.6-terra","openrouter/z-ai/glm-5.3-flash","nvidia/minimaxai/minimax-m3"],"smol":["google-antigravity/gemini-3.1-flash-lite","nvidia/minimaxai/minimax-m3"],"slow":["anthropic/claude-opus-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"plan":["anthropic/claude-opus-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"task":["google-antigravity/gemini-3.7-flash","openrouter/z-ai/glm-5.3-flash","nvidia/minimaxai/minimax-m3"],"designer":["openai-codex/gpt-5.6-terra","google-antigravity/gemini-3.7-flash","openrouter/z-ai/glm-5.3-flash"],"vision":["openrouter/google/gemini-3.7-flash","openai-codex/gpt-5.6-terra","xai-oauth/grok-4.6"],"commit":["openai-codex/gpt-5.6-luna","nvidia/minimaxai/minimax-m3"],"advisor":["openai-codex/gpt-5.6-terra","nvidia/minimaxai/minimax-m3"],"tiny":["xai-oauth/grok-composer-2.5-fast","google-antigravity/gemini-3.1-flash-lite","nvidia/minimaxai/minimax-m3"],"architect":["openai-codex/gpt-5.6-sol","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"review":["anthropic/claude-opus-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"security":["anthropic/claude-opus-5","google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","openrouter/z-ai/glm-5.3-flash"],"critical":["google-antigravity/claude-opus-4-6","google-antigravity/claude-sonnet-4-6","openrouter/z-ai/glm-5.3-flash","openai-codex/gpt-5.6-sol","xai-oauth/grok-4.6"],"fast_worker":["xai-oauth/grok-build","google-antigravity/gemini-3.1-flash-lite","nvidia/minimaxai/minimax-m3"],"good_worker":["google-antigravity/gemini-3.7-flash","openrouter/z-ai/glm-5.3-flash","nvidia/minimaxai/minimax-m3"]}'

omp config set retry.usageAwareFallback true
omp config set retry.usageReservePolicy auto
omp config set cycleOrder '["smol","default","slow","architect","sage"]'
```

## Verify
```bash
omp config get modelRoles --json
omp config get retry.fallbackChains --json
omp models find openrouter/google/gemini-3.7-flash  # must show `google/gemini-3.7-flash` with 66K max-out
omp models find nvidia/minimaxai/minimax-m3
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
