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

   **Planning-only exemption:** researching alternative subscriptions or generating
   an opt-in overlay without applying it is not a new live snapshot. Do not bump the
   root snapshot, rewrite current-setup claims, change existing auth, or run the
   apply/commit/push workflow for that work. See [SUBSCRIPTION-MIXES.md](SUBSCRIPTION-MIXES.md)
   for sourced four-provider SKUs and an isolated API-auth alternative. For selection
   behavior, follow [../instructions/SELECT-MODEL-MIX.md](../instructions/SELECT-MODEL-MIX.md)
   as the single instruction contract. Ask OMP for a preview with exact plans,
   workload, and budget; no root/config/auth changes or Fable requests. Offline
   reading sends no request, while asking OMP may consume its existing model allowance.

## One-shot preview request (paste into a fresh OMP session)

```text
Read instructions/SELECT-MODEL-MIX.md from this local clone and follow it.
Preview a full allocation, including the complete proposed overlay, without changing
files, config, agents, auth, subscriptions, or billing. My exact plans are:
[provider, product, tier, trial status, price, and authorized OMP/API route for each].
My workload is: [implementation/planning/architecture/research/vision volume and
concurrent machines]. My budget is: [subscription ceiling, separately funded API
budget, included-credit status, and no-spend/top-up constraints]. Inspect current
state, usage, and catalog read-only if available; ask only for material missing
information. Show all 17 roles, ordered fallbacks, agent bindings, rationale,
provenance/independence limits, and entitlement/budget caveats. If these are future
plans, complete the conditional preview and list unmet access/funding prerequisites
instead of silently reverting to today's setup. Compare Fable 5.1 with Opus 5.5
separately for plan and architect using web research only; do not send Fable or
additional selected-model probes/trial requests or claim unobserved performance/access.
```

Replace the bracketed descriptions with your facts; this is an ordinary request,
not a new command language. Preview is the default, and the existing optional
profile is not installed by asking. Using OMP can consume the currently selected
model's allowance. Applying an allocation is a separate, explicitly authorized
operation; the import/update steps below are not permission to apply a preview.

For the four-provider preview, the
[2026-10-08 web evaluation](FABLE-EVALUATION.md) retains **Opus 5.5 provisionally
for both plan and architect in the Anthropic-heavy alternative**. Fable 5.1 remains
a credible conditional choice: independent rubric/correctness counterevidence
prevents a universal Opus-winner claim, and no controlled direct OMP plan/read-only
architect head-to-head was found in the reviewed sources. Follow instruction step 5
for separate role criteria, effort tuning, and reversal/access/budget conditions.
Historical local Fable timing/depletion metrics are withdrawn because the requests
fell back to OpenAI; do not reuse them or demand unavailable Fable tests now.
This decision changes neither the live v32 setup nor the static alternative profile.

## Methodology

