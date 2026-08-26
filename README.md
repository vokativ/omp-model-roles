# OMP model-role setup — import instructions

**Snapshot: 2026-08-26 · v16.** Stale after ~4-6 weeks, or immediately if any subscription
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
agents/               <- role-backed custom agent definitions for architect + critical (import this too)
README.md             <- you are here: import steps + the rationale for the current values
research/
  RESEARCH-PLAYBOOK.md            <- how to re-derive the allocation from scratch; staleness check
  GEMINI-QUOTA-OPTIONS.md         <- 2026-08-15 investigation: Gemini/Antigravity quota burnout options
  META-MUSE-EVALUATION.md         <- 2026-08-25 evaluation: the `meta` provider, and why it wasn't adopted
  ARCHITECT-CRITICAL-AGENTS.md    <- 2026-08-26: wiring architect/critical into real subagent dispatch
```

Just importing the config? You need the two `.yml` files, `agents/`, and the import steps below —
nothing in `research/`.

## Design rationale (why these specific models, not just "the best ones")

This isn't a "use the top-benchmark model everywhere" config — it's balanced against real
subscription capacity, confirmed via `omp usage` on the source machine:

| Login | Plan | Capacity signal | Treat as |
|---|---|---|---|
| `anthropic` | Claude Pro, $20/mo | Smallest pool; 5h window **peaked at 94% over 30d** (`omp usage --history`) | **scarce** — kept off `default`'s primary path AND off its first fallback; now `default`'s third tier, a genuine safety net |
| `openai-codex` | ChatGPT Pro, $100/mo | 5x Plus quota | **abundant** — absorb the heavy/high-volume roles |
| `google-antigravity` | free public preview | Separately meters Google/OpenAI/**Anthropic** usage — i.e. it's a free proxy that includes Claude models | **free pressure release** — use for anything that would otherwise double up on a paid pool |
| `xai-oauth` | X Premium, $8/mo (bundled SuperGrok credits, *not* standalone SuperGrok) | Small, weekly-reset credit pool | **primary for `designer`** (tested best there, see below) + sparing fallback elsewhere |
| `nvidia` | free NIM catalog | unmetered | **last-resort fallback** — use `deepseek-ai/deepseek-v4-flash` (1M ctx). The small `meta/llama-3.1-8b-instruct` is **unusable here**: 16K context vs a measured 15.5K-26.7K first turn |
| `openrouter` | prepaid credit balance | Pay-per-token, no subscription tie-in | **narrowly scoped** — first fallback for `vision` only, added after a real A/B test (see below) |

Consequences baked into this file:
- `default` (highest-volume, fires every turn) was moved off the scarce Anthropic pool onto
  `google-antigravity/gemini-3.7-flash` — it rides Antigravity's independent, daily-resetting
  Google lane instead of competing with `slow`/`plan`/`advisor` for the Claude Pro 5h/7d window.
  `openai-codex/gpt-5.6-terra` is now `default`'s **first** fallback (promoted from second in v9),
  with `nvidia/deepseek-ai/deepseek-v4-flash` second and `anthropic/claude-sonnet-5` demoted to
  third. With `retry.usageAwareFallback: true` + `usageReservePolicy: "auto"`, OMP proactively
  hops down this chain before Gemini's lane hard-fails — so every-turn volume lands on the
  abundant ChatGPT Pro pool (7d peak **5%** over 30d) or a free unmetered pool, and the scarce
  Anthropic pool is only reached if both are unavailable. See the 2026-08-25 A/B below.
- `slow`/`plan` (max-thinking, expensive-per-call) remain on `openai-codex/gpt-5.6-sol` — the flagship Codex tier on the abundant pool. Their fallback chain starts with direct `anthropic/claude-opus-5` for maximum depth, then `google-antigravity/claude-sonnet-4-6` on Antigravity's separately-metered free Anthropic lane, then Grok and NVIDIA.
- `architect` (Strategy C — high-leverage, infrequent architectural design) stays on direct `anthropic/claude-opus-5`, with Sol first fallback and Antigravity Sonnet 4.6 second — preserving the existing flagship pair while adding a third provider/meter before the small Grok pool.
- `review` & `security` (code review and vulnerability analysis) stay on `openai-codex/gpt-5.6-sol`, falling back to direct Opus 5, then Antigravity Sonnet 4.6, then Grok/NVIDIA.
- `critical` remains an **explicit, manually-dispatched final implementation/operational gate** on direct Opus 5, not an automatic architect reviewer. Opus gives independent-provider review against likely producers: Gemini `default`, Terra `task`, Sol `slow`/`plan`/`review`/`security`, and Grok `designer`. Observed real use matches this: two adversarial implementation reviews in `parent-help-android`; no automatic trigger exists. Its first fallback stays Sol for flagship depth; Antigravity Sonnet 4.6 is now the second fallback before Grok. Provenance instructions still forbid unconditional `GO` when producer/reviewer models match or are unknown; architect remains the known same-model primary exception and needs the Sol-backed `reviewer` as an additional independent critique.
- `advisor` (would double per-turn cost the moment it's enabled) points at `google-antigravity/claude-sonnet-4-6` — free Claude access via Antigravity's separately-metered Anthropic-proxy lane, so turning advisor on doesn't touch the paid Anthropic pool at all.
- `vision` primaries on `google-antigravity/gemini-3.7-flash`, but its **first fallback is
  `openrouter/google/gemini-3.7-flash`** — same weights, different (billed) pool, added 2026-08-22
  after a real head-to-head test on an actual production image (a family WhatsApp screenshot with
  8+ dated events): the OpenRouter call was both faster (4.8s vs 21.2s) *and* the only one of four
  candidates with zero factual errors — native Antigravity, `gpt-5.6-terra`, and `xai-oauth/grok-4.6`
  each misread the same word ("Lapathon") differently, and each missed at least one real event.
  Requires `models-overlay.yml` merged into `~/.omp/agent/models.yml` — see below — or this
  fallback truncates output instead of failing over cleanly.
- `designer` was moved off `google-antigravity/gemini-3.7-flash` entirely — it's now
  **primary `xai-oauth/grok-4.6`, fallback `gpt-5.6-terra`, last-resort back to Antigravity
  Gemini**. Same 2026-08-22 A/B round (a responsive HTML/CSS event-card task): Grok's output
  included a semantic `<time datetime>` element and `prefers-reduced-motion` handling that
  neither competitor produced unprompted; Terra was a close second; native Antigravity Gemini
  was solidly usable but least polished of the three. Unlike `vision`, OpenRouter's Gemini call
  in this same round hit the truncation problem this repo now documents (see `models-overlay.yml`)
  and lost on quality even before that was fixed — it isn't part of `designer`'s chain at all.
- `commit` (once per commit — genuinely low frequency) remains the only `xai-oauth/grok-build` primary. `grok-4.6` stays a late contingency for depth roles, now *after* the free Antigravity Sonnet lane, so the X weekly pool cannot drain through routine fallback.
- Every fallback chain uses a *different provider* than its primary, so a single provider outage/quota exhaustion doesn't take out both tiers at once.
- Deliberately **not** using `claude-fable-5`/`claude-mythos-5` (Anthropic's largest models) anywhere — on the Pro plan those bill through separate credits, i.e. the "buy more" trap.
- Deliberately **not** using the `meta` provider (`muse-spark-1.2`, `muse-spark-1.2-contributor`)
  in any role, despite Contributor being ~31× cheaper per task than `gpt-5.6-terra`'s list price.
  Two structural reasons: the Contributor discount is paid for with permission for Meta to train
  on submitted prompts and completions (disqualifying for proprietary source), and a plain API key
  is excluded from `retry.usageAwareFallback`, so it can neither be hopped-off-of proactively nor
  relieve a metered pool. It also places behind `gpt-5.6-terra` on Meta's own published DeepSWE
  chart. Full evaluation, including the one role it *could* plausibly fit (`review`, Standard tier,
  non-blocking): `research/META-MUSE-EVALUATION.md`.
- `default`/`vision` both primary on `gemini-3.7-flash` (GA Aug 13 2026, newest stable Flash
  tier) via `google-antigravity`; `gemini-3.6-flash` is still live but one generation behind.
  `designer` no longer shares that meter — see above.
- `tiny` is explicitly assigned to `openai-codex/gpt-5.6-luna` with fallback chain: `nvidia/deepseek-ai/deepseek-v4-flash` $\to$ `xai-oauth/grok-composer-2.5-fast` $\to$ `google-antigravity/gemini-3.1-flash-lite`. Background tasks (session titles, Mnemopi memory extraction, auto-thinking classifier, unexpected-stop detector) run on the abundant ChatGPT Pro pool (97% idle). If OpenAI experiences transient issues, it fails over to NVIDIA's unmetered DeepSeek V4 Flash and xAI Grok Composer Fast, with Gemini 3.1 Flash-Lite as the final safety net — providing total protection for the Google Antigravity daily lane that `default` and `vision` rely on. **v10:** the previous first fallback, `nvidia/meta/llama-3.1-8b-instruct`, was removed here and in all 11 other chains — its 16K context cannot hold this harness's first turn (measured 15.5K-26.7K tokens), so it could never have served as a fallback at all.
- `task.agentModelOverrides` binds bundled subagents to their dedicated roles: `security-reviewer` $\to$ `@security`, `reviewer` $\to$ `@review`, `sonic` $\to$ `@fast_worker`, `task` $\to$ `@good_worker`.
- **v16 depth-tier expansion:** six depth roles (`slow`, `plan`, `review`, `security`, `architect`,
  `critical`) previously resolved across primary + first fallback to only two models
  (`gpt-5.6-sol`, `claude-opus-5`), then all dropped directly to `xai-oauth/grok-4.6` — the
  smallest pool and slowest candidate in the 2026-08-25 A/B. Added
  `google-antigravity/claude-sonnet-4-6` after the existing Sol/Opus flagship pair and before Grok
  in all six chains. This is cost-neutral, uses the separately-metered Antigravity Anthropic lane
  already proven by `advisor`, preserves Claude-class reasoning depth, and does not disturb the
  A/B-backed primary/first-fallback order.
- `architect` and `critical` existed only as `modelRoles`/`fallbackChains` entries through v12 —
  but **not as dispatchable subagents**: `task.agentModelOverrides` can only bind a role onto an
  *existing* bundled agent name (`reviewer`, `security-reviewer`, `sonic`, `task`), and no bundled
  agent is named `architect` or `critical`. `agents/architect.md` and `agents/critical.md` fix this
  via OMP's documented role-backed custom-agent pattern. Manual whole-session selection remains
  available with `/model @architect` or `/model @critical`; current `cycleOrder` includes
  `architect` but **not** `critical` (the earlier claim that both were there was stale).
  `task(agent: "architect", ...)` / `task(agent: "critical", ...)` are verified by five live
  dispatches, both resolving to configured `anthropic/claude-opus-5`. Both set `thinking: high`
  (deepest level every model in their fallback chains supports; `xhigh` would break on
  `deepseek-v4-flash`). `critical` adds a machine-checkable GO / NO-GO / GO-WITH-CONDITIONS schema
  with required producer/reviewer provenance and independence status; a same-model Opus-vs-Opus
  smoke test correctly returned `SAME-MODEL` + `GO-WITH-CONDITIONS`, never unconditional `GO`.
  `architect` gets `read`/`grep`/`glob`; `critical` adds `bash`, scoped in-prompt to
  non-destructive inspection. **These are advisory, not sandboxed:** `tools:` bounds built-in
  tools only — `hub` is auto-added, and MCP tools are injected regardless, so a dispatched agent
  can reach arbitrary code execution. This was demonstrated, not theorised. Neither auto-invokes;
  installing them makes them dispatchable, not automatically triggered. Full evidence:
  `research/ARCHITECT-CRITICAL-AGENTS.md`.

### 2026-08-25 A/B — what `default`'s chain order is actually based on

Five candidate models were run through an identical, objectively-graded harness rather than
compared on vendor benchmarks. Fixture: an MV3 browser extension with two independent seeded
root causes in two files (an async `sendResponse` channel closed by a missing `return true`,
and a read-modify-write race in a `chrome.storage` wrapper). Deterministic 1/4 passing before
the fix, 4/4 reachable. 3 trials per model, plus one research/prose task.

| Model | Pass | Wall mean | σ | Tokens mean | Tail | Cost/task |
|---|---|---|---|---|---|---|
| `google-antigravity/gemini-3.7-flash` | 3/3 | **37.8s** | 6.2 | 265,038 | **1.09×** | $0.1553 |
| `openai-codex/gpt-5.6-terra` | 3/3 | 63.2s | **0.8** | **248,632** | 1.16× | **$0.1337** |
| `anthropic/claude-sonnet-5` | 3/3 | 60.0s | 13.6 | 331,651 | 1.89× | $0.1891 |
| `nvidia/deepseek-ai/deepseek-v4-flash` | 3/3 | 46.5s | 8.1 | 352,096 | 1.70× | $0.1825 |
| `xai-oauth/grok-4.6` | 3/3 | 74.8s | 11.7 | 227,327 | 1.28× | bundled |

Findings that drove the v10 chain order:
- **Correctness did not discriminate.** All five passed 3/3, left `test/` untouched, correctly
  reported 2 root causes, and independently converged on the same fix (`return true` plus a
  rejection-isolated promise queue). No model gamed the tests. For this workload class the
  decision is therefore quota, latency and consistency — not capability.
- **Gemini stays primary on merit**, not just because it's free: it was the fastest model tested
  and had the tightest token spread. Its only problem is pool state (see below).
- **Terra promoted to first fallback**: 17× tighter latency variance than Sonnet 5 (σ 0.8s vs
  13.6s), lowest cost per task, on a pool whose 7d meter peaked at **5% over 30 days**.
- **Sonnet 5 demoted to third**: worst token profile of the five (331K mean, 1.89× worst/best
  tail) on the scarcest pool, whose 5h window peaked at **94% over 30 days**.
- **DeepSeek V4 Flash earned a real chain slot**: 3/3 on a free unmetered pool, and in the
  research task it independently found `omp usage --history` and cited "19 snapshots" — verified
  exactly correct. It replaces the non-functional 16K llama entry everywhere.
- **Grok 4.6 is viable but last**: full pool (0→1% after 4 tasks), yet the slowest model tested
  and the highest tool churn (19 calls/task) — a real tax on a role that fires every turn.
- On the research task all five detected that this repo's own quota claims were stale. Only
  `gemini-3.7-flash` additionally spotted that `research/GEMINI-QUOTA-OPTIONS.md` **contradicts itself**
  (its 2026-08-22 addendum records the 90% event that the 2026-08-15 body still denies).

Caveat: one moderate two-file task does not probe long-horizon multi-file refactors, where
DeepSWE v1.1 does separate the flagship tier (Claude Opus 5 74.0%, GPT-5.6 Sol 73.0%) from
mid-tier models. That regime is already routed to `slow`/`plan`/`architect`/`critical`.

If the target machine's subscriptions differ from the table above, don't paste this file blind —
re-derive the allocation from whatever pools that machine actually has (`omp usage` after logging in).

## Prerequisite: auth

The mapping references six providers: `anthropic`, `openai-codex`, `google-antigravity`,
`xai-oauth`, `nvidia`, `openrouter`. Any role whose provider isn't authenticated on the target
machine will
fail to select (falls through to the fallback chain, or errors if that's also unauthenticated).
Run `omp usage` on the target machine to confirm each provider is logged in before relying on
the roles below — and check that machine's own subscription tiers actually match the ones in
the rationale table, since the allocation assumes Pro-tier Anthropic/OpenAI, not Max/$200.

## Pick ONE of these on the target machine

### Option A — merge into the global config (affects every project on that machine)
1. Run `omp config path`, then open `config.yml` in the printed agent directory (create it if
   missing). This is platform-independent; the printed path is authoritative for profiles and
   custom roots. Without either, the default is `~/.omp/agent/` on POSIX and
   `%USERPROFILE%\.omp\agent\` on Windows.
2. Copy in the `modelRoles:` and `retry:` blocks from `model-roles.yml` (the whole `retry:` map,
   including `fallbackChains`, `usageAwareFallback`, and `usageReservePolicy`).
   - If `modelRoles` or `retry` already exist there, replace them wholesale.
   - Leave every other key in that file untouched.
3. In the same directory, open `models.yml` (create it if missing — **different file** than
   `config.yml`). Copy in `models-overlay.yml`'s `providers:` block. If `providers.openrouter`
   already exists there, merge `modelOverrides` in rather than replacing the whole provider entry.
4. Copy this repo's `agents/architect.md` and `agents/critical.md` into `~/.omp/agent/agents/`
   (create the directory if missing) so `architect`/`critical` become dispatchable via
   `task(agent: "architect"|"critical", ...)`, not just reachable through `/model`.
5. Restart any running `omp` session.

Equivalent commands for the settings in `config.yml` (no manual paste):
```bash
omp config set modelRoles '{"default":"google-antigravity/gemini-3.7-flash","smol":"openai-codex/gpt-5.6-luna","slow":"openai-codex/gpt-5.6-sol","vision":"google-antigravity/gemini-3.7-flash","plan":"openai-codex/gpt-5.6-sol","commit":"xai-oauth/grok-build","designer":"xai-oauth/grok-4.6","task":"openai-codex/gpt-5.6-terra","advisor":"google-antigravity/claude-sonnet-4-6","tiny":"openai-codex/gpt-5.6-luna","architect":"anthropic/claude-opus-5","review":"openai-codex/gpt-5.6-sol","security":"openai-codex/gpt-5.6-sol","critical":"anthropic/claude-opus-5","fast_worker":"openai-codex/gpt-5.6-luna","good_worker":"openai-codex/gpt-5.6-terra"}'

