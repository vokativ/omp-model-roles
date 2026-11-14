# Owner notes — evidence and history behind the current setup

*Moved out of `README.md` on 2026-11-13 (snapshot v41) so the README stays short. This is the
owner's machine-specific record: subscription meter readings, incidents, OMP probe numbers, plan
billing details, and workflow habits, each as of its dated note — point-in-time, not current.
Current values: [model-roles.yml](model-roles.yml). Per-version history: [CHANGELOG.md](CHANGELOG.md).
Methodology: [research/RESEARCH-PLAYBOOK.md](research/RESEARCH-PLAYBOOK.md).*

## Optional subscription mixes — preview without changing this setup

[Subscription mixes](research/SUBSCRIPTION-MIXES.md) covers major OpenAI, Anthropic,
Google, and SpaceX/xAI/X plans, prices and caveats. The single selection behavior
contract is [instructions/SELECT-MODEL-MIX.md](instructions/SELECT-MODEL-MIX.md):
**instructions for OMP to follow, not a standalone program**.
It includes an **Anthropic-heavy allocation** (Max 5x $100 + ChatGPT Plus $20,
optionally Google AI Pro and X Premium) matching the current overlay's subscription base.
The source notes distinguish native subscription allowances from permitted OMP/API
use: Max's newly offered monthly API credits must be claimed after seven days and
used through an allowed API-key route. Existing OAuth remains untouched.

Paste this request into an OMP session, supplying your actual plans, workload, and
budget rather than assuming the example describes your account:

```text
Read instructions/SELECT-MODEL-MIX.md and follow it. Preview a complete conditional
future allocation for Claude Max 5x, ChatGPT Plus, non-trial Google AI Pro, and X Premium.
My workload is frequent implementation, planning, and architecture review,
with occasional vision/design work and one active machine. Subscription budget:
about $148/month; no additional paid API spend or top-ups. Max API credits are not
yet claimed and route permissions are unconfirmed; mark those as prerequisites,
not verified access. Inspect state/catalog read-only if available and ask only for
material missing information. Show all 15 roles, ordered fallbacks, agent bindings,
the full proposed overlay, rationale, provenance/independence limits, and budget
caveats. Compare Fable 5.1 with Opus 5.5 separately for plan and slow (architect agent) using
web evidence only. Do not apply changes, modify files/auth, install a profile,
buy anything, or send Fable/selected-model probe requests.
```

Reading the instruction file offline sends no model request. Asking OMP to follow
it uses the existing OMP session/model and may consume that model's allowance;
preview does not mean a zero-inference offline executable.
`model-roles.yml` itself doubles as a run-only overlay (`omp --config ./model-roles.yml`),
**not automatically installed** that way. It includes the mistral/typesafe/openrouter routes, so a
run in an isolated API-auth profile needs those logins or edits. Any later run needs the notes'
isolated-profile API-auth and provider-enforced spending prerequisites.
The [2026-10-08 Fable 5.1-versus-Opus 5.5 evaluation](research/FABLE-EVALUATION.md)
supports **provisional Opus 5.5 for both `plan` and `architect` in the Anthropic-heavy allocation**.
Fable remains a credible conditional choice, with correctness/rubric counterevidence,
not a promised upgrade or an excluded family; no direct controlled OMP plan/read-only
architect comparison was found in the reviewed sources. Historical local Fable
speed/depletion metrics are withdrawn because those runs fell back to OpenAI.
Fable 5.1 access itself was probe-verified on 2026-10-20 (delivered model ids checked
from events): accepted via Max 5x OAuth with no `credits_required`, unlike the
2026-09-04 Claude Pro 429. That does not change the FABLE-EVALUATION.md conclusion
(provisional Opus 5.5 for `plan`/`architect`); `sage` is the one role on Fable in v35
(below). The preview prompt above still authorizes no Fable or selected-model trial
calls. **No Max trial or alternative quality/quota benchmark is claimed.**
The current setup and its evidence below stay unchanged; subscription planning alone
does not by itself bump the snapshot version.

## Design rationale (why these specific models, not just "the best ones")

This isn't a "use the top-benchmark model everywhere" config — it's balanced against real
subscription capacity, confirmed via `omp usage` on the source machine:

| Login | Plan | Capacity signal | Treat as |
|---|---|---|---|
| `anthropic` | Claude Max 5x, $100/mo | Primary workhorse pool. 2026-11-03 reading: 5h varies (re-read before use), 7d **~46%** used, Fable 7d meter **3%** used (earlier reading) — a sub-cap inside the shared weekly pool (up to 50% of it); so far moved only by Claude Code usage, not OMP | **heavy workhorse and depth pool** — `task`, `smol`, `review`, and `security` on Sonnet 5.5; `slow` and `plan` (plus the `architect` agent) on Opus 5.5; `sage` on Fable 5.2 (v39); `commit`, `tiny`, `widget`, and Vibe/`sonic` workers on Haiku 5.5:low |
| `openai-codex` | ChatGPT Plus, $20/mo | OpenAI rate card: ~15-160 Sol 6.1 local messages per 5h (Astra 5-45). One chat 5h + one 7d meter shared by Sol, Astra, and Luna (`omp usage`, plan: plus). 2026-11-03 reading: 5h **16%** / 7d **78%** used, 3 saved resets | **independent critical reviewer & first fallback of most chains** — `critical` on Sol 6.1 guarantees independent provenance against Anthropic producers; Sol 6.1 / Luna are the first fallbacks of most chains (Luna is now second behind Mistral's GLM-5.3 Flash in `smol`/`tiny`, v37). The only OpenAI-primary role. The 7d meter is the tight one now |
| `google-antigravity` | Google AI Pro, ~$20/mo | 2026-11-03 reading, main account: shared Claude & GPT weekly pool **~93%** used (one pool for Antigravity Claude and Antigravity GPT); Gemini 4 Argon weekly **~37-40%** used (no longer exhausted); Gemini weekly **~5-6%** used; Gemini 5h reading varies. Four other accounts ~0% | **vision and advisor primary, and `default`'s first fallback** (v38: no longer the default primary) — `vision` and `advisor` primary on Gemini 3.8 Flash; first hop of `default`'s chain after `mistral/zai-glm-5-3` is Gemini 4 Hydrogen high (v42; was 3.8 Flash; also where it lands when Mistral returns HTTP 402), before Sonnet 5.5; Hydrogen high is also `task`'s second hop and Hydrogen medium `smol`'s third hop (v42); Antigravity Opus 5.5 is a depth fallback and sage's second hop, effectively unavailable until the shared pool resets (inference: ~93% is inside OMP's 10% usage reserve); Argon is `critical`'s first fallback and a middle hop in `slow`/`plan`/`review`/`security` and is usable again; Gemini 3.5 Flash-Lite (`tiny`, `commit`, `widget`) as a lightweight fallback |
| `xai-oauth` | X Premium, $8/mo (bundled SuperGrok credits) | Small weekly credit pool; 2026-11-03 reading: **~1-9%** used | **last-tier fallback** — Grok 4.7 ends depth/vision/critical chains; `grok-build` and `grok-composer-2.5-fast` end the cheap chains; select Grok 4.7 directly for one-off design work |
| `mistral` | Mistral Education (student Pro), $5.99/mo list (owner reports ~$5/mo; max 12 months) | Two separate included monthly allowances (admin.mistral.ai, 2026-11-03): **$150 Vibe Code** ($5.35 used) and **$15 API/Studio** ($0 used); each resets on the 1st of each calendar month, independent of renewal. OMP's vibe-scope key most likely draws the $150 Vibe Code one [inference: API usage read $0 after a day of OMP calls], shared with Mistral Vibe CLI, the Ubuntu server, and every Mistral hop. Pay-as-you-go is off for both. No 5h/weekly windows; **no `omp usage` meter** (live meter only in the Mistral console). Exhaustion returns HTTP 402 `billing_vibe_budget_exhausted` | **`default` primary (v38) plus bounded fallback hops** — `zai-glm-5-3` is the `default` primary (the only Mistral primary) and `task`'s third hop and `review`'s hop before the same-family Opus hop; `zai-glm-5-3-flash` ahead of Luna in `smol`/`tiny`; `mistral-large-4` in `vision` (after Sol 6.1, before Grok 4.7). Exhaustion walks `default` to Gemini 4 Hydrogen high (v42). Pool shared with the owner's Mistral Vibe CLI use and the Ubuntu server |
| `typesafe` | API key, prepaid credit (console.typesafe.ai; separate balance from OpenRouter) | No `omp usage` meter. `typesafe/jev-1.14.0`: $0.042/M input, output free (same price as via OpenRouter). Verified 2026-11-03 (omp 18.16.0): discovery lists `jev-1.14.0`, `jev-latest`, `jev-preview`; a fresh process judged via `typesafe/jev-1.14.0` (P=0.98, ~4 s whole run) | **judge primary** (v37.1) — direct native TypeSafe Jev judgments; no chat model routes through it |
| `openrouter` | API key, prepaid credit (~$7.5 left, 2026-11-03; separate balance from TypeSafe) | No `omp usage` meter. `typesafe/jev-1.14`: $0.042/M input, output free; 164 judgments cost $0.012 over 2026-09-28..10-28 | **judge fallbacks only** (v37.1; was the judge primary in v37) — Jev via OpenRouter, then Liquid d1.1; no chat model routes through it |

