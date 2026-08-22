# OMP model-role setup — import instructions

**Snapshot: 2026-08-22 · v9.** Stale after ~4-6 weeks, or immediately if any subscription
changed — check `RESEARCH-PLAYBOOK.md`'s staleness check before importing this blind.

`model-roles.yml` is a config **overlay**: `modelRoles`, `retry.fallbackChains`, and
`retry.usageAwareFallback`/`retry.usageReservePolicy`. No API keys. Safe to copy anywhere,
commit to a repo, or paste into an existing config.

Subscriptions or workload change? Don't hand-edit this file — see `RESEARCH-PLAYBOOK.md`
in this repo for the methodology and the questions to re-run before updating it.

## Design rationale (why these specific models, not just "the best ones")

This isn't a "use the top-benchmark model everywhere" config — it's balanced against real
subscription capacity, confirmed via `omp usage` on the source machine:

| Login | Plan | Capacity signal | Treat as |
|---|---|---|---|
| `anthropic` | Claude Pro, $20/mo | Smallest pool (rolling 5h/7d windows) | **scarce** — kept off `default`'s primary path, used only as its fallback safety net |
| `openai-codex` | ChatGPT Pro, $100/mo | 5x Plus quota | **abundant** — absorb the heavy/high-volume roles |
| `google-antigravity` | free public preview | Separately meters Google/OpenAI/**Anthropic** usage — i.e. it's a free proxy that includes Claude models | **free pressure release** — use for anything that would otherwise double up on a paid pool |
| `xai-oauth` | X Premium, $8/mo (bundled SuperGrok credits, *not* standalone SuperGrok) | Small, weekly-reset credit pool | **primary for `designer`** (tested best there, see below) + sparing fallback elsewhere |
| `nvidia` | free NIM catalog | unmetered | **last-resort fallback**, quality is behind frontier |
| `openrouter` | prepaid credit balance | Pay-per-token, no subscription tie-in | **narrowly scoped** — first fallback for `vision` only, added after a real A/B test (see below) |

Consequences baked into this file:
- `default` (highest-volume, fires every turn) was moved off the scarce Anthropic pool onto
  `google-antigravity/gemini-3.7-flash` — it rides Antigravity's independent, daily-resetting
  Google lane instead of competing with `slow`/`plan`/`advisor` for the Claude Pro 5h/7d window.
  `anthropic/claude-sonnet-5` is now `default`'s first fallback instead of its primary: with
  `retry.usageAwareFallback: true` + `usageReservePolicy: "auto"`, OMP proactively hops to it
  before Gemini's daily lane hard-fails, so the scarce paid pool now sits almost idle as a
  safety net rather than absorbing every-turn volume directly.
- `slow`/`plan` (max-thinking, expensive-per-call) remain on `openai-codex/gpt-5.6-sol` — the flagship Codex tier on the abundant pool. Their fallback chain starts with `anthropic/claude-opus-5` to retain maximum reasoning depth during rare OpenAI transient outages, followed by `xai-oauth/grok-4.6` and NVIDIA DeepSeek V4 Pro.
- `architect` (Strategy C — high-leverage, infrequent architectural design) is assigned to `anthropic/claude-opus-5`. This leverages Claude's renowned architectural taste, RFC/contract structuring, and system decomposition on the scarce Pro pool without generating heavy volume, with `openai-codex/gpt-5.6-sol` as its first fallback.
- `review` & `security` (code review and vulnerability analysis) are assigned to `openai-codex/gpt-5.6-sol` — absorbing heavy diff analysis and static security sweeps on the abundant ChatGPT Pro pool, falling back to `claude-opus-5`.
- `critical` (high-stakes pre-commit audits and destructive action gating) is assigned to `anthropic/claude-opus-5` with `gpt-5.6-sol` fallback, ensuring independent cross-provider verification before major cutovers.
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
- `commit` (once per commit — genuinely low frequency) is the one place `xai-oauth/grok-build` is used as primary, so the X login gets real use without meaningfully risking its small weekly pool. `grok-4.6` is the first non-OpenAI contingency for `slow`/`plan`, followed by NVIDIA; it cannot drain the pool through routine use.
- Every fallback chain uses a *different provider* than its primary, so a single provider outage/quota exhaustion doesn't take out both tiers at once.
- Deliberately **not** using `claude-fable-5`/`claude-mythos-5` (Anthropic's largest models) anywhere — on the Pro plan those bill through separate credits, i.e. the "buy more" trap.
- `default`/`vision` both primary on `gemini-3.7-flash` (GA Aug 13 2026, newest stable Flash
  tier) via `google-antigravity`; `gemini-3.6-flash` is still live but one generation behind.
  `designer` no longer shares that meter — see above.
- `tiny` is explicitly assigned to `openai-codex/gpt-5.6-luna` with fallback chain: `nvidia/meta/llama-3.1-8b-instruct` $\to$ `xai-oauth/grok-composer-2.5-fast` $\to$ `google-antigravity/gemini-3.1-flash-lite`. Background tasks (session titles, Mnemopi memory extraction, auto-thinking classifier, unexpected-stop detector) run on the abundant ChatGPT Pro pool (97% idle). If OpenAI experiences transient issues, it fails over immediately to NVIDIA's live NIM Llama 3.1 8B (sub-second latency, 100% unmetered and free) and xAI Grok Composer Fast, with Gemini 3.1 Flash-Lite as the final safety net — providing total protection for the Google Antigravity daily lane that `default` and `vision` rely on.
- `task.agentModelOverrides` binds bundled subagents to their dedicated roles: `security-reviewer` $\to$ `@security`, `reviewer` $\to$ `@review`, `sonic` $\to$ `@fast_worker`, `task` $\to$ `@good_worker`.

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
1. Open `~/.omp/agent/config.yml` (create it if missing).
2. Copy in the `modelRoles:` and `retry:` blocks from `model-roles.yml` (the whole `retry:` map,
   including `fallbackChains`, `usageAwareFallback`, and `usageReservePolicy`).
   - If `modelRoles` or `retry` already exist there, replace them wholesale.
   - Leave every other key in that file untouched.
3. Open `~/.omp/agent/models.yml` (create it if missing — **different file** than `config.yml`
   above). Copy in `models-overlay.yml`'s `providers:` block. If `providers.openrouter` already
   exists there, merge `modelOverrides` in rather than replacing the whole provider entry.
4. Restart any running `omp` session.

Equivalent one-liners (no manual paste):
```bash
omp config set modelRoles '{"default":"google-antigravity/gemini-3.7-flash","smol":"openai-codex/gpt-5.6-luna","slow":"openai-codex/gpt-5.6-sol","vision":"google-antigravity/gemini-3.7-flash","plan":"openai-codex/gpt-5.6-sol","commit":"xai-oauth/grok-build","designer":"xai-oauth/grok-4.6","task":"openai-codex/gpt-5.6-terra","advisor":"google-antigravity/claude-sonnet-4-6","tiny":"openai-codex/gpt-5.6-luna","architect":"anthropic/claude-opus-5","review":"openai-codex/gpt-5.6-sol","security":"openai-codex/gpt-5.6-sol","critical":"anthropic/claude-opus-5","fast_worker":"openai-codex/gpt-5.6-luna","good_worker":"openai-codex/gpt-5.6-terra"}'

omp config set task.agentModelOverrides '{"security-reviewer":"@security","reviewer":"@review","sonic":"@fast_worker","task":"@good_worker"}'

omp config set retry.fallbackChains '{"default":["anthropic/claude-sonnet-5","openai-codex/gpt-5.6-terra","xai-oauth/grok-4.6","nvidia/meta/llama-3.1-8b-instruct"],"smol":["google-antigravity/gemini-3.1-flash-lite","nvidia/meta/llama-3.1-8b-instruct"],"slow":["anthropic/claude-opus-5","xai-oauth/grok-4.6","nvidia/meta/llama-3.1-8b-instruct"],"vision":["openrouter/google/gemini-3.7-flash","openai-codex/gpt-5.6-terra","xai-oauth/grok-4.6"],"plan":["anthropic/claude-opus-5","xai-oauth/grok-4.6","nvidia/meta/llama-3.1-8b-instruct"],"commit":["openai-codex/gpt-5.6-luna"],"designer":["openai-codex/gpt-5.6-terra","google-antigravity/gemini-3.7-flash"],"task":["google-antigravity/gemini-3.7-flash","nvidia/meta/llama-3.1-8b-instruct"],"advisor":["openai-codex/gpt-5.6-terra"],"tiny":["nvidia/meta/llama-3.1-8b-instruct","xai-oauth/grok-composer-2.5-fast","google-antigravity/gemini-3.1-flash-lite"],"architect":["openai-codex/gpt-5.6-sol","xai-oauth/grok-4.6","nvidia/meta/llama-3.1-8b-instruct"],"review":["anthropic/claude-opus-5","xai-oauth/grok-4.6","nvidia/meta/llama-3.1-8b-instruct"],"security":["anthropic/claude-opus-5","xai-oauth/grok-4.6","nvidia/meta/llama-3.1-8b-instruct"],"critical":["openai-codex/gpt-5.6-sol","xai-oauth/grok-4.6","nvidia/meta/llama-3.1-8b-instruct"],"fast_worker":["nvidia/meta/llama-3.1-8b-instruct","xai-oauth/grok-build","google-antigravity/gemini-3.1-flash-lite"],"good_worker":["google-antigravity/gemini-3.7-flash","nvidia/meta/llama-3.1-8b-instruct"]}'

omp config set retry.usageAwareFallback true
omp config set retry.usageReservePolicy auto
```

Also merge `models-overlay.yml` into `~/.omp/agent/models.yml` (required for `vision`'s
OpenRouter fallback — see rationale above):
```bash
omp config set providers.openrouter.modelOverrides '{"google/gemini-3.7-flash":{"maxTokens":65536}}' --file models.yml
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
omp config get providers.openrouter.modelOverrides --json --file models.yml
omp usage   # confirm which pools are actually getting hit
```
Then `/model` inside a session to confirm each role resolves to an available (authenticated)
model rather than silently falling back.
