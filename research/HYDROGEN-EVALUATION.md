# Gemini 4 Hydrogen vs Gemini 3.8 Flash / 3.5 Flash-Lite — fallback-hop evaluation (2026-11-13 · v42)

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root,
one level up.*

Written 2026-11-13 for snapshot v42 (omp 18.20.0). Prompted by the Gemini 4 Hydrogen release on
2026-11-12. This evaluation combines a 5-lens online research pass (verified 2026-11-13) with a live
OMP retest on the owner's machine. **[INFERENCE]** marks anything not read directly from a source.
Raw data lived in `/tmp/omp-hydrogen-probe/`, which is temporary and not committed; every number
below is copied from it and this document stands alone.

---

## Decision

- **Adopted (v42, 2026-11-13, owner decision via form): three fallback-hop changes.**
  `retry.fallbackChains.default` hop 1: `google-antigravity/gemini-3.8-flash` ->
  `google-antigravity/gemini-4-hydrogen-high` (chain: Hydrogen high -> Sonnet 5.5; primary is still
  `mistral/zai-glm-5-3`). `retry.fallbackChains.task` hop 2: 3.8 Flash -> Hydrogen high (chain: Sol
  6.1 -> Hydrogen high -> GLM-5.3 -> Grok Build). `retry.fallbackChains.smol` hop 3:
  `google-antigravity/gemini-3.5-flash-lite` -> `google-antigravity/gemini-4-hydrogen-medium`
  (chain: GLM-5.3 Flash -> Luna -> Hydrogen medium -> Grok Build).
- **Unchanged:** `vision` primary stays 3.8 Flash (model card: multimodal unjustified refusals
  +5.57pp vs 3.8 Flash); `advisor` primary stays 3.8 Flash (advisor runtime is off,
  `advisor.enabled: false`); the 3.5 Flash-Lite hops in `tiny`, `commit`, `widget`; everything else.
- **Rule added as a YAML comment above the `default` chain:** never add `:minimal` or `:off` to
  Hydrogen ids (thinking-level hazard below).

## Question and scope

In v41 (2026-11-12) the Gemini Flash models appeared as: 3.8 Flash as the first fallback hop of
`default` and the second hop of `task`; 3.8 Flash as the `vision` primary and the `advisor` primary
(advisor runtime off); 3.5 Flash-Lite as the third hop of `smol` and a hop in `tiny`, `commit`,
`widget`. Question: is Gemini 4 Hydrogen, which Google calls the "Recommended upgrade from Gemini
3.8 Flash" (https://aistudio.google.com/docs/whats-new-gemini-4-hydrogen.md), a better occupant of
those slots? Scope is the fallback hops, not any primary, and the Antigravity subscription route
(reports $0 per call), so API pricing is context only.

Model facts. Hydrogen was released 2026-11-12. OMP selectors are
`google-antigravity/gemini-4-hydrogen-{low,medium,high,xhigh}`: 1M context, 262K max output, image
input; the thinking level is pinned by the id. It is available to paid Google AI Pro in Antigravity
(Antigravity blog https://antigravity.google/blog/gemini-4-hydrogen-in-google-antigravity; HN users on
Pro confirm); trial/Jio-bundle Pro reportedly lacks it. Google publishes no numeric quota.

## Online evidence

Verified 2026-11-13 by a 5-lens research pool, one day after launch. **Vendor-reported** rows are
marked V; the rest are independent boards or users.

| Measure | Hydrogen | 3.8 Flash | Source |
|---|---|---|---|
| Artificial Analysis Index v5.0.1 | high 51 (medium 41, low 27, xhigh 54) | 31 | AA model pages (independent) |
| 3.5 Flash-Lite, same index | | 12 (Flash-Lite) | AA |
| Terminal-Bench 4.0 (AA run) | 54% (high and xhigh) | 19.7% (medium) / 19.1% (high, tbench.ai); Flash-Lite 1.0% | AA, tbench.ai (independent) |
| Terminal-Bench 4.1 | 57% | 18.2% | Google (V) |
| TTFT (AA live page) | 16.68 s | 17.47 s | AA |
| Output speed (AA live page) | 179 tok/s | 112 tok/s | AA |
| Time per Index task (AA live page) | 7.9 min | 14.7 min | AA |
| Cost per task (AA) | $1.87 (high) | $7.77 | AA, see caveat below |
| LiveBench long-agentic | 61.8% | 16.5% | aggregated, not one head-to-head |
| Vals Index | 68.5% (xhigh) | 56.0% | aggregated |
| CursorBench | 54.3% | 39.6% | aggregated |
| Box eval | 79% in "less than half the time", ~12% fewer tokens | 74% | Box (V) |