**Binding constraint (2026-10-20): the OpenAI Plus 5h window, not the 7d window.** Plus's 5h meter hit
100% five times between 2026-10-17 and 2026-10-19, with 26 `usage_limit_reached` errors on
Sol (10-17: 6, 10-18: 17, 10-19: 3). `critical` accounts for 135 of ~182 task dispatches
(74%) over 2026-10-06..10-20, mostly PR-review swarms. On 2026-10-20 the weekly pools (Anthropic 41%
used, Antigravity 2.3%, xAI 1%) were not the bottleneck; bursts on Plus were. Chain order
therefore avoids sending routine fallback traffic to Sol where a different pool is idle
(see `sage` below). The 2026-10-20 Plus 0% reading is a fresh-window snapshot and does not
contradict this. Percent meters are whole-percent and point-in-time.

**2026-11-03 update: the weekly meters now bind.** Plus 7d is **78%** used (5h 16%, 3 saved resets), and
Antigravity's shared Claude & GPT weekly pool is **~93%** used on the main account, so every
`google-antigravity/claude-opus-5-5` hop is effectively unavailable until it resets (inference: it
sits inside OMP's 10% usage reserve). Gemini 4 Argon is **~37-40%** used and available again, so Argon
hops work. A scan of the last seven days of this Mac's OMP sessions showed little Plus use (about 59
Sol messages) and no Antigravity Claude calls, so the drain likely comes from another machine or
non-OMP use (inference; the scan counts whole files touched in the window, an upper bound). v37's
Mistral hops in `smol`/`tiny` put a separately metered pool ahead of Luna to take pressure off Plus
(see the Mistral section below).

