# Re-running the model-role allocation

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root,
one level up; the file map at the bottom gives explicit paths.*

This repo holds a **snapshot**, not a fixed answer. Subscriptions change, model lineups
change, workload mix changes — re-derive the allocation instead of copying `model-roles.yml`
blind once any of those have moved.

## Staleness check (do this first, before importing or updating anything)

`model-roles.yml` and `README.md` each carry a `Generated: YYYY-MM-DD · Snapshot version: N`
line. Before importing this config on a machine, or before treating it as current:

1. Compare that date to today. **Older than ~4-6 weeks → treat as stale.**
2. Regardless of date, treat it as stale **immediately** if: any subscription/plan changed,
   a provider was added or dropped, or the model catalog (`omp models`) looks meaningfully
   different from what's referenced in `model-roles.yml`.
3. If stale by either rule: **don't import as-is.** Tell me it looks stale and ask the
   subscription checklist below before applying anything. If it's still current, say so and
   proceed.
4. Whenever you do re-derive and update the files, bump `Snapshot version` by 1 and set
   `Generated` to today's date, in both `model-roles.yml` and `README.md`.

## One-shot prompt (paste into a fresh OMP session on any machine)

```
Read research/RESEARCH-PLAYBOOK.md from https://github.com/vokativ/omp-model-roles (or the
local clone). Follow its methodology: inspect my current OMP model-role config and `omp usage`,
ask me the subscription checklist questions in that file, research current model/plan
capacity online, then propose and apply an updated quota-aware modelRoles +
retry.fallbackChains allocation. Update model-roles.yml and README.md in that repo to
match what you applied, and commit + push.
```

## Methodology

