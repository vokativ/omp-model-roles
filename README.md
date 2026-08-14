# OMP model-role setup — import instructions

**Snapshot: 2026-08-14 · v4.** Stale after ~4-6 weeks, or immediately if any subscription
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
| `anthropic` | Claude Pro, $20/mo | Smallest pool (rolling 5h/7d windows) | **scarce** — reserve for the one highest-value role |
| `openai-codex` | ChatGPT Pro, $100/mo | 5x Plus quota | **abundant** — absorb the heavy/high-volume roles |
| `google-antigravity` | free public preview | Separately meters Google/OpenAI/**Anthropic** usage — i.e. it's a free proxy that includes Claude models | **free pressure release** — use for anything that would otherwise double up on a paid pool |
| `xai-oauth` | X Premium, $8/mo (bundled SuperGrok credits, *not* standalone SuperGrok) | Small, weekly-reset credit pool | **sparingly** — one low-frequency role + last-resort fallback only |
| `nvidia` | free NIM catalog | unmetered | **last-resort fallback**, quality is behind frontier |

Consequences baked into this file:
- `default` (highest-volume, fires every turn) stays on `anthropic/claude-sonnet-5` — that pool's smallness is fine because it's not also asked to carry `slow`/`plan`/`advisor`.
- `slow`/`plan` (max-thinking, expensive-per-call) remain on `openai-codex/gpt-5.6-sol` — the flagship Codex tier on the pool with headroom. Their fallback chain is `grok-4.6` then NVIDIA DeepSeek V4 Pro: direct Anthropic Opus was removed because it shares the already-exhausted Claude Pro five-hour window.
- `advisor` (would double per-turn cost the moment it's enabled) points at `google-antigravity/claude-sonnet-4-6` — free Claude access, so turning advisor on doesn't touch the paid Anthropic pool at all.
- `default` overflow now takes `gemini-3.7-flash` → `gpt-5.6-terra` → `grok-4.6` → DeepSeek V4 Pro. Gemini is first because it uses Antigravity's independent Google lane (0% used during this audit), carries a 1M context window, and is Google’s current stable mixed coding/knowledge-work agent model. Terra draws from the 94%-remaining Codex pool; Grok and NVIDIA are separately metered emergency tiers.
- `vision`/`designer` fallback to `gpt-5.6-terra` then `grok-4.6`, both image-capable and independent of the Google primary. This replaces the designer's direct Sonnet fallback, which cannot be relied on when the Claude Pro window is exhausted.
- `commit` (once per commit — genuinely low frequency) is the one place `xai-oauth/grok-build` is used as primary, so the X login gets real use without meaningfully risking its small weekly pool. `grok-4.6` is the first non-OpenAI contingency for `slow`/`plan`, followed by NVIDIA; it cannot drain the pool through routine use.
- Every fallback chain uses a *different provider* than its primary, so a single provider outage/quota exhaustion doesn't take out both tiers at once.
- Deliberately **not** using `claude-fable-5`/`claude-mythos-5` (Anthropic's largest models) anywhere — on the Pro plan those bill through separate credits, i.e. the "buy more" trap.
- `vision`/`designer` upgraded to `gemini-3.7-flash` (GA Aug 13 2026, newest stable Flash tier); `gemini-3.6-flash` is still live but one generation behind.
- `retry.usageAwareFallback: true` + `retry.usageReservePolicy: "auto"` — when the Anthropic 5-hour window is nearly exhausted, OMP proactively switches to the `default` fallback chain without waiting for a 429 and without prompting. Prevents the session from stopping cold on token exhaustion.
- `smol`/`task` fallback chains upgraded from `gemini-3.1-flash-lite` to `gemini-3.5-flash-lite` — 3.5-Lite is specifically optimized for agentic sub-agent workflows (vs 3.1-Lite which targets bulk/classification workloads). Cost difference is nominal at API rates and irrelevant here since `google-antigravity` is a free proxy.
- `tiny` remains unset: OMP delegates its low-impact background work to `@smol` (Luna). No separate tiny-model allocation is justified by the current workload or catalog evidence.

If the target machine's subscriptions differ from the table above, don't paste this file blind —
re-derive the allocation from whatever pools that machine actually has (`omp usage` after logging in).

## Prerequisite: auth

The mapping references five providers: `anthropic`, `openai-codex`, `google-antigravity`,
`xai-oauth`, `nvidia`. Any role whose provider isn't authenticated on the target machine will
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
3. Restart any running `omp` session.

Equivalent one-liners (no manual paste):
```bash
omp config set modelRoles '{"default":"anthropic/claude-sonnet-5","smol":"openai-codex/gpt-5.6-luna","slow":"openai-codex/gpt-5.6-sol","vision":"google-antigravity/gemini-3.7-flash","plan":"openai-codex/gpt-5.6-sol","commit":"xai-oauth/grok-build","designer":"google-antigravity/gemini-3.7-flash","task":"openai-codex/gpt-5.6-terra","advisor":"google-antigravity/claude-sonnet-4-6"}'

omp config set retry.fallbackChains '{"default":["google-antigravity/gemini-3.7-flash","openai-codex/gpt-5.6-terra","xai-oauth/grok-4.6","nvidia/deepseek-ai/deepseek-v4-pro"],"smol":["google-antigravity/gemini-3.5-flash-lite","nvidia/deepseek-ai/deepseek-v4-flash"],"slow":["xai-oauth/grok-4.6","nvidia/deepseek-ai/deepseek-v4-pro"],"vision":["openai-codex/gpt-5.6-terra","xai-oauth/grok-4.6"],"plan":["xai-oauth/grok-4.6","nvidia/deepseek-ai/deepseek-v4-pro"],"commit":["openai-codex/gpt-5.6-luna"],"designer":["openai-codex/gpt-5.6-terra","xai-oauth/grok-4.6"],"task":["google-antigravity/gemini-3.5-flash-lite","nvidia/deepseek-ai/deepseek-v4-flash"],"advisor":["openai-codex/gpt-5.6-terra"]}'

omp config set retry.usageAwareFallback true
omp config set retry.usageReservePolicy '"auto"'
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
omp config get retry.fallbackChains --json
omp config get retry.usageAwareFallback --json
omp config get retry.usageReservePolicy --json
omp usage   # confirm which pools are actually getting hit
```
Then `/model` inside a session to confirm each role resolves to an available (authenticated)
model rather than silently falling back.
