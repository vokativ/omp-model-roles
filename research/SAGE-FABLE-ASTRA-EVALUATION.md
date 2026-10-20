# `sage`: Fable 5.1 vs Opus 5.5, and Astra — evaluation 2026-10-20

**Probes, usage readings and the blind A/B ran on 2026-10-20 (snapshot v35).** Raw artifacts were kept under `/tmp/probe/` (not committed); every figure below comes from them or from the cited public pages. Config effects are in [`model-roles.yml`](../model-roles.yml) (v35 header). Opus-vs-Fable public proxies for `plan`/`architect` live in [`FABLE-EVALUATION.md`](./FABLE-EVALUATION.md); this note supersedes that file's "no Fable access" statement only for access, not for its benchmark review.

## 1. Decision

- **Astra (`openai-codex/gpt-6-astra`): no role, no fallback chain.** (It was never in the live `model-roles.yml`; older README prose placing it in sage's chain was wrong.) Use it only as an explicit one-off, `--model openai-codex/gpt-6-astra`, when stuck and Plus has headroom.
- **`sage` primary: `anthropic/claude-fable-5-1`. Provisional and reversible.** Quality of Fable vs Opus 5.5 is **UNRESOLVED** by the A/B below. Chosen on low volume (~2 dispatches/week), best published pushback evidence (AA-PersonalityBench), and decorrelation from the Opus-based `plan`/`architect`/`slow` roles. Revert = set `modelRoles.sage` back to `anthropic/claude-opus-5-5`.
- **Failover chain for sage-on-Fable** (model-level key `anthropic/claude-fable-5-1`, mirrored on `claude-fable-5`): `anthropic/claude-opus-5-5` → `google-antigravity/claude-opus-5-5` → `openai-codex/gpt-6.1-sol` → `google-antigravity/gemini-4-argon` → `xai-oauth/grok-4.7`.
  - Direct Opus first: Fable cap exhaustion or Fable safeguard/refusal failures should land on the same-family model.
  - Antigravity Opus before Sol: it is an idle pool (2.3% used) and keeps sage off the Plus 5h window that `critical` swarms exhaust.
  - Argon late: its weekly meter is 100% used until ~2026-10-24, so a first hop there is wasted this week.
- **Why the chain is model-level.** OMP checks exact `provider/model-id` chain keys before role keys (`omp://settings.md` ~579, 587). With sage on Fable, a role-level `sage` chain would be shadowed. The role-level `sage` chain (`google-antigravity/claude-opus-5-5` → Sol 6.1 → Argon → Grok 4.7) applies **only if sage reverts to Opus**.

## 2. Capacity evidence (2026-10-20)

| Pool | Reading | Implication |
| --- | --- | --- |
| ChatGPT Plus (5h/7d chat meter, plan `plus`) | 5h window hit 100% five times 2026-10-17..10-19; 26 `usage_limit_reached` errors on Sol (10-17: 6, 10-18: 17, 10-19: 3); `critical` = 135 of ~182 task dispatches (74%) over 10-06..10-20, mostly PR-review swarms | **Binding burst pool.** Anything that spends Plus (Astra, Sol early in a chain) competes with `critical`. |
| Anthropic Max 5x | 7d 41% used, resets 2026-10-23 16:00Z; Fable 7d meter 13% (a sub-cap inside the shared weekly pool, up to 50% of the weekly limit; no published multiplier) | Fable meter so far moved only by Claude Code usage (522 `claude-fable-5-1` messages), not OMP. |
| Google Antigravity "Claude & GPT (shared)" | weekly 2.3% used | Idle; one shared pool for Antigravity Claude and Antigravity GPT. |
| Google Gemini 4 Argon | weekly meter 100% used until ~2026-10-24 | First-fallback hops to Argon are wasted this week. |

sage volume: 4 sessions in 14 days (~2 completed dispatches/week), all on Opus 5.5, **$4.50 API-equivalent total (~$1.12/dispatch)**. Fable estimate: ~2.4x cost (batch $0.250 vs $0.103 per answer) and ~1.6x latency (74.7s vs 46.1s) ⇒ **~$2.6/dispatch, roughly +1.6 weekly-pool points vs Opus at 2 dispatches/week**. These are **estimates**; the "$185 ≈ 100% weekly" calibration behind the pool-point figure is rough.

## 3. Astra evidence

- **Plus rate card** (OpenAI Help Center / pricing): local messages per 5h on Plus — Astra 5–45, Sol 6.1 15–160, Sol 6 15–150, Luna 350–3000. Credits per M tokens in/cached/out: Astra 250/25/1250, Sol 6.1 50/2.5/250, Luna 2.5/0.25/12.5. API list $/M in/out: Astra $10/$50, Sol 6.1 $2/$10, Luna $0.10/$0.50. Plus "includes limited GPT-6 Astra usage" (Help Center and Codex pricing); the learn.chatgpt.com Plus card lists only Sol and Luna (inconsistent). Ultrafast (8x burn) is Pro $500/Enterprise only; Fast mode burns 2.5x on Plus.
- **Shared meter.** `omp usage` shows one 5h + one 7d chat meter (plan `plus`); no Astra-specific meter. Astra as a fallback for Sol therefore adds **no pool diversification** when Sol hits `usage_limit_reached`.
- **Coarse burn probe:** 13.8K Astra tokens = +1 meter point = the same as 40.8K Sol tokens. The meter is whole-percent, so this is a hypothesis of ~3–5x burn, **not a measured ratio**.
- **Independent proxies.** Artificial Analysis (max effort): Intelligence Index Astra 53 vs Sol 6.1 52; cost/task $3.26 vs $0.72; Coding Agent Index within 1–2 points. Arena creative writing: Opus 5.5 #1 (1519), Fable 5.1 #9 (1485), Sol 6.1 #30 (1458), Astra #38 (1450). AA-PersonalityBench: Astra 352 words/response vs Opus 571, Fable 576.
- **Access probe:** `gpt-6-astra` accepted on ChatGPT Plus through OMP; delivered id verified from the event stream (`provider: openai-codex`, `model: gpt-6-astra`).

## 4. Fable evidence and access boundary

- **Access (2026-10-20):** `omp -p --no-session --no-tools --mode json --model anthropic/claude-fable-5-1` was accepted via Max 5x OAuth; delivered id `anthropic/claude-fable-5-1` verified; no `credits_required` (unlike the 2026-09-04 Claude Pro 429). This overturns `FABLE-EVALUATION.md`'s "no Fable access" for this account.
- **Pushback evidence:** AA-PersonalityBench ranks Fable #1 of 36 on "constructively pushes back"; Fable 576 words/response vs Astra 352.
- **Operational caveats:**
  - Fable reasoning blocks are readable only by Fable/Mythos. A mid-session Fable → Opus failover drops that reasoning, and OMP may skip same-provider fallback when signed thinking history exists. Fresh dispatches are unaffected (sage is usually a fresh dispatch).
  - Fable always thinks.
  - Anthropic safeguard classifiers can substitute Opus 4.8/Opus 5 server-side (`providers.anthropic.serverSideFallback` defaults to false in OMP), so delivered-id checks matter.
  - **Policy risk:** OMP presents as Claude Code over Max OAuth (can1357/oh-my-pi issue 12487); Anthropic's 2026-04 third-party-harness restrictions; the 2026-10-07 update says subscription limits remain usable with third-party apps. Max's $100 monthly API credits cover API-key use, not OAuth/interactive use.

## 5. Blind A/B

**Design.** 3 sage-style prompts × 4 models = 12 answers, one answer per model per prompt. System prompt = the body of [`agents/sage.md`](../agents/sage.md); `--thinking high`; `--no-tools --no-extensions --no-skills --no-rules --no-lsp`; delivered ids verified from events (all 12 matched). Models: Fable 5.1, Opus 5.5, Astra, Sol 6.1. Answers were relabelled A–D with a different shuffle per judge folder (`j1`–`j3`) and judged on a six-item rubric, 1–10 each: R1 Insight, R2 Position, R3 Grounding, R4 Objection, R5 Correctness, R6 Density (length not rewarded). Judges: Sonnet 5.5 ×3 (one per folder), Grok 4.7, Sol 6.1 (each over the same three folders).

- **P1** — meta question: the 17-role config overlay across four subscriptions (Claude Max 5x with a separate Fable sub-meter, ChatGPT Plus incl. limited Astra at ~3x Sol burn, Google AI Pro, X Premium), with the current sage on Opus 5.5 and fallbacks Sol → Argon → AG Opus → Grok 4.7; "should sage move?"
- **P2** — a solo developer's 600-line dotfile-sync bash tool occasionally corrupts files on concurrent syncs; the plan is a weekend Rust rewrite with a sync engine. Challenge the plan.
- **P3** — a 12-person team with 3-day median PR review latency, leadership wants an AI code-review tool, the tech lead suspects the wrong problem. Help them think.

**Mean rubric score (1–10) per judge, mean over 3 prompts × 3 folders = 9 cells per model** (Grok and Sol values recomputed from `xjudge.json` + `key.json`; Sonnet figures are taken from the run summary, not recomputed — no Sonnet score file was among the artifacts reviewed):

| Judge | Fable 5.1 | Opus 5.5 | Astra | Sol 6.1 | Mean rank (best first) |
| --- | ---: | ---: | ---: | ---: | --- |
| Sonnet 5.5 ×3 (Claude family) | **8.19** | 7.98 | 6.61 | 6.30 | Fable 1.33, Opus 1.67, Astra 3.33, Sol 3.67 |
| Grok 4.7 (neutral, xAI) | **8.43** | 8.13 | 7.85 | 7.74 | Fable 1.33, Opus 2.11, Astra 3.11, Sol 3.44 |
| Sol 6.1 (OpenAI family) | 6.35 | 6.28 | **8.83** | 8.70 | Astra 1.33, Sol 1.67, Opus 3.44, Fable 3.56 |

Excluding P1: Sonnet Fable 8.14 vs Opus 8.19 (the gap vanishes); Grok Fable 8.53, Opus 8.22, Astra 7.86, Sol 7.83; Sol judge Astra 8.92, Sol 8.89, Fable 6.42, Opus 6.33 (recomputed).

**Reading.** Each family's judges favored their own family; the neutral Grok judge ordered Fable > Opus > Astra > Sol, but the Fable–Opus gap (0.30) is small against that bias. **Fable vs Opus quality: unresolved. Claude vs OpenAI ordering: judge-dependent.** Public evidence that is independent of this A/B (Arena creative, AA-PersonalityBench) favors Claude for prose/ideation.

**Cost, latency, length (API-equivalent, from `manifest.md`).** Mean per answer: Fable $0.250, Opus $0.103; wall 74.7s vs 46.1s. Words: Opus ~1067, Fable ~908, Astra ~723, Sol ~673 (spec default is <900). Meter movement over the generation batch: Plus 5h 4%→7%, Plus 7d 1%→1%; Anthropic 7d ~41%→43%, Fable 7d 13%→13%.

**Methodological caveats (all apply):**

1. **Judge-family self-preference dominates.** Sonnet judges favored Claude answers, the Sol judge favored OpenAI answers. Judges identified Claude vs GPT family in 36/36 cases per the draft review notes (`proposal.md`), so family-level blinding failed.
2. **P1 identity leak.** P1 answers leaked first-person model identity ("I am running as Fable"; "running on Opus 5.5 per the workstation header"), so P1 is identity-contaminated. No self-identifying lines were found to strip from P2/P3; P1 mentions model names partly because the prompt does.
3. **n = 3 prompts**, not 9; the nine judge cells per judge share three underlying answers per model. One answer per model per prompt; no repeats.
4. **Extra MCP input tokens:** MCP tool schemas were still present on Anthropic runs (~4.2K extra input tokens: ~8.5–8.8K vs ~4.4–4.6K input), a prompt-length confound between the families.
5. **Length spread:** Opus answers run ~58% longer than Sol's despite the rubric's "do not reward length"; judges may still reward length.
6. **The "nofallback" overlay did not disable fallback by itself.** `/tmp/probe/nofallback.yml` set `retry: {fallbackChains: {}, usageAwareFallback: false}`; only `retry.modelFallback: false` stops chains from switching models. The runs are valid because the **delivered id was verified for every answer**, not because of the overlay.
7. **Cost is API-equivalent $ computed by omp, not subscription burn.**
8. Whole-percent meters limit every meter-based inference (e.g. the 13.8K vs 40.8K token burn probe).

## 6. Adversarial review summary

The draft recommendation (`proposal.md`, "to be attacked") was challenged before the v35 edit. What changed:

- **Chain precedence.** The draft put the chain under `retry.fallbackChains.sage`; OMP resolves exact model keys first, so with sage on Fable that chain would never run. The order now lives under `anthropic/claude-fable-5-1` / `claude-fable-5`; the role-level `sage` chain is kept for a revert to Opus.
- **Cost per real dispatch.** The draft's "~2.1x Opus cost per answer" and "quota is a non-issue" were replaced by the ~2.4x batch ratio applied to the observed $1.12/dispatch baseline (~$2.6, +1.6 weekly-pool points at 2 dispatches/week), labelled as an estimate.
- **P1 contamination and bias.** The draft's headline (Sonnet mean Fable 8.19 > Opus 7.98, "Claude beat OpenAI on every cell") was downgraded: P1 leaked identity, excluding P1 erases the Sonnet Fable–Opus gap, and a cross-family judge pair (Grok, Sol 6.1) was added, which showed the ordering flips with the judge's family. Fable vs Opus is recorded as UNRESOLVED instead of a win.
- Unchanged: Astra gets no role (shared Plus meter, ~5x list price, AA 53 vs 52, Arena creative #38).

## 7. Reversal criteria

**Revert sage to `anthropic/claude-opus-5-5`** (one-line config change) if any of:

- Fable meter pressure (the Fable 7d sub-meter or the shared weekly pool rising materially because of sage dispatches).
- Silent model substitution observed (delivered id ≠ `claude-fable-5-1`, or server-side safeguard substitution).
- Interactive Fable → Opus continuity problems (failover dropping reasoning mid-session).
- A larger, blinded cross-family evaluation — ≥10 prompts, repeated answers, human or mixed-family judges, identity scrubbed, MCP disabled — shows no Fable advantage over Opus.

**Reconsider Astra** only if the Plus plan changes (Pro tier) or a role-specific benchmark shows a clear lead for hard novel problems.

## 8. Re-running the probes

Run inside `/tmp/probe/ab`-style scratch; fallback must be off **and** the delivered id checked:

```yaml
# nofallback.yml — retry.modelFallback is what actually stops chain switching
retry:
  modelFallback: false
  fallbackChains: {}
  usageAwareFallback: false
```

```sh
omp -p --no-session --no-tools --no-extensions --no-skills --no-rules --no-lsp --no-title \
  --mode json --thinking high --model anthropic/claude-fable-5-1 \
  --config nofallback.yml --system-prompt sage-system.md "$(cat P2.txt)" > P2_fable51.json
# verify: delivered provider/model must match the requested id
grep -o '"provider":"[^"]*","model":"[^"]*"' P2_fable51.json | sort -u
```

- `sage-system.md` is the body of `agents/sage.md`; swap `--model` for `anthropic/claude-opus-5-5`, `openai-codex/gpt-6-astra`, `openai-codex/gpt-6.1-sol`.
- Discard any run whose delivered id differs from the request.
- Read meters with `omp usage` before and after; they are whole-percent, so burn ratios from one run are hints.
- For judging, build blind folders per judge with a fresh A–D shuffle per prompt, keep the key outside the judge's reach, run judges with `--no-tools --thinking medium`, and use judges from more than one family. Scrub identity lines; disable MCP.
- Re-check staleness first per [`RESEARCH-PLAYBOOK.md`](./RESEARCH-PLAYBOOK.md).