omp config set task.agentModelOverrides '{"security-reviewer":"@security","reviewer":"@review","sonic":"@fast_worker","task":"@good_worker"}'

omp config set retry.fallbackChains '{"default":["openai-codex/gpt-5.6-terra","nvidia/deepseek-ai/deepseek-v4-flash","anthropic/claude-sonnet-5","xai-oauth/grok-4.6"],"smol":["google-antigravity/gemini-3.1-flash-lite","nvidia/deepseek-ai/deepseek-v4-flash"],"slow":["anthropic/claude-opus-5","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","nvidia/deepseek-ai/deepseek-v4-flash"],"plan":["anthropic/claude-opus-5","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","nvidia/deepseek-ai/deepseek-v4-flash"],"task":["google-antigravity/gemini-3.7-flash","nvidia/deepseek-ai/deepseek-v4-flash"],"designer":["openai-codex/gpt-5.6-terra","google-antigravity/gemini-3.7-flash"],"vision":["openrouter/google/gemini-3.7-flash","openai-codex/gpt-5.6-terra","xai-oauth/grok-4.6"],"commit":["openai-codex/gpt-5.6-luna"],"advisor":["openai-codex/gpt-5.6-terra"],"tiny":["nvidia/deepseek-ai/deepseek-v4-flash","xai-oauth/grok-composer-2.5-fast","google-antigravity/gemini-3.1-flash-lite"],"architect":["openai-codex/gpt-5.6-sol","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","nvidia/deepseek-ai/deepseek-v4-flash"],"review":["anthropic/claude-opus-5","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","nvidia/deepseek-ai/deepseek-v4-flash"],"security":["anthropic/claude-opus-5","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","nvidia/deepseek-ai/deepseek-v4-flash"],"critical":["openai-codex/gpt-5.6-sol","google-antigravity/claude-sonnet-4-6","xai-oauth/grok-4.6","nvidia/deepseek-ai/deepseek-v4-flash"],"fast_worker":["nvidia/deepseek-ai/deepseek-v4-flash","xai-oauth/grok-build","google-antigravity/gemini-3.1-flash-lite"],"good_worker":["google-antigravity/gemini-3.7-flash","nvidia/deepseek-ai/deepseek-v4-flash"]}'

