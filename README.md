# OMP model-role setup — import instructions

**Snapshot: 2026-08-14 · v1.** Stale after ~4-6 weeks, or immediately if any subscription
changed — check `RESEARCH-PLAYBOOK.md`'s staleness check before importing this blind.

`model-roles.yml` is a config **overlay**: only `modelRoles` and `retry.fallbackChains`.
No API keys. Safe to copy anywhere, commit to a repo, or paste into an existing config.

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
- `slow`/`plan` (max-thinking, expensive-per-call) moved off Anthropic onto `openai-codex/gpt-5.6-sol` — the flagship Codex tier, sitting on the pool with headroom. Opus 5 is still available as the fallback, just not the thing burning the 5-hour window on every planning call.
- `advisor` (would double per-turn cost the moment it's enabled) points at `google-antigravity/claude-sonnet-4-6` — free Claude access, so turning advisor on doesn't touch the paid Anthropic pool at all.
- `default`'s fallback chain is ordered `google-antigravity/claude-sonnet-4-6` *before* `openai-codex/gpt-5.6-terra` — deliberately, not just cheapest-first. Coding-branded endpoints (OpenAI's Codex-specific API, which `openai-codex` hits) are documented to skew technical/terse outside of software tasks; when overflow happens on a role that also carries non-coding writing, land on the still-Claude free lane first, not the coding-tuned one.
- `commit` (once per commit — genuinely low frequency) is the one place `xai-oauth/grok-build` is used as primary, so the X login gets real use without meaningfully risking its small weekly pool. `grok-4.6` also appears as the last-resort tail of the `slow`/`plan` fallback chains for the same reason — rarely triggered, so it can't drain the pool through routine use.
- Every fallback chain uses a *different provider* than its primary, so a single provider outage/quota exhaustion doesn't take out both tiers at once.
- Deliberately **not** using `claude-fable-5`/`claude-mythos-5` (Anthropic's largest models) anywhere — on the Pro plan those bill through separate credits, i.e. the "buy more" trap.

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
2. Copy in the `modelRoles:` and `retry:` blocks from `model-roles.yml`.
   - If `modelRoles` or `retry.fallbackChains` already exist there, replace them
     wholesale (these are YAML *records*, not appended — the whole map wins).
   - Leave every other key in that file untouched.
3. Restart any running `omp` session.

Equivalent one-liners (no manual paste):
```bash
omp config set modelRoles '{"default":"anthropic/claude-sonnet-5","smol":"openai-codex/gpt-5.6-luna","slow":"openai-codex/gpt-5.6-sol","vision":"google-antigravity/gemini-3.6-flash","plan":"openai-codex/gpt-5.6-sol","commit":"xai-oauth/grok-build","designer":"google-antigravity/gemini-3.6-flash","task":"openai-codex/gpt-5.6-terra","advisor":"google-antigravity/claude-sonnet-4-6"}'

omp config set retry.fallbackChains '{"default":["google-antigravity/claude-sonnet-4-6","openai-codex/gpt-5.6-terra"],"smol":["google-antigravity/gemini-3.1-flash-lite","nvidia/deepseek-ai/deepseek-v4-flash"],"slow":["anthropic/claude-opus-5","xai-oauth/grok-4.6"],"plan":["anthropic/claude-opus-5","xai-oauth/grok-4.6"],"commit":["openai-codex/gpt-5.6-luna"],"designer":["anthropic/claude-sonnet-5"],"task":["google-antigravity/gemini-3.1-flash-lite","nvidia/deepseek-ai/deepseek-v4-flash"],"advisor":["openai-codex/gpt-5.6-terra"]}'
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
Or load it ad hoc for one run: `omp --config ~/path/to/model-roles.yml`.
This file is always read fresh — editing it on the source machine and re-syncing the
dotfiles repo propagates to every machine without any `omp config set`.

## Verify
```bash
omp config get modelRoles --json
omp config get retry.fallbackChains --json
omp usage   # confirm which pools are actually getting hit
```
Then `/model` inside a session to confirm each role resolves to an available (authenticated)
model rather than silently falling back.