URLs: https://artificialanalysis.ai/models/gemini-4-hydrogen-high and
https://artificialanalysis.ai/models/gemini-3-8-flash.

- **Cost per task caveat.** The $1.87 vs $7.77 figure is real on AA's page, but an AA employee on HN
  attributes it to 3.8 Flash's much lower cache hit rate
  (https://news.ycombinator.com/item?id=50475524).
- **Counterpoint.** One HN user's own eval found Hydrogen 37% more expensive per task but taking
  40-60% of the time per task (both at medium)
  (https://news.ycombinator.com/item?id=50471431).
- **Pricing (API).** Hydrogen $1.50/$7.50 per M; 3.8 Flash $0.75/$3.75 through 2026-12-31 and
  $1.50/$7.50 from 2027-01-01; 3.5 Flash-Lite $0.30/$2.50
  (https://ai.google.dev/gemini-api/docs/pricing). Not relevant to the Antigravity route.
- **Gaps.** No third-party Aider/OpenHands/Cline evals, edit-error rates, or thought-signature bug
  reports found yet (1 day after launch). OpenRouter launch-day AI Studio uptime was 92.88% (Vertex
  100%). The thought-signature contract is the same as Gemini 3 (signature on the first
  functionCall of each step in the current turn).

## OMP measurements

All runs on omp 18.20.0 with the Antigravity OAuth main account, all
`-p --auto-approve --mode json --no-lsp`. Task: "Run the failing test, fix the planted bug, then
create fizz.py with a fizzbuzz(n) function and test_fizz.py with tests for fizzbuzz(15) and
fizzbuzz(5), and run both test files." Fixture: `stats.py` with planted bug
`sum(nums)/(len(nums)+1)` in `mean`; `test_stats.py` (3/5 fail on the bug).

### Retest (2026-11-13 13:15-13:31 local) — the decision basis

Method fixes over run 1: a fresh temp dir per run; bare ids under the real config
`defaultThinkingLevel: auto` (how a fallback hop actually runs); `omp usage invalidate` before each
meter read; pass/fail scored from the transcript (last runs of both test files passed after the
final edit), because `fizzbuzz(n)` returning a list is a valid reading of the prompt.

| cell | n | tests pass | median wall (range) | median turns | median input tok (cached) | median output | median thinking | edit/write errors | incidents |
|---|---|---|---|---|---|---|---|---|---|
| Hydrogen high (auto) | 5 | 5/5 | 21.2 s (17.1-28.1) | 6 | 23,037 (45,706) | 1,374 | 477 | 0 | 0 |
| Hydrogen medium (auto) | 5 | 5/5 | 20.4 s (18.1-25.7) | 6 | 22,976 (45,535) | 1,372 | 520 | 0 | 0 |
| 3.8 Flash (auto) | 5 | 5/5 | 62.5 s (48.2-65.2) | 13 | 165,878 (0) | 3,532 | 2,441 | 0 | 0 |
| 3.8 Flash (`--thinking high`) | 3 | 3/3 | 58.7 s (50.1-67.1) | 14 | 142,602 (9,505) | 3,194 | 2,071 | 0 | 1: "Cloud Code Assist API returned an empty response" -> walked to Sonnet 5.5 mid-task |
| 3.5 Flash-Lite (auto) | 5 | 5/5 | 19.0 s (14.1-19.2) | 9 | 37,922 (80,660) | 2,661 | 1,530 | 2 | 0 |
| Handoff -> Hydrogen high | 2 | 2/2 | 11.9 s (11.5-12.4) | 3 | 16,924 (19,798) | 1,036 | 578 | 0 | 0 |
| Handoff -> 3.8 Flash | 2 | 2/2 | 41.5 s (31.9-51.2) | 8 | 104,496 (22,804) | 3,130 | 2,140 | 0 | 0 |

- Every Hydrogen run was delivered by the requested model (no silent fallback under `auto`): 12/12.
- **Handoff test.** Phase A, in a fresh dir, asked `mistral/zai-glm-5-3` to diagnose only; phase B
  ran `omp -p --continue --model <target>` to fix and build. Because Mistral returned 402 (incident
  below), phase A actually ran on 3.8 Flash via the default chain, so phase B tested Hydrogen taking
  over a session with foreign (Flash-signed + GLM error) history: no signature errors, task
  completed in 3 turns.
- **Meter** (main account, fresh reads): 5h 14.4% -> 21.1%, weekly 9.0% -> 10.8% over the whole
  retest. Per-block deltas were noisy (the rolling windows even dropped between two blocks), so
  per-model quota cost is **not measured**. Directionally 3.8 Flash's blocks moved the weekly meter
  more (+1.1 for 5 Flash runs vs +0.4 / +0.0 for 5 Hydrogen high / medium runs), consistent with ~7x
  the uncached input tokens. Indicative only.
- **Versus run 1:** isolated dirs removed the agent wandering into harness files; Flash high
  92.8 s -> 58.7 s; Hydrogen high 27.8 s -> 21.2 s. Hydrogen high stays roughly 3x faster on wall
  time (3.3x in run 1, 2.8-2.9x in the retest against Flash high/auto), in line with the
  third-party "40-60% of the time per task" and Google's "2-2.8x faster".

### Run 1 (2026-11-13 morning) — superseded, kept for the record

- Flawed method: shared fixture dir; agents sometimes read the harness scripts; a duplicate driver
  raced on the fixture for some runs; meter readings were cached (not refreshed). **The earlier
  claim "Hydrogen uses ~4.8x less quota" is WITHDRAWN.**
- Pinned levels: Hydrogen high 27.8 s median (3/3), medium 23.9 s (3/3), low 15.3 s (2/2), 6 turns;
  3.8 Flash `--thinking high` 92.8 s median, 24 turns (vs 34.6 s on the 2026-11-03 baseline:
  environment drift); 3.8 Flash `--thinking low` 25.1 s.
- **G1 thinking-control gate:** `--thinking minimal` and `--thinking off` on
  `gemini-4-hydrogen-high` silently walked the default chain to 3.8 Flash (which then answered a
  puzzle wrongly: 400 vs correct 401); `--thinking high` on `-low` and `--thinking low` on `-high`
  stayed on the pinned model and answered correctly (~4.6 s).
- **Vision set** (6 synthetic-real images: terminal traceback, dark-theme code, settings UI, bar
  chart, 10x5 number table, abstention scene with no text; answer keys written before any call) plus
  legacy `shapes.png`: 3.8 Flash and Hydrogen low/medium/high all answered every item correctly (the
  chart value is unanswerable by design for all: no y-axis scale) and all abstained correctly on the
  no-text image. Latency ~4-6 s for all. 3.8 Flash used 0 thinking tokens and 8-69 output tokens;
  Hydrogen 33-259 thinking tokens and 90-292 output tokens per image.

## Thinking-level hazard

Google's thinking levels for Hydrogen are low, medium, high (default) and xhigh. `minimal` is
rejected with HTTP 400 and there is no off (Google docs; Vertex model page). OMP 18.20.0's catalog
nevertheless lists `minimal,low,medium,high` for the Hydrogen ids. Observed consequence (G1 gate
above): a request with `minimal` or `off` is rejected and OMP's retry chain silently walks to the
next hop, here 3.8 Flash, so the user believes they are on Hydrogen and are not. The OMP catalog
`minimal` mislabel is not fixed upstream.

- **Rule:** never add `:minimal` or `:off` to Hydrogen ids. Ids stay bare (`...-high`, `...-medium`);
  the level is pinned by the id.
- Under `defaultThinkingLevel: auto`, Hydrogen stayed on Hydrogen in 12/12 retest runs, so the bare
  ids used in the chains are safe.

## Decision per role

- **`default` (hop 1 -> Hydrogen high).** 5/5 pass at 21.2 s median vs 62.5 s for 3.8 Flash on the
  same task (13 turns vs 6, 165,878 uncached input tokens vs 23,037), AA Index 51 vs 31, Terminal-
  Bench 54% vs 19.7%. Handoff into a foreign-signed session worked (2/2, no signature errors). Sonnet
  5.5 stays the last hop (owner priority from `DEFAULT-ROLE-EVALUATION.md`). Primary is unchanged.
- **`task` (hop 2 -> Hydrogen high).** Same evidence: agentic tool work, where the speed and turn
  count advantage is largest.
- **`smol` (hop 3 -> Hydrogen medium).** Hydrogen medium matches high on the retest (5/5, 20.4 s,
  6 turns, 0 edit errors), AA Index 41 vs 12 for 3.5 Flash-Lite. 3.5 Flash-Lite passed 5/5 at
  19.0 s but with 9 turns and 2 edit/write errors. Medium rather than high is a choice to keep the
  third hop lighter **[INFERENCE]**; its quota effect is unmeasured.
- **`vision` (unchanged, 3.8 Flash).** Model card: multimodal unjustified refusals +5.57pp vs 3.8
  Flash (regression). The vision set did not separate the models (all correct), so there is no
  measured gain to offset the regression.
- **`advisor` (unchanged, 3.8 Flash).** Advisor runtime is off (`advisor.enabled: false`); no change
  is worth making to an inactive role.
- **`tiny`, `commit`, `widget` (unchanged, 3.5 Flash-Lite hops).** Not tested for these roles; the
  retest was a coding-task test. They stay as they were.

## Risks

- **Short-term GA.** Vertex lists Hydrogen as a "short-term generally available (GA) release
  subject to a minimum 45-day retirement notice policy" — much shorter than 3.8 Flash (Vertex:
  retirement Sept 2, 2027 or later; Gemini API: no shutdown date) and 3.5 Flash-Lite (Vertex: July
  21, 2027 or later). Mitigation: on retirement the hop errors and the chain walks to the next
  entry; re-check the OMP catalog for the Hydrogen ids on each snapshot.
- **Launch-week non-stationarity.** All data is from the day after launch and may change.
  OpenRouter launch-day AI Studio uptime was 92.88% (Vertex 100%). Run 1 vs
  the 2026-11-03 baseline already showed environment drift for 3.8 Flash (92.8 s vs 34.6 s).
- **Multimodal over-refusal.** Model card +5.57pp unjustified refusals vs 3.8 Flash. This is why
  `vision` was not moved. The `default`/`task`/`smol` hops can still receive image input
  **[INFERENCE]**.
- **Quota cost unmeasured.** Whether Hydrogen shares the "Gemini" weekly/5h bucket with 3.8 Flash
  is unverified (`omp usage` shows only "Gemini (Weekly)", "Gemini (5 Hour)", and a separate
  "Gemini (Argon)" bucket). Per-model quota cost is not measured (see Meter above).
- **Access.** Trial/Jio-bundle Pro reportedly lacks Hydrogen; the owner's main account has it.
  Another account without it would fail the hop and walk on **[INFERENCE]**.

## Incident found during the retest (not a config change)

- Every `mistral/zai-glm-5-3` call on 2026-11-13 returned
  `402 Vibe budget exhausted. (type=billing_vibe_budget_exhausted)`; OMP's `retry_fallback_applied`
  walked `default` to its first hop.
- Until the Mistral allowance resets on 2026-12-01, the `default` role effectively runs on its first
  fallback hop: Hydrogen high after v42 (3.8 Flash before).
- This Mac's recorded Mistral spend for November is only $11.90
  (`scripts/omp-spend.sh mistral 2026-11-01`), so most of the $150 Vibe Code allowance was used
  elsewhere (Ubuntu server, omarchy, or the Mistral Vibe CLI) **[INFERENCE]**; check
  admin.mistral.ai.
- The GLM hops in smol/tiny/task/review/vision chains also fail fast with 402 until then.

## Not measured / limits

- n=5 per cell (n=2 or 3 in some) on one small tool task; launch-week behaviour may change.
- Per-model quota cost is unresolved; meter data is indicative only.
- No Hydrogen vision change was made; the vision set had 6 images plus `shapes.png`.
- `tiny`, `commit`, `widget` roles and long-session quality were not tested.
- The OMP catalog `minimal` mislabel is not fixed upstream.

## Live apply (2026-11-13, owner's Mac)

- Applied with `omp config set` from `model-roles.yml`. `scripts/check-live.sh` needs ruby, which is
  not installed there, so the same 11-key comparison ran in Python: all keys OK.
- That machine had never applied v41: live `modelRoles` lacked `image` and `generate_image.enabled`
  was false; both were set to the v41 values in the same apply.
- Smoke test: `omp -p --no-session --no-tools "Reply with exactly: ok"` on the `default` role logged
  `retry_fallback_applied` from `mistral/zai-glm-5-3:low` (402) to
  `google-antigravity/gemini-4-hydrogen-high` and answered on `gemini-4-hydrogen-high:high` in 6.3 s;
  the `auto` classifier's `low` did not override the pinned id.

## How to revert

Edit `model-roles.yml` (and the live config) and restore the three entries:

1. `retry.fallbackChains.default` hop 1: `google-antigravity/gemini-4-hydrogen-high` ->
   `google-antigravity/gemini-3.8-flash`.
2. `retry.fallbackChains.task` hop 2: `google-antigravity/gemini-4-hydrogen-high` ->
   `google-antigravity/gemini-3.8-flash`.
3. `retry.fallbackChains.smol` hop 3: `google-antigravity/gemini-4-hydrogen-medium` ->
   `google-antigravity/gemini-3.5-flash-lite`.

Remove the YAML comment above the `default` chain about `:minimal`/`:off` if Hydrogen is no longer
referenced. Nothing else changed in v42.