1. **Read current state first.**
   - `omp config get modelRoles --json` / `omp config get retry.fallbackChains --json` — what's live now.
   - `omp usage` — which providers are actually authenticated, and real quota pressure (5h/7d/weekly/daily windows, % used). This is ground truth; the model catalog (`omp models`) just shows what's technically reachable, not what's affordable.
   - `omp models <provider>` for each authenticated provider — current model lineup, since names/tiers shift release to release (e.g. a vendor's "flagship/balanced/fast" naming ladder).

2. **Resolve the subscription checklist below.** Use facts supplied in the request
   and read-only state; ask only for material missing information. Don't assume the
   mix from last time still holds.

3. **Classify roles by volume and cost-per-call, not by "which is best":**
   - `default` — highest volume, fires every turn. Needs the model best suited to the *actual* workload mix (see below), on a pool that can sustain constant use.
   - `task`/`smol` — high volume (subagent dispatch, background classification). Route to whichever pool has real headroom. `smol` also executes implementation after an opted-in prewalk, so do not evaluate it only on trivial/background work.
   - `slow`/`plan` — measure actual use, not assumed low frequency. `slow` may drive a whole difficult task or the opening of a prewalk; `/plan` remains useful when approval before implementation is required.
   - `architect` — the owner uses it frequently for technical reviews, not only rare RFCs. In v29 it shares Sol with `slow`/`review`/workers; different role names are not independent model evidence. Use a distinct model deliberately when that matters.
   - `commit`, and any other rarely-invoked role — the safe place to actually exercise a login you're barely using (e.g. a cheap/bundled AI subscription with small credits), since low frequency ≈ low risk to a small pool.
   - `advisor` — if enabled, roughly **doubles** whatever pool it shares with `default` (it reviews every turn). Prefer a free/separate pool for it so enabling it later doesn't create new pressure on your scarcest account.
   - `vision`/`designer` — occasional, multimodal. Free/generous pools are usually fine here.

4. **Match model *character* to workload, not just benchmark score.** If any of the workload is non-coding (writing for humans, research synthesis, business/creative output), check whether a provider's coding-branded product/API (e.g. an OpenAI "Codex"-specific endpoint, an agentic dev-tool mode) is known to skew toward technical/terse output outside of software tasks — that's a real, sourced effect, not just benchmark noise. Keep `default` (and anything that produces reader-facing prose) on whichever model is credibly rated for natural, plain-language writing.

5. **Prefer free/bundled multi-model proxies as pressure release, not as your primary daily driver** — they're usually one point-version behind flagship and can have volatile preview-tier quotas. Good for: `advisor`, fallback tiers, low-stakes roles. Risky as: the *primary* `default` model.

6. **Every fallback chain entry should be a different provider than its primary** (and ideally different from the other fallback tiers too) — the point of a fallback chain is surviving one provider's outage/quota exhaustion, which a same-provider fallback doesn't protect against.

7. **Remember quota is usually account-level, not per-machine.** If this config runs on N machines concurrently, model load on any shared-login pool as N×, not 1×.

   Account for repeated reading, cached input, output, and thinking over the whole
   task rather than multiplying nominal per-call prices. Catalog API prices are
   not subscription-quota conversion factors. Avoid planner → executor handoffs
   solely as an assumed cost optimization; trial same-session prewalk instead.
   Keep independent subagents/reviews where isolation earns their context cost.

   After reviewing both machines' session histories, the owner chose one shared
   v29 configuration with `extendedContext: true`. Import it on every machine;
   do not retain the superseded Mac-off trial or machine-local split. See README's
   measured context distribution and limitations. Compare quota over a full reset
   cycle, compaction frequency, lost constraints, and rework. A higher ceiling is
   not pre-allocation; a lower ceiling can increase compaction and re-reading.

8. **Only after explicit authorization to update the live setup: apply, verify, ship.**
   ```bash
   omp config set modelRoles '{...}'
   omp config set retry.fallbackChains '{...}'
   omp config get modelRoles --json   # verify
   omp config get retry.fallbackChains --json   # verify
   ```
   Update `model-roles.yml` and `README.md` in this repo to match exactly what's live, commit, push.

## Subscription checklist (ask only for material missing facts)

- **Per provider you have a login for**: exact plan/tier and price? (e.g. Anthropic Free / Pro $20 / Max 5x $100 / Max 20x $200 / Team; OpenAI Free / Plus $20 / Pro $100 / Pro $200 / Team; Google — which product and tier, storage-plan vs AI-specific subscription vs a free preview program; xAI — bundled-with-social-app tier vs standalone SuperGrok Lite/Standard/Heavy; any others: Groq, Mistral, DeepSeek, Perplexity, OpenRouter credits, local models via Ollama/LM Studio/llama.cpp?)
- **Anything added or dropped** since the last pass?
- **Has the workload mix changed?** More/less pure coding vs. research-and-writing vs. design/vision work? New repos with different characteristics (e.g. much heavier subagent/parallel-task usage, or a lot more image/design review)?
- **Any role currently causing pain** — hitting rate limits, feels slow, tone/output quality feels off for what it's used for?
- **Budget constraint still "no new spend,"** or open to upgrading one specific tier now?
- **Any provider to avoid or deprioritize** (privacy, cost-control, reliability complaints)?
- **Multiple machines active concurrently**, or mostly one-at-a-time? (Changes how aggressively to treat shared quota as scarce.)

## Files in this repo

The importable overlays and README are at the root. Selection instructions live in
`instructions/`; source research and rationale live in `research/` (this folder).

Root — the importable config:
- `../model-roles.yml` — model roles, agent bindings, retry policies/chains, cycle order, and owner-approved `extendedContext: true`. Merge all supplied keys into `config.yml`; `omp --config ./model-roles.yml` applies a run-only overlay, not a persistent install.
- `../models-overlay.yml` — companion `models.yml` overlay (per-model overrides like `maxTokens`).
  Currently just the OpenRouter Gemini 3.8 Flash `maxTokens` fix that `vision`'s fallback chain
  depends on — check whether any newly-added fallback model needs one of these before assuming
  `model-roles.yml` alone is a complete import.
- `../README.md` — import instructions, the repo-layout map, plus the rationale/subscription table
  that justified the current values, including the locally measured 2026-08-25 A/B.

Optional planning instructions/profile — not the current imported setup:
- `../instructions/SELECT-MODEL-MIX.md` — the single behavior contract for OMP to
  preview a subscription/workload/budget-aware allocation; not a standalone program.
- `../profiles/anthropic-heavy.yml` — opt-in static alternative, not auto-installed.
  A run-only overlay is not authentication isolation: follow the notes' API-credit,
  isolated-profile, provider-permission, and Console spending prerequisites before any run.

`research/` — methodology and point-in-time investigations:
- `RESEARCH-PLAYBOOK.md` — this file.
- `SUBSCRIPTION-MIXES.md` — 2026-10-08 major OpenAI/Anthropic/Google/SpaceX-xAI-X SKUs,
  sourced prices and missing-price caveats, recommended paying-tier mixes, instruction
  usage, full Anthropic-heavy role map, and safe API-auth/budget prerequisites.
- `GEMINI-QUOTA-OPTIONS.md` — point-in-time investigation into Gemini/Antigravity quota burnout
  options; superseded in part by the `vision`/`designer` decisions in this snapshot — see its own
  addendum before treating its recommendation as current.
- `META-MUSE-EVALUATION.md` — point-in-time evaluation of the `meta` provider (Muse Spark 1.2 /
  1.2-contributor), 2026-08-25. Research-only, no local benchmark. Conclusion: not adopted in any
  role; the Contributor tier's discount is paid for with permission to train on submitted prompts
  and completions, and a plain API key is excluded from `usageAwareFallback`. Read it before
  re-litigating "should we add the cheap Meta model somewhere".
- `ARCHITECT-CRITICAL-AGENTS.md` — original dispatch investigation, with a v29 addendum for the review-oriented architect and its verification.
- `FABLE-EVALUATION.md` — 2026-10-08 web-only Fable 5.1 versus Opus 5.5 comparison for plan and architect: official/independent evidence, correctness counterevidence, effort/cost/latency limits, provisional Opus defaults, and conditional Fable reversal/access criteria. Historical local Fable speed/depletion claims are withdrawn after OpenAI fallback invalidated their model identity.
- `THINKING-PARTNER-ROLE.md` — 2026-09-04 · v19: architecture, multi-agent debate (Architect vs Slow), and allocation for the `sage` Thinking Partner role, defusing the Anthropic 429 credits_required failure mode on Fable.
- `SAGE-CREATIVE-INSTRUCTIONS.md` — 2026-09-04 · v19.1: cognitive divergence operators, anti-slop defect catalogs, and subtractive taste architecture for `sage` (Thinking Partner), adapted from Anshu Chimala's Apple R&D AI creativity methodology.

Adding a new investigation? Put it in `research/`, register it in this list, and link it from
`../README.md`'s rationale section so it is discoverable from the entry point.