1. **Read current state first.**
   - `omp config get modelRoles --json` / `omp config get retry.fallbackChains --json` — what's live now.
   - `omp usage` — which providers are actually authenticated, and real quota pressure (5h/7d/weekly/daily windows, % used). This is ground truth; the model catalog (`omp models`) just shows what's technically reachable, not what's affordable.
   - `omp models <provider>` for each authenticated provider — current model lineup, since names/tiers shift release to release (e.g. a vendor's "flagship/balanced/fast" naming ladder).

2. **Ask me the subscription checklist below.** Don't assume the mix from last time still holds.

3. **Classify roles by volume and cost-per-call, not by "which is best":**
   - `default` — highest volume, fires every turn. Needs the model best suited to the *actual* workload mix (see below), on a pool that can sustain constant use.
   - `task`/`smol` — high volume (subagent dispatch, background classification). Route to whichever pool has real headroom; quality matters more for `task` (does real work) than `smol` (trivial/background).
   - `slow`/`plan` — low frequency, expensive per call (deep/max-thinking bursts). Fine to point at a pool with headroom even if it's not your "primary" account, since infrequent big spikes are exactly what headroom is for.
   - `commit`, and any other rarely-invoked role — the safe place to actually exercise a login you're barely using (e.g. a cheap/bundled AI subscription with small credits), since low frequency ≈ low risk to a small pool.
   - `advisor` — if enabled, roughly **doubles** whatever pool it shares with `default` (it reviews every turn). Prefer a free/separate pool for it so enabling it later doesn't create new pressure on your scarcest account.
   - `vision`/`designer` — occasional, multimodal. Free/generous pools are usually fine here.

4. **Match model *character* to workload, not just benchmark score.** If any of the workload is non-coding (writing for humans, research synthesis, business/creative output), check whether a provider's coding-branded product/API (e.g. an OpenAI "Codex"-specific endpoint, an agentic dev-tool mode) is known to skew toward technical/terse output outside of software tasks — that's a real, sourced effect, not just benchmark noise. Keep `default` (and anything that produces reader-facing prose) on whichever model is credibly rated for natural, plain-language writing.

5. **Prefer free/bundled multi-model proxies as pressure release, not as your primary daily driver** — they're usually one point-version behind flagship and can have volatile preview-tier quotas. Good for: `advisor`, fallback tiers, low-stakes roles. Risky as: the *primary* `default` model.

6. **Every fallback chain entry should be a different provider than its primary** (and ideally different from the other fallback tiers too) — the point of a fallback chain is surviving one provider's outage/quota exhaustion, which a same-provider fallback doesn't protect against.

7. **Remember quota is usually account-level, not per-machine.** If this config runs on N machines concurrently, model load on any shared-login pool as N×, not 1×.

8. **Apply, verify, ship:**
   ```bash
   omp config set modelRoles '{...}'
   omp config set retry.fallbackChains '{...}'
   omp config get modelRoles --json   # verify
   omp config get retry.fallbackChains --json   # verify
   ```
   Update `model-roles.yml` and `README.md` in this repo to match exactly what's live, commit, push.

## Subscription checklist (ask me these — don't assume)

- **Per provider you have a login for**: exact plan/tier and price? (e.g. Anthropic Free / Pro $20 / Max 5x $100 / Max 20x $200 / Team; OpenAI Free / Plus $20 / Pro $100 / Pro $200 / Team; Google — which product and tier, storage-plan vs AI-specific subscription vs a free preview program; xAI — bundled-with-social-app tier vs standalone SuperGrok Lite/Standard/Heavy; any others: Groq, Mistral, DeepSeek, Perplexity, OpenRouter credits, local models via Ollama/LM Studio/llama.cpp?)
- **Anything added or dropped** since the last pass?
- **Has the workload mix changed?** More/less pure coding vs. research-and-writing vs. design/vision work? New repos with different characteristics (e.g. much heavier subagent/parallel-task usage, or a lot more image/design review)?
- **Any role currently causing pain** — hitting rate limits, feels slow, tone/output quality feels off for what it's used for?
- **Budget constraint still "no new spend,"** or open to upgrading one specific tier now?
- **Any provider to avoid or deprioritize** (privacy, cost-control, reliability complaints)?
- **Multiple machines active concurrently**, or mostly one-at-a-time? (Changes how aggressively to treat shared quota as scarce.)

## Files in this repo

Repo root holds only the importable config plus the README; everything explaining *why* lives
in `research/` (this folder).

Root — the importable config:
- `../model-roles.yml` — the current applied `modelRoles` + `retry.fallbackChains` overlay (importable via `PI_CONFIG_FILES` or manual merge into `config.yml`).
- `../models-overlay.yml` — companion `models.yml` overlay (per-model overrides like `maxTokens`).
  Currently just the OpenRouter Gemini 3.8 Flash `maxTokens` fix that `vision`'s fallback chain
  depends on — check whether any newly-added fallback model needs one of these before assuming
  `model-roles.yml` alone is a complete import.
- `../README.md` — import instructions, the repo-layout map, plus the rationale/subscription table
  that justified the current values, including the locally measured 2026-08-25 A/B.

`research/` — methodology and point-in-time investigations:
- `RESEARCH-PLAYBOOK.md` — this file.
- `GEMINI-QUOTA-OPTIONS.md` — point-in-time investigation into Gemini/Antigravity quota burnout
  options; superseded in part by the `vision`/`designer` decisions in this snapshot — see its own
  addendum before treating its recommendation as current.
- `META-MUSE-EVALUATION.md` — point-in-time evaluation of the `meta` provider (Muse Spark 1.2 /
  1.2-contributor), 2026-08-25. Research-only, no local benchmark. Conclusion: not adopted in any
  role; the Contributor tier's discount is paid for with permission to train on submitted prompts
  and completions, and a plain API key is excluded from `usageAwareFallback`. Read it before
  re-litigating "should we add the cheap Meta model somewhere".
- `ARCHITECT-CRITICAL-AGENTS.md` — 2026-08-26: wiring architect/critical into real subagent dispatch.
- `FABLE-EVALUATION.md` — 2026-09-03: evaluation of Claude Fable 5 / 5.1 for architect and critical roles, token economics on $20/mo Anthropic Pro, Google Antigravity Claude 4.6 fallbacks, and multi-agent debate (Architect vs Slow).
- `THINKING-PARTNER-ROLE.md` — 2026-09-04 · v19: architecture, multi-agent debate (Architect vs Slow), and allocation for the `sage` Thinking Partner role, defusing the Anthropic 429 credits_required failure mode on Fable.
- `SAGE-CREATIVE-INSTRUCTIONS.md` — 2026-09-04 · v19.1: cognitive divergence operators, anti-slop defect catalogs, and subtractive taste architecture for `sage` (Thinking Partner), adapted from Anshu Chimala's Apple R&D AI creativity methodology.

Adding a new investigation? Put it in `research/`, register it in this list, and link it from
`../README.md`'s rationale section so it is discoverable from the entry point.