omp config set retry.usageAwareFallback true
omp config set retry.usageReservePolicy auto
```

`models.yml` is a model-registry file, not an `omp config` settings file. OMP has no
`omp config set`/`get` command that targets it: perform step 3 above to merge the companion
overlay. In a fresh shell, confirm the effective OpenRouter entry with:
```bash
omp models find openrouter/google/gemini-3.7-flash
```


### Option B — project-scoped (only affects repos you drop this into)
Best for overlapping repos across machines: commit it once, every machine that opens that
repo gets the same roles automatically, no manual sync needed.

```bash
mkdir -p <repo>/.omp
cp model-roles.yml <repo>/.omp/config.yml   # or merge if that file already has content
git add .omp/config.yml && git commit -m "omp: shared model roles"
```
Project config wins over global config for these keys (values fully replace, not merge,
per-key — see the settings precedence doc if the repo already sets `modelRoles`/`retry`).

`agents/architect.md` and `agents/critical.md` need the same treatment as `models.yml`: they're
files under `.omp/agents/`, not `omp config` keys, so copy them into `<repo>/.omp/agents/` for a
project-scoped install, or `~/.omp/agent/agents/` for the global one from Option A step 4.

### Option C — overlay file, loaded automatically, never merged by hand
Keep `model-roles.yml` in a synced dotfiles repo and point OMP at it permanently:
```bash
# add to shell profile (~/.zshrc, ~/.bashrc, etc.)
export PI_CONFIG_FILES=~/path/to/model-roles.yml
```
Or load it ad hoc for one run: `PI_CONFIG_FILES=~/path/to/model-roles.yml omp`.
This file is always read fresh — editing it on the source machine and re-syncing the
dotfiles repo propagates to every machine without any `omp config set`.

## Verify
```bash
omp config get modelRoles --json
omp config get task.agentModelOverrides --json
omp config get retry.fallbackChains --json
omp config get retry.usageAwareFallback --json
omp config get retry.usageReservePolicy --json
omp models find openrouter/google/gemini-3.7-flash  # must show `google/gemini-3.7-flash` with 66K max-out
omp usage   # confirm which pools are actually getting hit
```
Then `/model` inside a session to confirm each role resolves to an available (authenticated)
model rather than silently falling back. There's no CLI list command for custom agents; confirm
`architect`/`critical` dispatch by actually running `task(agent: "architect", task: "...")` once —
"Unknown agent" means `agents/*.md` didn't land in a discovered directory (`~/.omp/agent/agents/`
or `<project>/.omp/agents/`) or `task.disabledAgents` blocks the name.