**2026-11-10 notes (no config change).** Two incidents, details in
[research/REVIEW-ROLE-EVALUATION.md](research/REVIEW-ROLE-EVALUATION.md): (1) omp's Codex meter read
5h 95% / 7d 72% while the owner's ChatGPT page showed 22% weekly, and OMP's usage preflight skipped
Sol on that reading (a real PR #104 review fell to Grok 4.7); (2) omarchy auto-updated to omp 18.18.6
(`update.auto: true` in its `config.yml`), which dropped the `google-antigravity` provider. omp 18.18.8
lists 13 Antigravity models again (2026-11-11, catalog only), and v40 pins `update.auto: false`.
Argon's weekly meter is at ~91% after the review benchmark. The Mistral lineup tests are in
[research/MISTRAL-LINEUP-BENCHMARK.md](research/MISTRAL-LINEUP-BENCHMARK.md).


**2026-11-13 (v42), Gemini 4 Hydrogen in three fallback hops** ([research/HYDROGEN-EVALUATION.md](research/HYDROGEN-EVALUATION.md)):
`default`'s first fallback, `task`'s second hop, and `smol`'s third hop move off Gemini 3.8 Flash / 3.5 Flash-Lite
onto `google-antigravity/gemini-4-hydrogen-high` (`default`, `task`) and `gemini-4-hydrogen-medium` (`smol`);
owner decision 2026-11-13. `vision` and `advisor` stay on 3.8 Flash (the model card shows +5.57 pp unjustified
multimodal refusals vs 3.8 Flash); the Flash-Lite hops in `tiny`/`commit`/`widget` are unchanged. Retest on omp
18.20.0 (fresh dir per run, bare ids under `defaultThinkingLevel: auto`, n=5 per cell, one small tool task):
Hydrogen high 5/5 in a median 21.2 s / 6 turns, medium 5/5 in 20.4 s / 6 turns, 3.8 Flash 5/5 in 62.5 s / 13
turns (~165.9K uncached input tokens vs ~23.0K for Hydrogen high); 12/12 Hydrogen runs were delivered by the
requested model, 0 edit/write errors. Artificial Analysis Index v5.0.1: Hydrogen high 51 vs 3.8 Flash 31;
Terminal-Bench 4.0 54% vs 19.7%. Hazard (G1): Google rejects `minimal` (HTTP 400, no `off`) but OMP 18.20.0's catalog
lists it, so `--thinking minimal`/`off` on a Hydrogen id silently walked the chain to 3.8 Flash; a YAML comment now
says never to add `:minimal`/`:off` to Hydrogen ids. Risk: Vertex lists Hydrogen as short-term GA with a minimum
45-day retirement notice (3.8 Flash: Vertex retirement Sept 2, 2027 or later). Limits: per-model quota cost is not
measured, and no Aider/OpenHands/Cline evals existed one day after launch. **Mistral 402 incident (not a config
change):** every `mistral/zai-glm-5-3` call on 2026-11-13 returned `402 Vibe budget exhausted
(type=billing_vibe_budget_exhausted)`, so `default` effectively ran on its first hop (Hydrogen high after v42)
until the allowance resets on 2026-12-01; the GLM hops in `smol`/`tiny`/`task`/`review`/`vision` fail fast too.
This Mac recorded only $11.90 of Mistral spend for November (`scripts/omp-spend.sh mistral 2026-11-01`), so most of
the $150 Vibe Code allowance was used elsewhere (Ubuntu server, omarchy, or Mistral Vibe CLI) [INFERENCE]; check
admin.mistral.ai. Revert: restore `google-antigravity/gemini-3.8-flash` for `default` hop 1 and `task` hop 2, and
`google-antigravity/gemini-3.5-flash-lite` for `smol` hop 3.

**2026-11-11 (v40), from the Fable 5.2 review** ([CHANGELOG.md](CHANGELOG.md)): `extendedContext`
off; GLM-5.3 keeps its own 150k compaction trigger because the toggle does not shrink its 1M window;
`commit` falls back to Luna first; `update.auto: false` and `defaultThinkingLevel: auto` are carried in
the overlay. Machine-local, not in the overlay: `auth.accountPolicies` with `reservePct: 0` for
`openai-codex` so the usage preflight stops skipping Sol on disputed meter readings (untested at a
real Plus limit; revert with `omp config set auth.accountPolicies '[]'`).

Consequences baked into this file (chains verified against `model-roles.yml`, 2026-11-03):
- **`default` runs on `mistral/zai-glm-5-3`** (v38, owner decision 2026-11-03; v37.2 and earlier: `google-antigravity/gemini-3.8-flash`), falling back to `google-antigravity/gemini-4-hydrogen-high` (v42; Gemini 3.8 Flash in v38-v41) $\to$ `anthropic/claude-sonnet-5-5` (was Sonnet $\to$ Sol 6.1 $\to$ Grok Build). Full evidence: [research/DEFAULT-ROLE-EVALUATION.md](research/DEFAULT-ROLE-EVALUATION.md); Hydrogen hop: [research/HYDROGEN-EVALUATION.md](research/HYDROGEN-EVALUATION.md).
  - **Why.** Gemini 3.8 Flash lost its speed case. In the OMP tool-task probe (2026-11-03) it took a median 21.6 s at `low` / 34.6 s at `high` (TTFT 2.7 / 3.3 s) vs GLM-5.3 7.6 s (TTFT 0.64 s) and Sonnet 5.5 ~9 s. GLM-5.3 also scores AA Index v5.0 31.7 vs 30.5 and Terminal-Bench 4.0 41.9% vs 19.7%, with a 1M context. Usage forensics on this Mac (30 days): every main session starts on Gemini 3.8 Flash but only 15% of turns stay there (Opus 53%, Sol 15%, Sonnet 8%, Grok 4.7 7%); 10 of 16 sessions switched away within 6 minutes.
  - **Owner priority: keep the default off the Claude Max pool**, so Sonnet 5.5 is last. Sol 6.1 and Grok Build leave the chain (Plus 7d meter 78% used; Grok Build has a 512K window and 5 edit errors in 11 calls). Thinking for `default` stays on `defaultThinkingLevel` auto (judge-driven); the owner rejected pinning Gemini to `:low`.
  - **Allowance and 402 behaviour.** GLM-5.3 draws the Mistral EDU monthly allowance, most likely the $150 Vibe Code one (see the Mistral section), shared with Mistral Vibe CLI, the Ubuntu server (same global config), and the Mistral fallback hops; Mistral pay-as-you-go is off. Repriced at Mistral rates (GLM-5.3 $1.4 / $0.14 cached / $4.4 per M tokens), this Mac's current default-only turns (279 in 30 days) cost ~$4.65/mo (~3% of $150); running every main turn on GLM-5.3 would cost ~$92/mo, which fits inside $150 on this Mac alone but leaves ~$58 for the server, Mistral Vibe CLI, and the hops [inference: repricing, not a measured meter]. Exhaustion returns HTTP 402 and `retry.fallbackOn` walks the chain to Gemini 4 Hydrogen high (v42; Gemini 3.8 Flash, the v37 default, before). There is no `omp usage` meter for Mistral, so `retry.usageAwareFallback` cannot skip a depleted primary in advance.
  - **Image caveat.** GLM-5.3 is text-only: an image attached to a default session is not seen (verified 2026-11-03: plain "What is in this image?" made it fall back to decoding pixels with Python/OCR, ~10 tool calls, unreliable for real screenshots). Ask: "Use the read tool on the attached image and tell me ..." (or "use read on <file> and ..."); GLM calls `read`, gets the hint, then `read <path>?q=<question>`, which the `vision` role (Gemini 3.8 Flash) answers correctly. "Read the attached image with the vision model ..." alone did **not** work (same pixel-decoding fallback). `/model` to an image-capable model is the alternative.
  - **Ctrl+P `cycleOrder` is unchanged** (`smol`, `default`, `slow`, `sage`). **Revert:** set `modelRoles.default` back to `google-antigravity/gemini-3.8-flash` and `retry.fallbackChains.default` to `["anthropic/claude-sonnet-5-5","openai-codex/gpt-6.1-sol","xai-oauth/grok-build"]`.
- **No `openrouter` or `nvidia` chat model appears in any role or chain; `typesafe` and `openrouter` serve the `judge` role only.** v33 excluded external API tiers (OpenRouter GLM 5.3 Flash, NVIDIA Nemotron) to fit the four paid subscriptions; earlier GLM/Nemotron floors are historical (see the v17-v23 log in `model-roles.yml`). v37 added two logins beyond those four: `mistral` (plan key; fallback hops, and since v38 also the `default` primary) and `openrouter` (prepaid API credit, native judgment routes only); v37.1 adds a seventh, `typesafe` (prepaid API key, judge primary), and demotes `openrouter` to judge fallbacks.
- **`vision`** keeps `google-antigravity/gemini-3.8-flash` primary, falling back to `anthropic/claude-sonnet-5-5` $\to$ `openai-codex/gpt-6.1-sol` $\to$ `mistral/mistral-large-4` $\to$ `xai-oauth/grok-4.7` (the Mistral hop is v37.2, owner decision 2026-11-03: Large 4 read the probe image correctly, the best vision result of the Mistral models, with the cleanest OMP tool run; 1M context, image input; public preview). It sits late because it only runs after Gemini 3.8 Flash, Sonnet, and Sol all fail. (The 2026-08-22 OpenRouter Gemini 3.8 Flash A/B winner is no longer in the chain.)
- **`critical` keeps strict cross-provider independent provenance**: primary `openai-codex/gpt-6.1-sol`, then `google-antigravity/gemini-4-argon`, then `xai-oauth/grok-4.7`. Independence holds against Anthropic producers; if a producer has failed over to Sol, the producer/reviewer collision must be caught by `critical`'s own provenance check. Argon's weekly meter was exhausted until ~2026-10-24 (historical); it reads ~37-40% used now and is usable, so a Sol failure falls to Argon first. Since v36 it is scoped to irreversible/operational go/no-go decisions only; PR review moved to `reviewer` (next bullets), which removes the PR-review swarms that drove most `critical` dispatches. No Mistral model is in `critical` (hallucination robustness: Artificial Analysis Omniscience +6 for GLM-5.3 vs +42 for Sol and +46 for Argon).
- **`slow` / `plan` run on `anthropic/claude-opus-5-5`**, falling back to `openai-codex/gpt-6.1-sol` $\to$ `google-antigravity/gemini-4-argon` $\to$ `google-antigravity/claude-opus-5-5` $\to$ `xai-oauth/grok-4.7`. `security` uses the same chain (primary: Sonnet 5.5).
- **`review` (bundled `reviewer`, i.e. PR review) runs on `openai-codex/gpt-6.1-sol`** (v36), falling back to `google-antigravity/gemini-4-argon` $\to$ `xai-oauth/grok-4.7` $\to$ `mistral/zai-glm-5-3` $\to$ `google-antigravity/claude-opus-5-5` (the Mistral hop is v37). Rule: the reviewer's model family must differ from the author's. Producers here are Claude, so Sol reviews; Opus sits last because it is same-family (treat a review it produced as non-independent). v37 inserts GLM-5.3 (a Z.ai-family model hosted by Mistral, text-only, 1M context) ahead of it so the last independent hop is not the same-family one, which matters now that the Antigravity shared Claude & GPT pool is at ~93% (2026-11-03 reading) and its Opus hop is effectively unavailable. Evidence for it is the OMP edit-tool probe (0 edit errors) and Terminal-Bench 4.0 41.9%, not a review benchmark; no review-precision evidence exists for it. OMP's own `reviewer` default is `@slow` (Opus); the previous `@review` = Sonnet setting was both same-family and a smaller model. If a PR was written on Sol/Codex, select Opus for that review by hand. For high-stakes PRs, run `reviewer` on both Sol and Opus. Do not fan out reviewer swarms on Sol: the Plus 5h window is the binding constraint. [cubic BugBench](https://www.cubic.dev/bugbench/compare/claude-sonnet-5-5-vs-gpt-6-1-sol) (2026-10-26) shows Sonnet 5.5 and Sol 6.1 statistically tied on bugs in code they write; it is not a review benchmark, so the choice rests on family independence, not a measured review-quality gap.
- **The `architect` agent binds to `@slow`** (v36). The redundant `architect` role/chain/carousel entry was collapsed into `@slow` (both ran Opus 5.5 on identical fallback chains). The read-only consultant agent contract lives in `agents/architect.md`.
- **`sage` (Thinking Partner) is on `anthropic/claude-fable-5-2` since v39 (Fable 5.1 since v35) — provisional and reversible.** Failover is Opus 5.5 $\to$ Antigravity Opus 5.5 $\to$ Sol 6.1 $\to$ Gemini 4 Argon $\to$ Grok 4.7, owned by the **model-level** `anthropic/claude-fable-5-2` chain (identical `claude-fable-5-1` and `claude-fable-5` chains cover explicit `--model` use and a revert to 5.1): OMP checks exact model-key chains before role-key chains (`omp://settings.md`; also seen in the binary strings), so the role-level `sage` chain (Antigravity Opus 5.5 $\to$ Sol 6.1 $\to$ Argon $\to$ Grok 4.7) applies only if `sage` reverts to Opus. Antigravity Opus precedes Sol so `sage` does not drain the Plus 5h window that `critical` swarms exhaust; Argon stays late by design (it was exhausted until ~2026-10-24 when v35 set the order; now ~37-40% used and usable). Emits no rigid JSON schema. No Mistral model is in `sage` (AA Intelligence 32 and below vs the 50+ depth tier). **Revert:** set `modelRoles.sage` back to `anthropic/claude-fable-5-1` or `anthropic/claude-opus-5-5`.
- **Why Fable for `sage`, and what is not proven.** Access: 2026-10-20 probes accepted Fable 5.1 via Max OAuth; a 2026-11-11 dispatch on `anthropic/claude-fable-5-2` (13 turns, tools enabled, repo cwd) was accepted with the delivered id `claude-fable-5-2` verified from the event stream — no fallback hop fired. Quality is **unresolved**: a blind A/B (3 sage-style prompts × 4 models, one answer per model per prompt, thinking high, delivered ids verified) gave mean rubric scores (1-10) that depend on the judge's family — Sonnet 5.5 ×3: Fable 8.19, Opus 7.98, Astra 6.61, Sol 6.30; Grok 4.7 (neutral): Fable 8.43, Opus 8.13, Astra 7.85, Sol 7.74; Sol 6.1: Astra 8.83, Sol 8.70, Fable 6.35, Opus 6.28. Judge-family self-preference dominates; prompt P1 leaked first-person model identity, and excluding P1 Sonnet's Fable–Opus gap vanishes (8.14 vs 8.19); n = 3 prompts, not 9. Chosen anyway on low volume (4 sessions in 14 days, ~2 completed dispatches/week, all on Opus: $4.50 API-equivalent, ~$1.12/dispatch), the best published pushback evidence (AA-PersonalityBench: Fable #1 of 36 on "constructively pushes back"; Arena creative writing Opus 5.5 #1, Fable 5.1 #9, Sol 6.1 #30, Astra #38), and decorrelation from the Opus-based `plan`/`architect`/`slow` (inference). **Estimates:** Fable ~2.4x cost and ~1.6x latency per answer in the batch (≈$2.6/dispatch, roughly +1.6 weekly-pool points vs Opus at 2 dispatches/week; the $185 ≈ 100% weekly calibration is rough).
- **Fable operational caveats.** Fable reasoning blocks are readable only by Fable/Mythos: a mid-session Fable → Opus failover drops that reasoning, and OMP may skip same-provider fallback when signed thinking history exists (fresh dispatches are unaffected). Fable always thinks, and safeguard classifiers can substitute Opus 4.8/Opus 5 server-side (`providers.anthropic.serverSideFallback` defaults to false). It draws the shared Max weekly pool faster, no published multiplier. Policy risk: OMP presents as Claude Code over Max OAuth (can1357/oh-my-pi issue 12487); Anthropic's 2026-10-07 update says subscription limits remain usable with third-party apps. Max's $100/mo API credits cover API-key use, not OAuth.
- **Astra (`openai-codex/gpt-6-astra`) is in no role and no chain.** Probe-verified accepted on Plus on 2026-10-20, but it draws the same Plus 5h/7d meter as Sol (no failover resilience when Plus saturates); list price is ~5x Sol 6.1 ($10/$50 vs $2/$10 per M tokens; Artificial Analysis cost/task $3.26 vs $0.72) for an Intelligence Index of 53 vs 52, with Coding Agent Index within 1-2 points; Arena creative writing ranks it #38 vs Opus 5.5 #1. A coarse burn probe saw 13.8K Astra tokens = +1 meter point = 40.8K Sol tokens (whole-percent granularity: hypothesis ~3-5x, not a measured ratio). Use only as an explicit one-off — `--model openai-codex/gpt-6-astra` — when stuck and Plus has headroom. Earlier README text placing Astra in sage's fallback chain no longer applies.
- **`task` runs on `anthropic/claude-sonnet-5-5`**, falling back to `openai-codex/gpt-6.1-sol` $\to$ `google-antigravity/gemini-4-hydrogen-high` (v42; was Gemini 3.8 Flash) $\to$ `mistral/zai-glm-5-3` $\to$ `xai-oauth/grok-build` (the Mistral hop is v37: GLM-5.3 scored Terminal-Bench 4.0 41.9% vs 19.7% for Gemini 3.8 Flash and made 0 edit-tool errors in OMP probes). The bundled `task` agent (and Vibe's `good` tier) already binds to `@task`, so no override is needed (v36 removed the duplicate `good_worker` role). Sol 6.1 ($2/M input, $0.10/M cached, $10/M output, 128K max output in the installed catalog) serves as `critical` primary and first fallback; with `extendedContext: false` (v40) Codex Sol has a **500K** window (922K when on).
- **`designer` role removed** (v36). OMP has no built-in designer role or agent; invoke `xai-oauth/grok-4.7` directly via `/model xai-oauth/grok-4.7` when design work is needed.
- **`smol` runs on `anthropic/claude-sonnet-5-5`** (chain: `mistral/zai-glm-5-3-flash` $\to$ Luna $\to$ Gemini 4 Hydrogen medium (v42; was Gemini 3.5 Flash-Lite) $\to$ Grok Build). **`tiny` runs on `anthropic/claude-haiku-5-5:low`** (chain: `mistral/zai-glm-5-3-flash` $\to$ Luna $\to$ Gemini 3.5 Flash-Lite $\to$ `grok-composer-2.5-fast`). v37 puts Mistral's GLM-5.3 Flash ahead of Luna in both to relieve the ChatGPT Plus 7d meter (78% used on 2026-11-03): Artificial Analysis Intelligence v5.0 27.8 vs Luna's 21.4, vision, 1M context, $0.15/$0.5 per M, 0 edit-tool errors in 6 turns / 8.2 s in OMP probes. **Bundled `sonic` (Vibe's `fast` tier) is routed with `task.agentModelOverrides.sonic: "@tiny"`** (v36, replacing the `fast_worker` role): bundled `sonic` otherwise binds to `@smol` (Sonnet 5.5). The override names a role, not a bare model, on purpose: a role-less pinned subagent falls back through the `default` chain (Sonnet first). History: v24 moved the cheap tier off OpenAI's retired `gpt-5.3-codex-spark` onto Grok; v33 moved it onto Haiku.
- **`widget` runs on `anthropic/claude-haiku-5-5:low`** (v36; chain: Gemini 3.5 Flash-Lite $\to$ Grok Composer 2.5 Fast). Resolves OMP 18.12.3's `async.widgets: true` background job author defaulting to `smol` (Sonnet 5.5), protecting frontier quota while providing fast, concise status-line widgets.
- **`judge` runs on `typesafe/jev-1.14.0`** (v37.1, direct TypeSafe; chain: `openrouter/typesafe/jev-1.14` $\to$ `openrouter/typesafe/jev-1.13` $\to$ `openrouter/liquid/d1.1`). It activates semantic `find` under OMP's `find.enabled: auto` default (which requires the judge to resolve first to a native judgment model), auto-prewalk, smart `tui.autoGraph`, and typed Eval judgments (`judge()`, `judge_batch()`). **v36 regression and root cause (historical):** v36 set `typesafe/jev-1.14.0` as primary, claiming stored TypeSafe credentials in `agent.db`; no TypeSafe credential ever existed there (likely a misreading of pre-v36 `model_usage` rows whose role was `typesafe` but whose provider was OpenRouter). `typesafe/jev-preview` is not seeded, which logged `Fallback chain for role 'judge' does not resolve to a compatible model`, and the chain had no OpenRouter route. Since 2026-10-28 every judgment therefore fell through to prompted `gemini-3.5-flash-lite` (0/1 probabilities), which disabled `find`, auto-prewalk, and smart `autoGraph`. Before v36 OMP's built-in chain reached OpenRouter Jev: 164 judgments over 2026-09-28..10-28 cost $0.012. **Natives only, on purpose:** once a credentialed native judge fails, OMP never tries a prompted chat model, so a chat tail is dead config (tested). **v37 fix (2026-11-03):** judge on `openrouter/typesafe/jev-1.14` (chain `openrouter/typesafe/jev-1.13` $\to$ `openrouter/liquid/d1.1`); `omp find` answered in ~2 s with 4 relevant hits (baseline 6.3 s, 0 hits); `judge_batch` 0.40-0.56 s per call with graded probabilities 0.89-0.96; the warning was gone and the `find` tool present. **v37.1 (2026-11-03, omp 18.16.0):** the owner stored a TypeSafe API key (`/login typesafe`; `agent.db` `auth_credentials` row `provider=typesafe`, `api_key`), so the direct route now works. TypeSafe discovery lists `typesafe/jev-1.14.0`, `jev-latest`, and `jev-preview`; a fresh process judged via `typesafe/jev-1.14.0` (P=0.98, ~4 s whole run). **Forced failover test** (run-only overlay `judgment.attemptTimeoutMs: 1`): the logs show `typesafe/jev-1.14.0`, `openrouter/typesafe/jev-1.14`, and `openrouter/typesafe/jev-1.13` each `Aborted: The operation timed out.`, then `openrouter/liquid/d1.1` answered (P=0.993), so the full chain walk is verified. `find` with the v37.1 overlay: coverage complete, 4 relevant hits, $0.0018. Same model and price ($0.042/M input, output free) as v37, so the switch is about route diversity, not cost: TypeSafe credit funds the primary and OpenRouter credit is fallback-only (two separately funded prepaid balances). Direct `jev-latest`/`jev-preview` are intentionally **not** in the chain: same provider and endpoint as the primary, and TypeSafe's docs say both currently alias `jev-1.14.0`. **Restart running OMP sessions:** a session started before the TypeSafe login keeps its cached judge route (one such session still judged via OpenRouter); a fresh process picks up the direct route. Mistral is not a judge candidate (no native judgment API; prompted `mistral-small-2603` was ~3x slower).
- **`critical` agent runs with `structured: true` and `read-summarize: false`** (v36). Restores the `yield` tool and output schema validation broken in OMP 18.10.2+ for subagents spawned by `task`, while ensuring adversarial gates inspect raw source without structural line elisions.

### Haiku 5.5: bounded subscription adoption (v32, widened in v33)

`commit` uses `anthropic/claude-haiku-5-5:low`, followed by Luna → Gemini 3.5 Flash-Lite →
Grok Build (v40: Grok Build moved last after 44.8 s vs 5.6 s in the commit dry run and weekly-meter peaks of 90%/99%). It is infrequent, bounded summarization work, not general
implementation. v33 also moved `tiny` and Vibe/`sonic` workers to Haiku 5.5:low and made it
`advisor`'s first fallback; automatic fallback traffic can become sustained load
on the same Claude allowance (now Max 5x) used by every Anthropic-primary role.

At v32, Claude Pro OAuth access and native OMP 18.8.3 tool replay were exercised with model
and usage-aware fallback disabled. No Haiku was listed by any of the five
authenticated Antigravity inventories. OpenRouter lists it as a separately billed
API model, not subscription capacity. No custom model definition is needed.

On one identical staged utility-function addition, actual `omp commit --dry-run
--no-changelog` requests produced faithful, validated messages:

| Model | Wall time | Commit-agent tool calls |
|---|---:|---:|
| Haiku 5.5, low effort | 5.63 s | 3 |
| Grok Build | 44.81 s | 6 |

This is a single-workload screening result, not a general speed, quality, or quota
benchmark. [Haiku's overview](https://platform.claude.com/docs/en/models/haiku-5-5/overview)
specifies 1M context, 128K output, adaptive effort, and text/image input. API
input/output prices are $0.10/$0.50 per million tokens through 100K prompt tokens,
and $0.50/$2.50 above 100K; those are not Claude Pro quota multipliers.
[Anthropic recommends](https://www.anthropic.com/claude-haiku-5-5) narrowly scoped
work for Haiku and larger Sonnet/Opus models for complex agentic coding.

### Antigravity: paid main setup versus free accounts (v31)

The main overlay targets the paid Google AI Pro account's Claude 5.5 lineup.
Authenticated inventories on 2026-10-07 (Claude 4.6 since removed per Google's schedule) showed one `g1-pro-tier` account with
Opus/Sonnet 5.5 and four free accounts with Opus/Sonnet 4.6. Opus and Sonnet share
the account's Claude pool; they are not independent quota reservoirs.

Both `google-antigravity/claude-opus-5-5` and `google-antigravity/claude-sonnet-5-5`
completed OMP requests at `thinking: high` with retries and model/usage-aware
fallback switching disabled. Both also completed a `read` tool round trip and
returned the file contents with LSP disabled. The then-updated `@advisor` alias resolved
to Sonnet 5.5 (advisor has since moved to Gemini 3.8 Flash, v33), and `@default` completed on Gemini 3.8 Flash without falling back.
The earlier 404 probes no longer describe current access. Free-account 4.6
availability is inventory evidence, not a new inference test.

Do not import the main overlay unchanged on a free-only setup: its depth chains and sage's
Fable chain include Antigravity Opus 5.5, which free accounts do not expose; keep non-Google fallbacks.
The low-capacity free Google accounts can still supplement eligible Gemini models;
they do not provide extra Claude 5.5 capacity. No account-specific routing policy
or credential pinning is added by this overlay.
[Google's model documentation](https://antigravity.google/docs/models.md) limits
Claude 5.5 to non-trial Pro/Ultra subscriptions and scheduled Claude 4.6 and
GPT-OSS-120B removal for **2026-11-02** (now past; free accounts' 4.6 availability on 2026-11-03 was not re-checked). Historical research files retain their
original 4.6 measurements; they are not the current main-setup allocation.

### Mistral EDU plan: bounded adoption (v37; `default` primary added v38)

Full evidence, probe tables, and sources: [research/MISTRAL-EVALUATION.md](research/MISTRAL-EVALUATION.md).

**Plan facts (observed 2026-11-03).** Mistral's Education plan is the Pro plan with a student
discount: $5.99/mo list (normally $14.99; the owner reports ~$5/mo), at most 12 months, verified
institutional email. It includes Le Chat Pro, Mistral Vibe (CLI, IDE, web), and "$15/mo in API
credits" per the pricing card. "Vibe" in this section means Mistral's product; elsewhere in this
README `Vibe` means OMP's good/fast worker tiers.

**Billing route.** OMP's `/login mistral` key is a "vibe"-scope plan key (Mistral Vibe's `whoami`
reports `plan_name` EDU). The admin subscription page (admin.mistral.ai, owner screenshot 2026-11-03
12:26) shows **two separate included monthly allowances**, each resetting on the first day of each
calendar month independently of the subscription renewal: **Included API usage** (API/Studio) $0 used
of $15, and **Included Vibe Code usage** $5.35 used of $150. "API pay-as-you-go" and "Pay-as-you-go
for Vibe Code" both show an "Enable" button, i.e. both are off. **Inference:** OMP's vibe-scope key
draws the $150 Vibe Code allowance, not the $15 API one: API usage read $0 after a day of OMP calls
through that key, and the $5.35 includes that day's OMP research probes plus any Mistral Vibe CLI
use. v37 had inferred ~$15/mo from the pricing card's API-credit line; that figure was wrong for OMP's
key and is corrected here. The $150 allowance is shared across the owner's Mistral Vibe CLI, the Ubuntu
server (same global config), and every OMP Mistral entry (the v38 `default` primary and all fallback
hops). The `has_paid_vibe_entitlement: false` in `~/.vibe`'s cache is a client default that only
suppresses an upgrade prompt and is irrelevant to EDU. The owner's own Mistral Vibe CLI usage (default
model GLM-5.3, hosted by Mistral) draws the same budget as OMP.

**Probe matrix (omp 18.16.0, 2026-11-03).** Each model ran the same tool task (run a failing test, fix
the planted bug with `edit`, create and run two new files), a vision prompt, a commit-message prompt,
and two reasoning puzzles at several thinking levels; `n` is 1-3 per cell, so rankings are directional.
List-price spend for the whole session was under $0.30.

| Model | Tool task | `edit` errors | Image | Note |
|---|---|---|---|---|
| `zai-glm-5-3-flash` | 6 turns, 8.2 s | 0 | pass | cheapest; ~1.3 s on the commit prompt |
| `zai-glm-5-3` | 10 turns, 13.8 s | 0 | text-only | three self-fixed assertion errors in its own test |
| `mistral-large-4` | 5 turns, 10.8 s | 0 | pass | cleanest run, best commit message; public preview |
| `deepseek-v4-1-flash-1017` | 4 turns, 5.7 s | 0 | text-only | fastest; emitted thinking-only turns that OMP auto-continued; public preview |
| `mistral-small-2603` | 8 turns, 11.6 s | 0 | misread text | wrong once on a puzzle at high thinking |
| `mistral-medium-latest` | 9 turns, 13.3 s | 3 of 4 malformed | pass | slowest on small prompts |
| `ministral-14b-2512` | 56 turns, 114.8 s | 47 of 47 failed | pass | finished only by rewriting the file with `write` |
| `mistral-medium-3.5` (alias) | 14 turns, 18.6 s | 6 of 7 failed | pass | null catalog metadata; answered a puzzle wrongly (never thinks) |

OMP accepted every thinking level on every model; the effect is weak and non-monotonic, and `off`
sends the lowest effort rather than disabling reasoning on GLM-5.3. Chain entries are bare ids.

**Chosen entries** (one `mistral/*` entry per chain; fallback hops except `default`, the one primary, added in v38; `vision` added in v37.2):

- `default` (primary, v38): `mistral/zai-glm-5-3` $\to$ Gemini 4 Hydrogen high (v42) $\to$ Sonnet 5.5
- `smol`: `mistral/zai-glm-5-3-flash` $\to$ Luna $\to$ Gemini 4 Hydrogen medium (v42) $\to$ Grok Build
- `tiny`: `mistral/zai-glm-5-3-flash` $\to$ Luna $\to$ Gemini 3.5 Flash-Lite $\to$ `grok-composer-2.5-fast`
- `task`: Sol 6.1 $\to$ Gemini 4 Hydrogen high (v42) $\to$ `mistral/zai-glm-5-3` $\to$ Grok Build
- `review`: Argon $\to$ Grok 4.7 $\to$ `mistral/zai-glm-5-3` $\to$ Antigravity Opus 5.5
- `vision`: Sonnet 5.5 $\to$ Sol 6.1 $\to$ `mistral/mistral-large-4` $\to$ Grok 4.7

GLM-5.3 Flash (AA Intelligence v5.0 27.8, Terminal-Bench 4.0 32.8%, vision, 1M context, $0.15/$0.5)
precedes Luna (AA 21.4). GLM-5.3 (AA 31.7, Terminal-Bench 4.0 41.9% vs Gemini 3.8 Flash's 19.7%, 1M
context, text-only, $1.4/$4.4) is the `default` primary (v38), `task`'s third hop, and a cross-family reviewer before the
same-family Opus hop. Large 4 (AA 26.0, 1M context, image input, catalog `maxTokens` 262,144; OMP list price $1.36/$4.18 vs Mistral's own $0.70/$2.10) had the cleanest OMP tool run (5 turns, 10.8 s, 0 edit errors) and read the probe image correctly, the best vision result of the Mistral models. It is `vision`'s third hop, after Sol and before Grok 4.7, so it only runs when Gemini 3.8 Flash, Sonnet, and Sol all fail. Its Terminal-Bench 4.0 score is 24.7% in a neutral harness (41% in Mistral's own Vibe harness), which is why it is a vision-only hop. Only one entry per chain, because two entries on one routing provider share one pool.

**Not adopted** (`mistral-large-4` is adopted for `vision` only; elsewhere it stays an explicit `/model` choice):

- `mistral-large-4` for any chain other than `vision`: public preview; AA 26.0; Terminal-Bench 4.0 24.7% in a generic harness (41% in Mistral's own Vibe harness), too weak for the tool-heavy chains.
- `deepseek-v4-1-flash-1017`: public preview; strong AA (32.5) but emitted thinking-only turns OMP had to auto-continue.
- `mistral-medium-3.5`: deprecated 2026-10-31, Terminal-Bench 4.0 0%, 3 of 4 malformed hashline edits (`mistral-medium-latest`).
- Small 4 / Ministral: AA 4.3 / weak; `ministral-14b` failed 47 of 47 edits and looped for 115 s.
- Alias ids (`mistral-medium-3.5`, `zai-glm-5`, `mistral-vibe-cli-*`): no OMP catalog metadata, so no thinking control, null context window, and zero cost accounting.
- No Mistral model in `critical`, `slow`/`plan`/`security` (AA at most 32 vs the 50+ depth tier), `sage`, `judge` (Mistral has no native judgment API), or as a primary other than `default` (v38, owner choice; see below). `vision` has `mistral/mistral-large-4` as a late fallback only (v37.2).

**v38 default exception.** The owner chose `mistral/zai-glm-5-3` as the `default` primary, the one
exception to v37's "no primaries" rule: faster and stronger on the tool task than Gemini 3.8 Flash, and it
keeps routine turns off the Claude Max pool. Rationale, usage forensics, probe numbers, and repricing:
[research/DEFAULT-ROLE-EVALUATION.md](research/DEFAULT-ROLE-EVALUATION.md). GLM-5.3 is text-only (attached
images are not seen; ask "Use the read tool on the attached image and ..." - "read it with the vision model" alone did not work in testing - or `/model` to an image-capable model). Pay-as-you-go is off, so exhaustion means HTTP
402 and a walk to Gemini 4 Hydrogen high (v42; Gemini 3.8 Flash before).

**Risks.**

- **Unmetered.** No `omp usage` meter, so `retry.usageAwareFallback` cannot skip a depleted Mistral entry in advance (inference: unknown usage fails open); an entry is discovered empty only when it errors, which now includes the `default` primary on the first turn after exhaustion.
- **Shared pool.** Mistral Vibe CLI, the Ubuntu server, and every OMP Mistral entry draw the same $150/mo Vibe Code allowance (inference for OMP's key; see Billing route); heavy Mistral Vibe CLI or server use shrinks what the `default` primary and the fallbacks have.
- **Monthly reset.** Exhaustion lasts to the 1st of the next calendar month. It returns HTTP 402 `billing_vibe_budget_exhausted` (documented in mistral-vibe issue 1362 for a Free plan; first observed in OMP on 2026-11-13, see the v42 note above); OMP's `retry.fallbackOn` default `any` walks the chain on it, so `default` lands on Gemini 4 Hydrogen high (v42). Chain walking into the Mistral hop was verified with a forced runtime error (HTTP 410 on the `tiny` primary): the `sonic` subagent answered on `mistral/zai-glm-5-3-flash`.
- **Preview and deprecated models.** The chosen GLM-5.3 models are not previews, but Large 4 (now the `vision` chain's third hop, v37.2) and DeepSeek V4.1 Flash are public previews, so Large 4's availability or behavior could change; DeepSeek is not in any chain; Medium 3.5 is deprecated. Re-check the catalog before widening.
- **Provider vs family.** GLM-5.3 is a third-party model family served by Mistral; for independence, record both the routing provider and the family.
- **Data and terms.** The pricing page lists "Model training: Opt-out" for Pro; that it applies to EDU is an inference and the opt-out setting was not checked. Third-party-harness terms for the student plan were not checked. The renewal price after the 12 months is not stated.

**Check the meter.** Not in `omp usage`. Use https://console.mistral.ai/codestral/cli ("View
organization usage"), https://admin.mistral.ai/subscription (plan, included usage, PAYG toggle), or
https://admin.mistral.ai/organization/usage ("Vibe usage beyond quota"). To confirm the login and
selectors: `omp models mistral --json`.

### Extended context: off everywhere (v40)

v40 (2026-11-11, owner decision) sets **`extendedContext: false`** on every machine, reversing the
2026-10-02 "on everywhere" policy below, to rein in quota burn from very long contexts. Measured that day
with `omp models find` on omp 18.18.8, off only shrinks models that declare an extended window:

| Model | On | Off |
|---|---:|---:|
| `openai-codex/gpt-6.1-sol` | 922,000 | 500,000 |
| `openai-codex/gpt-6-luna` | 872,000 | 272,000 |
| `anthropic/claude-haiku-5-5` | 1,000,000 | 100,000 |
| GLM-5.3 / 5.3 Flash, Mistral Large 4, Gemini 3.8 Flash / Argon | 1,048,576 | unchanged |
| Claude Sonnet / Opus 5.5, Fable 5.2, Antigravity Opus 5.5 | 1,000,000 | unchanged |

GLM-5.3 (`default`) therefore keeps its own `compaction.modelThresholds` trigger at 150k (v38.1).
Check on 2026-11-11: since v38.1, 0 of 44 GLM-5.3 calls exceeded 150k (average prompt 65k, $0.026/call)
vs 690 of 766 on 2026-11-10 ($0.069/call); no session reached the trigger yet, so it is configured but
not yet exercised. `scripts/omp-spend.sh mistral` tracks it. No Gemini or Claude threshold is set.

The 2026-10-02 analysis below is kept as the historical record for the earlier "on" policy.

**Historical (2026-10-02 to v39):** after the cross-machine review, the owner chose **one configuration
everywhere: `extendedContext: true`**. This superseded both the initial off trial
and the interim machine-local proposal. The Ubuntu development server was already on;
the Mac was subsequently enabled to match.

(Sol 6.1 is now `critical`'s primary and the first fallback of most chains; the analysis
below predates the Anthropic-heavy v33 allocation, when Codex served more roles.)

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

On 2026-10-02 the shared ChatGPT Pro ($100) OpenAI account (since replaced by Plus, v33) reported **44% weekly usage**, **56% remaining**,
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

The persistent setting is `omp config set extendedContext false` (v40); start a new
session after importing it. OMP also exposes `/extended-context on|off|status` in its
interactive UI. Do not fake a larger provider limit through `models.yml`.

## Daily workflow: choose the job, not a committee

| Need | Normal choice |
|---|---|
| Small, clear change or everyday conversation | `omp`; stay on the default model (GLM-5.3 since v38; text-only, so for an attached image ask "Use the read tool on the attached image and ..." (not just "read it with the vision model", which failed in testing), or `/model` to an image-capable model) |
| Build/fix with a useful exploration phase and routine implementation | Opus 5.5 → Sonnet 5.5 prewalk (`@slow` → `@smol`), explicitly opted in |
| Hard reasoning remains throughout implementation | Stay on `@slow`; no forced downgrade |
| Review a design, implementation, plan, or configuration | Ask for the `architect` agent; define the question and scope |
| PR / diff review | Bundled `reviewer` (Sol 6.1, cross-family to Claude authors); `security-reviewer` for vulnerability hunting |
| Challenge the premise or explore a different direction | `sage` |
| Go/no-go before a release, migration, cutover, or destructive action | `critical`, with producer identity, `reviewer` findings, and validation evidence |
| Human approval required before any implementation | `/plan`; prewalk is not an approval boundary |

**Roles select models; agents select instructions.** `/model @slow` or
Ctrl+P selects Opus 5.5, not `agents/architect.md`'s read-only review contract.
Request "use the architect agent to review X" for that contract; the agent binds to `@slow`.
`slow` and `plan` share Opus 5.5; `security`, `smol`, and `task` use Sonnet 5.5;
`sage` is on Fable 5.2; `review` and `critical` are the Sol-primary roles. Different prompts on one
model, or direct and Antigravity Opus 5.5, are not independent model votes.
Keep reviews targeted; do not run all four (`architect`, `reviewer`, `security-reviewer`, `critical`) by habit. Retain `critical`'s structured
verdict/provenance schema; architect's schema was removed for human usability, not
because its performance overhead was measured.

### Implementation with prewalk

Start a new implementation session:

```bash
omp --model @slow --prewalk-into @smol "Implement X; preserve Y; verify Z."
```

This starts on Opus 5.5 and targets Sonnet 5.5 with the current role mappings (fallbacks may
change the concrete models). Plain `omp --prewalk` instead starts on the default
GLM-5.3 model; it does **not** automatically select `@plan`, `@slow`, or `@architect`.

In an existing session, first select `/model @slow`, then run `/prewalk`, then send
the implementation request. `/prewalk` arms a one-shot handoff; it is not an
always-on mode. `/prewalk restart` returns to `@default` (GLM-5.3 here), not `@slow`.

The target inherits the conversation and todo state rather than just a prose plan.
It still incurs input processing, can re-read files, and must validate the result.
Observed on OMP 18.4.10 (not re-verified on installed 18.16.0): any successful todo operation opens the gate; the switch
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
  Its reported costs/pass rates are not measurements of our Opus/Sonnet pair.
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

The mapping references seven logins. Four are subscription logins: `anthropic`, `openai-codex`,
`google-antigravity`, `xai-oauth`. Run `omp usage` on the target machine to confirm each is logged in.
Three more were added in v37/v37.1 and **never appear in `omp usage`**:

- `mistral`: run `/login mistral` on **each** machine (the key is per machine; the plan allowance is one
  account-level pool, $150/mo Vibe Code, so load across machines adds up). It must be the Mistral
  Education/student Pro plan key. Used as `default`'s primary (v38) and for the five fallback hops
  (`smol`, `tiny`, `task`, `review`, `vision`); without it, restore the v37.2 `default` (Gemini 3.8 Flash
  primary; chain Sonnet 5.5 → Sol 6.1 → Grok Build) and delete those `mistral/*` entries before importing.
- `typesafe` (v37.1): run `/login typesafe` (API key from console.typesafe.ai; needs prepaid credit, no free
  tier). Used by the `judge` role as the primary (`typesafe/jev-1.14.0`). Without it, set `judge` to
  `openrouter/typesafe/jev-1.14` (the v37 setup) before importing.
- `openrouter`: an OpenRouter API key with prepaid credit, funded separately from TypeSafe. Since v37.1 it is
  used only for the `judge` fallbacks (Jev via OpenRouter, then Liquid d1.1); without both it and a working
  TypeSafe login, `find` stays disabled under `find.enabled: auto`.

Verify these three with `omp models mistral --json` and `omp models --kind judge --json` (see README's Verify).
Restart any running `omp` session after logging in: sessions started before the login keep their cached judge route.
