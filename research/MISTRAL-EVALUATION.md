# Mistral (EDU plan) adoption and judge-role regression — v37 evaluation

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root,
one level up.*

Written 2026-11-03 for snapshot v37 (omp 18.16.0). Prompted by a new `mistral` login — the owner's
Mistral Education plan, about $5/month by the owner's account — and a judge-role regression found
in the same pass. Unlike `META-MUSE-EVALUATION.md`, **this evaluation ran the models**: live OMP
probes, a Mistral account check, public benchmarks. It did **not** measure quota consumption or
review precision (see risks).

**Terminology.** This repo uses "Vibe" for OMP's good/fast worker tiers. "Mistral Vibe" and
"Mistral Vibe CLI" here always mean Mistral's coding product and its plan budget.

Evidence reports lived in `/tmp/omp-mistral-research/` (plan/billing, benchmarks, live OMP tests,
judge, methodology critic). That scratch tree is not committed; every number below is copied from
those reports and attributed to its source.

---

## Decision

- **Adopted (v37): four fallback-only hops, one `mistral/*` entry per chain, no primaries** (except the
  v38 default, below).
  `smol` and `tiny`: `mistral/zai-glm-5-3-flash` ahead of Luna. `task` and `review`:
  `mistral/zai-glm-5-3` as third hop (before Grok Build; before same-family Antigravity Opus).
- **Adopted (v37.2, 2026-11-03, owner decision): a fifth hop, `vision`.** `mistral/mistral-large-4`
  after Sol 6.1, before Grok 4.7 (chain: Sonnet 5.5 -> Sol 6.1 -> Large 4 -> Grok 4.7). Still one
  `mistral/*` entry per chain, fallback-only.
- **Adopted (v38, 2026-11-03, owner decision): the sole Mistral primary.** `modelRoles.default` ->
  `mistral/zai-glm-5-3`; `default` chain -> `google-antigravity/gemini-3.8-flash` ->
  `anthropic/claude-sonnet-5-5`. Details and evidence: [DEFAULT-ROLE-EVALUATION.md](DEFAULT-ROLE-EVALUATION.md).
  Still one `mistral/*` entry per chain (the primary is the entry; the `default` chain holds none).
- **Why bounded.** Bounded monthly pool ($150/mo Vibe Code, resets 1st of calendar month, PAYG off), unmetered in OMP, shared with the owner's own Mistral Vibe
  CLI use (and, from v38, the default role). `retry.usageAwareFallback` excludes ordinary API keys, so it is an error-driven hop only.
- **Not adopted:** DeepSeek V4.1 Flash 1017, Medium 3.5, Small 4, Ministral, every alias id. No
  Mistral model in `critical`, `slow`/`plan`/`security`, `sage`, `judge`, or as any primary except the
  v38 `default`. (Large 4 was on this list in v37; v37.2 adopted it as the late `vision` hop only.)
- **Judge fix (independent of Mistral).** v37: `judge` -> `openrouter/typesafe/jev-1.14`, chain
  `openrouter/typesafe/jev-1.13` -> `openrouter/liquid/d1.1`; v37.1 (after a TypeSafe login):
  `typesafe/jev-1.14.0` direct with `openrouter/typesafe/jev-1.14` -> `openrouter/typesafe/jev-1.13` ->
  `openrouter/liquid/d1.1` as fallbacks. v36's TypeSafe primary had no credential; `find`, auto-prewalk
  and smart autoGraph were silently off since 2026-10-28.

## Subscription facts

Observed 2026-11-03. **[INFERENCE]** marks anything not read directly from a source.

| Item | Fact | Source |
|---|---|---|
| Plan | "The Education plan is the Pro plan with a discount" for verified students/teachers; institutional email required | https://help.mistral.ai/en/articles/698530 (2026-08-12) |
| Price | **$5.99/mo** (normally $14.99, excl. tax), **max 12 months**, only students at accredited higher-ed who have not used Vibe/Le Chat before; renewal price not stated. Owner says about $5/mo, about $50-70/yr (unverified). Refund only within 14 days | https://mistral.ai/pricing (`data-prices` 5.99); https://help.mistral.ai/en/articles/455205 |
| Included | Mistral Vibe CLI/IDE/web ("All-day coding in the CLI, IDE, or on web"), more messages/searches, **"$15 /mo in API credits"** | mistral.ai/pricing raw HTML |
| Allowance | "Monthly usage … **shared across Studio, the API, and Vibe Code**." Size **unpublished** ("fair usage limits"); no per-model weighting documented, overage "at API rate". **[INFERENCE]** the $15 line is the allowance in API-priced dollars (v37 reading; superseded by v38 correction below: $150 Vibe Code + $15 API) | https://docs.mistral.ai/admin/billing-usage/subscriptions ; https://docs.mistral.ai/vibe/code/cli/api-keys-profiles |
| Reset | **Monthly (billing period)**; "can stop working until the next billing period". No 5h/weekly windows documented (v37 reading; superseded by v38 correction below: reset 1st of calendar month) | https://help.mistral.ai/en/articles/698531 |
| Exhausted | PAYG off (default): Mistral Vibe stops until next period. PAYG on: prepaid credits, then **HTTP 402**; partner-bought Pro (Google, Apple, Free Mobile, Orange) cannot enable PAYG. Error shape seen: `402 {"code":"2304","type":"billing_vibe_budget_exhausted"}` (Free plan, vibe-type key; not reproduced here) | https://docs.mistral.ai/admin/billing-usage/billing ; https://github.com/mistralai/mistral-vibe/issues/1362 |
| Key scope | OMP's key is a **"vibe" plan key**: whoami `plan_type:"CHAT"`, `plan_name:"EDU"`, `primitive_access_scope:"personal_and_shared"`; Mistral Vibe maps `CHAT -> "vibe"` | Mistral Vibe CLI 3.0.4: `vibe/setup/auth/whoami.py`, `vibe/app_server/_account.py:56-61` |
| Billing route | A vibe-type key bills the **plan's Mistral Vibe budget**, not PAYG credits or the Free tier. OMP: "usage counts against the plan's Vibe Code quota instead of pay-as-you-go API credits". An OMP-extension author claims 12 requests / 46k completion tokens moved only the "Vibe Code" counter (author's claim) | issue #1362; help 698531 FAQ; `omp://providers.md`; https://github.com/Gauthier-Huguenin/omp-mistral-subscription |
| How identified | `GET https://console.mistral.ai/api/vibe/whoami` with the key (200). Mistral Vibe's cache key is `sha256(key)[:32]`; OMP's key hashes to `bb5cffee…`, the **EDU** entry in `~/.vibe/whoami_cache.json` (the FREE entry `dfc84bad…` is a different key). OMP's DB row: `source=login`, created 2026-11-03 | live check; `vibe/core/experiments/manager.py:13-15` |
| `has_paid_vibe_entitlement:false` | **Client default** (`whoami.py:64`), not in the raw payload; Mistral Vibe treats EDU as paid (`_PAID_CHAT_PLANS`); it only suppresses an upgrade nag. Does not mean "no Mistral Vibe on EDU" | reproduced in Mistral Vibe's venv |
| Mistral Vibe on EDU | Yes, by indirect evidence: EDU = Pro; Pro card says "Full access to Vibe"; the EDU account's `vibe_cli_extra_models` lists Large 4, GLM-5.3, GLM-5.3 Flash (FREE account: `{}`); Mistral Vibe maintainer: Large 4 needs "the Pro plan" (#1366). Counter not observed | mistral.ai/pricing; `~/.vibe/experiment_eval_cache.json` |
| Meter | **Console UI only**: https://console.mistral.ai/codestral/cli ("View organization usage"); https://admin.mistral.ai/organization/usage; https://admin.mistral.ai/subscription (plan, usage, PAYG toggle); https://admin.mistral.ai/plateforme/limits. No usable API: `console.mistral.ai/api/vibe/{usage,quota,entitlements,account}` -> 401, `api.mistral.ai/v1/{usage,billing}` -> 404, Admin API Enterprise-only; Mistral Vibe CLI has no usage command (#1366) | live probes |
| Training | Pro row "Model training: Opt-out"; plan key under consumer terms (legal.mistral.ai/terms). **[INFERENCE]** same for EDU | mistral.ai/pricing |

**v38 correction (owner screenshot of admin.mistral.ai/subscription, 2026-11-03 12:26).** The page shows
plan "Education — Pro plan with student discount" (Active) and **two separate included monthly
allowances**, each reset on the first day of each calendar month, independently of the subscription
renewal: **Included API usage (API/Studio) $0 used of $15** and **Included Vibe Code usage $5.35 used of
$150**. Pay-as-you-go for the API and for Vibe Code both show an "Enable" button, i.e. both off.
**[INFERENCE]** OMP's `/login mistral` key is a vibe-scope plan key and draws the **$150 Vibe Code**
allowance, not the $15 API allowance: API usage read $0 after a day of OMP calls through that key; the
$5.35 includes that day's OMP research probes plus any Mistral Vibe CLI use. v37 had inferred "$15/mo"
from the pricing card's API-credit line; that figure and the "Reset: monthly (billing period)" row above
are the v37 reading, superseded by this page. Where this document says "~$15/mo" below, it is that v37
inference unless it cites the v38 correction.

**Source conflict.** The 2026-08-12 help article says "API rate limits are not the same as your
Vibe plan budget"; the undated docs say one pool is shared by Studio, API and Vibe Code. Issue
#1362 shows the key type decides which pool is hit — consistent with the plan-key route.

**Shared with Mistral Vibe CLI.** The owner's Mistral Vibe CLI draws the same budget. Its default
here is GLM-5.3 (GrowthBook `vibe_cli_default_routing_model` = `glm-5-3`, experiment
`ml408-rollout-default-cli-ab-test`, announced 2026-09-21); Large 4 and GLM-5.3 Flash are extras.
**[INFERENCE]** Large 4 is the likely next default.

**What $15 would have bought at API prices — [INFERENCE], scale only, v37 figure now superseded (the
Vibe Code allowance is $150, so multiply by 10)** (docs.mistral.ai/inference/pricing;
judge-size call = 4k in/300 out; agent session = 200k in, 80% cached, 12k out): `zai-glm-5-3`
($1.4/$0.14/$4.4 per M in/cached/out) about 2.2k calls or 114 sessions; `mistral-large-4`
($0.7/$0.07/$2.1) about 4.4k / 233; `deepseek-v4-1-flash-1017` ($0.3/$0.007/$1.2) about 9.6k / 545;
`zai-glm-5-3-flash` ($0.15/$0.03/$0.5) about 20k / 893.

## Model inventory

Live `GET /v1/models` with the key plus OMP's catalog (`omp models mistral --json`).

| Selector | Status | Context / max out (OMP) | Vision (OMP) | Note |
|---|---|---|---|---|
| `mistral/zai-glm-5-3` | GA (hosted 2026-09-15) | 1,048,576 / 131,072 | no | MoE ~753B/40B (AA), MIT; always reasons |
| `mistral/zai-glm-5-3-flash` | GA (hosted 2026-10-22) | 1,048,576 / 131,072 | **yes** | MoE 320B/18B (Mistral docs), MIT; always reasons |
| `mistral/deepseek-v4-1-flash-1017` | **Public Preview** (2026-10-28) | 1,048,576 / 128,000 | no; **API caps, Mistral docs, HF card say yes** | catalog wrong on vision |
| `mistral/mistral-large-4` | **Public Preview** | 1,048,576 / 262,144 | yes | docs $0.7/$2.1; OMP catalog $1.36/$4.18 |
| `mistral/mistral-medium-latest` | **Deprecated 2026-10-31**; live `deprecation` still `null` | 262,144 / 262,144 | yes | aliases Medium 3.5 |
| `mistral/mistral-small-2603` | GA | 262,144 / 256,000 | yes | Small 4 |
| `ministral-{3b,8b,14b}-2512`, `codestral-2508` | GA | 256K (3B: API 131K); codestral 8K out | yes; codestral no | weak / FIM |

Catalog gaps and traps:

- **Alias ids have no metadata**: `mistral-medium-3.5`, `zai-glm-5`, `mistral-vibe-cli-*` resolve with
  `reasoning:false`, `input:["text"]`, `contextWindow:null`, `maxTokens:null`, cost 0 (RPC
  `get_state`). No thinking control, no cost accounting, and a null window likely affects
  compaction/usage display **[INFERENCE: not exercised]**. The medium-3.5 alias got the sheep puzzle
  wrong because it never reasoned. Use canonical ids only.
- `mistral-large-4-0` has null max-output; `mistral-large-4-0-8` is in the catalog but not live.
  OMP passes images to text-only-flagged models without warning.
- Live `/v1/models` has no Devstral; Medium 3.5 is absent from Mistral's API price table (Kunavo:
  $1.5/$0.15/$7.5); Magistral/Devstral retired; Leanstral 1.5 deprecated 2026-09-29, alias live.
- API rate limits seen with the key (tokens/min, req/min; **not plan quota**): ministral-3b 4M/6000,
  -8b 2M/1500, -14b 3M/240, codestral 2M/1000, mistral-large-2512 800K/**30**, deepseek-flash
  10M/1333, small 500K/1000. GLM limits not probed.
- No `models-overlay.yml` override appears needed (all chosen maxTokens >= 128K). **[INFERENCE]**

## Capability comparison

Artificial Analysis (AA) v5.0, independent, one harness (mini-swe-agent for Terminal-Bench 4.0).
Effort level in parentheses. Index v5 launched 2026-10-27; AA's v4.1.1 figures (e.g. z.ai's "57" for
GLM-5.3 Flash) are not comparable.

| Model | AA Index | Terminal-Bench 4.0 | FrontierCode 2.0 | Omniscience net | $/M in / out |
|---|---|---|---|---|---|
| **Mistral-accessible** | | | | | |
| GLM-5.3 (max) | 31.7 (low 23.1) | **41.9%** (low 34.8) | 21.6% | +6.0 | 1.4 / 4.4 |
| GLM-5.3 Flash | 27.8 | 32.8% | 17.6% | +0.7 | 0.15 / 0.5 |
| DeepSeek V4.1 Flash 1017 (max) | 32.5 (high 28.5; non-reasoning 18.5) | 33.8% (high 28.8) | 28.5% | +0.9 | 0.3 / 1.2 |
| Mistral Large 4 (high) | 26.0 (medium 23.1) | 24.7% (medium 23.2) | 15.0% | +5.1 | 0.7 / 2.1 |
| Mistral Medium 3.5 | not indexed | **0.0%** | unknown | -38.7 | 1.5 / 7.5 |
| Mistral Small 4 | 4.3 | 0.0% | 0.0% | -31.0 | 0.15 / 0.6 |
| **Current OMP role models** (high / max) | | | | | |
| Claude Opus 5.5 | 51.7 / 58.4 | 56.6 / 59.6 | 35.9 / 46.4 | +48.1 | 4 / 20 |
| GPT-6.1 Sol | 50.2 / 54.5 | 51.5 / 56.1 | 36.7 / 40.6 | +42.0 | 2 / 10 |
| Gemini 4 Argon (high) | 50.4 | 57.1 | 25.7 | +46.1 | AA 4 / 20 (OMP 2 / 10) |
| Claude Sonnet 5.5 | 41.1 / 54.2 | 43.9 / 63.6 | 25.7 / 41.7 | +30.5 | 2 / 10 |
| Grok 4.7 (xhigh) | 35.3 | 25.8 | 28.7 | +31.2 | 2 / 6 |
| Gemini 3.8 Flash (high) | 30.5 | 19.7 | 18.7 | +23.3 | 0.75 / 3.75 |
| GPT-6 Luna | 21.4 / 27.8 | 4.5 / 12.6 | 18.6 / 25.2 | -8.3 | 0.1 / 0.5 |
| Claude Haiku 5.5 `:low` (max) | 18.6 (36.2) | 12.6 (32.8) | 8.0 (34.9) | +12.3 | 0.1 / 0.5 |
| Gemini 3.5 Flash-Lite | 11.7 | 1.0 | 6.0 | +6.9 | 0.3 / 2.5 |

Grok Build 0.1 and Composer 2.5 Fast are not on the v5.0 index.

- **No Mistral-accessible model is near the depth tier** (Opus 58.4, Sol 54.5, Argon 50.4); the best
  (DS Flash 32.5, GLM-5.3 31.7) sit at Gemini 3.8 Flash / Grok 4.7 level.
- **Effort caveat.** Luna is 21.4 at high but 27.8 at max, tying GLM-5.3 Flash's 27.8 (AA's effort
  for that figure is not stated). The discriminator is Terminal-Bench 4.0: Flash 32.8% vs Luna
  4.5% / 12.6%.
- **GLM-5.3 holds across harnesses** (41.9% mini-swe-agent, 41.8% Claude Code, 39.9% Opencode).
  **Large 4's 41% is Mistral-Vibe-only** (Mistral Vibe 41.4% vs AA 24.7% vs Vals 26.3%);
  **[INFERENCE]** expect about 25% in OMP.
- **Counter-evidence**, neutral DeepSWE v1.1 board (deepswe.datacurve.ai, 2026-09-22): Gemini 3.8
  Flash (high) 74% ($2.36/task) beats GLM-5.3 (max) 69% ($3.99) and GLM-5.3 Flash 63% ($0.24).
  GLM-5.3 follows Gemini 3.8 Flash in `task` anyway.
- **Vendor figures, not independent:** Medium 3.5 SWE-bench Verified 77.6%; Large 4 FrontierCode
  19.7% (Cognition private set); GLM-5.3 HF DeepSWE 66.9; DS 1017 HF Terminal-Bench 4.0 42.3.
  SWE-bench Verified/Pro for the other models: unknown.
- LMArena text (BenchLeader, 2026-10-28): GLM-5.3 1481 (#28), GLM-5.3 Flash 1477 (#33), Large 4
  1432 (#110) vs Argon 1520 (#2), Opus 1509 (#3), Sol 1481 (#27), Luna 1441 (#96). AA speeds are
  from other hosts; Mistral is not an AA-benchmarked provider for these models.

## OMP live probe matrix

omp 18.16.0, 2026-11-03, fresh copy of a planted-bug fixture per run. Commands:

```text
omp -p --no-session --auto-approve --mode json --model mistral/<id> --thinking <lvl> "<prompt>"
omp ... --thinking low "Describe this image briefly: shapes, colors, any text." @shapes.png   # c
omp -p --no-tools --no-session ... --thinking low "Write a conventional-commit message ... <diff>"  # d
echo '{"type":"get_state"}' | omp --mode rpc --no-session --model <sel>                    # metadata
```

Tests: **a** sheep puzzle (answer 18), low/high; **p** integers 1..1000 divisible by 3 or 5 but not
15 (answer 401), low/high; **b** bash/read/edit/write task at medium — run the failing test, fix
the planted `/(len(nums)+1)` bug, create and run `fizz.py` + `test_fizz.py` (every PASS re-verified
afterwards); **c** image; **d** commit message from a diff.

| Model | a. sheep | p. "401" low/high | b. tool task | c. image | d. commit msg |
|---|---|---|---|---|---|
| `zai-glm-5-3` | 18/18 | 401/401 | PASS, 10 turns, 13.8 s, **0 edit errors** (3 self-fixed asserts in its own test) | n/a (text-only) | PASS; body invents "Store per-entry expires_at" |
| `zai-glm-5-3-flash` | 18/18 | 401/401 | PASS, 6 turns, 8.2 s, **0** | PASS ("HELLO7") | PASS |
| `mistral-large-4` | 18/18 | 401/401 | PASS, 5 turns, 10.8 s, **0** | PASS | PASS, best text |
| `mistral-medium-latest` | 18, **16 (wrong)**, then 18, 18 | 401/401 | PASS, 9 turns, 13.3 s, **3 of 4 edits malformed** | PASS | PASS but `feat:`, 5.3 s |
| `mistral-small-2603` | 18/18 | 401, **467 (wrong)** | PASS, 8 turns, 11.6 s, 0 | PASS, misread "HELLO?" | PASS |
| `deepseek-v4-1-flash-1017` | 18/18 | 401/401 | PASS, 4 turns, 5.7 s (fastest), 0 | n/a | PASS, flagged missing `import time`; once emitted thinking-only turns OMP auto-continued |
| `ministral-14b-2512` | 4/4 (wrong, no reasoning) | 401/401 | **FAIL (quality)**: 56 turns, 114.8 s, **47 of 47 edits failed**; finished via `write` | PASS (text slightly off) | PASS, `feat(cache)` |
| `mistral-medium-3.5` alias | 14 (wrong; never reasons) | not run | PASS, sloppy: 14 turns, 18.6 s, **6 of 7 edits failed** | PASS | PASS, bare subject |
| `zai-glm-5` alias | 18 | not run | PASS, 6 turns, 6.2 s, 0 | odd: used `eval` to analyse pixels, 3 turns, 56.8 s, 14.5K output tokens | PASS, 7.7 s, 2K output tokens |

All nine runs repaired the planted bug. Samples are n=1 to 3 per cell: directional only.

| Model | median TTFT | decode tok/s (turns >= 80 out tokens) | test b wall | tiny-prompt wall |
|---|---|---|---|---|
| `deepseek-v4-1-flash-1017` | 0.75 s | ~500 | 5.7 s | 1.2-2.2 s |
| `zai-glm-5-3` | 0.69 s | ~370 | 13.8 s | 1.3-2.6 s |
| `zai-glm-5-3-flash` | 1.0 s | ~315 | 8.2 s | 1.3-2.4 s |
| `mistral-medium-latest` | 0.73 s (p90 2.5 s) | ~218 | 13.3 s | 2.9-6.0 s |
| `mistral-small-2603` | 1.0 s | ~195 | 11.6 s | 2.0-5.4 s |
| `mistral-large-4` | 1.07 s | ~191 | 10.8 s | 1.8-3.7 s |
| `ministral-14b-2512` | 0.79 s | ~67 (n=3) | 114.8 s (looping) | 1.3-2.6 s |

- The first request carries about 8.2K input tokens of OMP system prompt; caching works afterwards.
  OMP's `model_perf` shows lower tok/s (GLM-5.3: 1511 tok / 17177 ms = 88), apparently counting TTFT
  in `gen_ms` **[INFERENCE]**.
- Spend at list price: under $0.30 total (about $0.08 `medium-latest`, $0.04 `glm-5-3`, under $0.01
  each for `glm-5-3-flash` and `small`). How the plan quota is charged is not observed. No Mistral,
  zai, ministral or deepseek warnings in `~/.omp/logs` from these runs.
- **Thinking.** OMP accepted `minimal` through `max` on every model without error (`ministral-14b`
  ignores it); reasoning blocks return (`thinkingSignature: "mistral-content-parts"`). The level is
  a weak hint: thinking characters on test p (low / high) GLM-5.3 68 / 110, medium-latest 1034 / 1574,
  small 1889 / 600, Large 4 255 / 616 **[INFERENCE on cause]**. **`--thinking off` on `zai-glm-5-3`
  still reasoned (42 chars) and answered 403**: the compat block has
  `reasoningDisableMode: 'lowest-effort'`, so "off" sends the lowest effort rather than disabling.
  GLM cannot be switched to non-reasoning via OMP's `off`.
- **Edit tool.** Hashline format (`PUT N.=M:`). Non-flagship Mistral models fail it (ministral-14b
  47/47, medium-latest 3/4, medium-3.5 alias 6/7), e.g. `Got "PUT 6:=6:"`; every other model had 0
  edit errors. Model-side syntax slop that OMP surfaces cleanly **[INFERENCE on cause]**.
- Tool smoke test (n=1): all ten models emitted two parallel tool calls with valid JSON and
  completed a result round trip.

## Role fit and the chosen v37 hops

| Role | Verdict | Reason |
|---|---|---|
| `smol` | **Adopted, hop 1: `zai-glm-5-3-flash`** | Sonnet 5.5 primary; Luna was hop 1 on the Plus 7d meter (78% used 2026-11-03). Flash: AA 27.8 vs Luna 21.4 (high), Terminal-Bench 4.0 32.8% vs 4.5%, vision, 1M context, $0.15/$0.5, 0 edit errors, 6 turns / 8.2 s in the tool probe |
| `tiny` | **Adopted, hop 1: `zai-glm-5-3-flash`** | Same reason; 1.3-2.4 s on tiny prompts. Always-on reasoning is over-capable but measured fast |
| `task` | **Adopted, hop 3: `zai-glm-5-3`** | After Sol and Gemini 3.8 Flash, before Grok Build. Terminal-Bench 4.0 41.9% vs 19.7%; 0 edit errors; 1M context; text-only; $1.4/$4.4 |
| `review` | **Adopted, hop 3: `zai-glm-5-3`** | Producers are mostly Claude; the last hop was same-family Antigravity Opus. GLM is a cross-family independent reviewer, non-blocking. Antigravity's Claude/GPT weekly pool is at 92.9%, inside the 10% usage reserve, so the Opus hop is effectively dead now **[INFERENCE]** and this hop is more likely the live last stop |
| `commit`, `widget`, `advisor` | No change | `commit` is infrequent (no quota relief); `advisor` reads the whole main conversation against an unknown budget; widget chain-walking unverified since OMP 18.13.2 |
| `vision` | v37: No Mistral hop. **v37.2: adopted, hop 3: `mistral-large-4`** | v37 rationale: Flash and Large 4 passed the image probe (Large 4 best) but no data against the repo's vision A/B bar. v37.2 (owner decision): after Sonnet 5.5 and Sol 6.1, before Grok 4.7, so it runs only when Gemini 3.8 Flash, Sonnet and Sol all fail. Cleanest OMP tool run (5 turns, 10.8 s, 0 edit errors), read the probe image correctly (best vision result of the Mistral models), 1M context, image input, catalog maxTokens 262,144. Caveats: public preview; AA 26.0; Terminal-Bench 4.0 24.7% neutral vs 41% in Mistral's own harness; OMP catalog $1.36/$4.18 vs Mistral's $0.70/$2.10; draws the EDU allowance |
| `default` | v37: No. **v38 (owner decision): adopted as the sole Mistral primary** (`zai-glm-5-3`) | v37 rationale: fires every turn; no usage-aware safety net. v38: see `research/DEFAULT-ROLE-EVALUATION.md`; draws the $150/mo Vibe Code allowance, chain walks to Gemini 3.8 Flash on HTTP 402 |
| `slow`, `plan`, `security` | No | AA <= 32 vs the 50+ depth tier; v34 principle is frontier depth |
| `critical` | No | Omniscience +6.0 (GLM-5.3) vs Sol +42.0 / Argon +46.1; a weaker concrete-model-different model can mint `INDEPENDENT` and `GO` |
| `sage` | No | GLM-5.3 arena #28 vs Opus 5.5 #3; Fable model-level chains own failover |
| `judge` | No | Mistral has no native judgment (System One/Decisions) endpoint. `mistral-small-2603` works as a prompted judge but is about 3x slower than native jev (5.7 s vs 1.8 s per `find`); `ministral-8b-2512` fails the batched answer format |

| Chain | v36 | v37 |
|---|---|---|
| `smol` | Luna -> Flash-Lite -> Grok Build | **GLM-5.3 Flash** -> Luna -> Flash-Lite -> Grok Build |
| `tiny` | Luna -> Flash-Lite -> Composer | **GLM-5.3 Flash** -> Luna -> Flash-Lite -> Composer |
| `task` | Sol -> Gemini 3.8 Flash -> Grok Build | Sol -> Gemini 3.8 Flash -> **GLM-5.3** -> Grok Build |
| `review` | Argon -> Grok 4.7 -> Antigravity Opus | Argon -> Grok 4.7 -> **GLM-5.3** -> Antigravity Opus |

Rules applied: one `mistral/*` entry per chain (same routing provider = same pool); fallback-only;
hosted GLM is a third-party model family behind a Mistral route, so record provider (`mistral`) and
family (GLM) when judging independence.

v37.2 adds one row: `vision` Sonnet 5.5 -> Sol 6.1 -> Grok 4.7 (v37.1) becomes Sonnet 5.5 -> Sol 6.1 ->
**Large 4** -> Grok 4.7. Mistral now appears in five fallback chains plus the `default` primary (v38): `smol`, `tiny`, `task`, `review`, `vision`.

**What v37 does not fix.** The `smol`/`tiny` hops relieve Plus only when those roles fall through
from Anthropic; Plus primaries (`review`, `critical` on Sol) are untouched. This Mac's 29 session
files from the last 7 days show little Plus use (Sol: 59 assistant messages, at most about 3.7M
tokens; upper bound), so the source of the 78% reading is unexplained here — **[INFERENCE]**
another machine or non-OMP use. Measure over a full reset cycle before widening Mistral.

## Not adopted

| Model | Why not |
|---|---|
| `mistral-large-4` | **Adopted in v37.2 as the late `vision` hop only** (see role-fit table); still not adopted anywhere else. Public preview. AA 26.0; Terminal-Bench 4.0 24.7% in a generic harness vs 41% in Mistral Vibe's own; about 2x DS Flash's price. Best vision, cleanest tool run (5 turns, 0 errors) and best commit text, so outside `vision` it stays **explicit `/model` use only** |
| `deepseek-v4-1-flash-1017` | Public preview. Strong AA 32.5 / FrontierCode 28.5 / $0.3/$1.2, fastest (5.7 s), but thinking-only turns OMP had to auto-continue; catalog mislabels vision; plan-meter effect unverified |
| `mistral-medium-3.5` / `-latest` | Deprecated 2026-10-31; Terminal-Bench 4.0 0.0%; Omniscience -38.7; malformed hashline edits (3 of 4 latest, 6 of 7 alias); wrong once at high on the sheep puzzle |
| `mistral-small-2603`, Ministral | Small 4 AA 4.3 < Flash-Lite 11.7; got "401" wrong once, misread "HELLO7"; `ministral-14b` failed 47/47 edits in a 115 s loop |
| Alias ids; Codestral, Leanstral, Magistral, Devstral, Large 3 | Aliases: no catalog metadata (no thinking control, null context, zero cost accounting). Others: FIM-only, specialised, deprecated, or retired |
| Any Mistral primary other than the v38 `default`; a second `mistral/*` entry per chain | Small unmetered pool; each failed hop burns a retry attempt with no preflight skip |

## Judge regression

**v36 regressed `judge`.** Evidence (report 4):

- Before v36 there was no `modelRoles.judge`; OMP's built-in chain (`typesafe/jev-1.14.0` ->
  `openrouter/typesafe/jev-1.14` -> ...) skipped the uncredentialed TypeSafe entry and used the
  OpenRouter key: **164** `model_usage` rows 2026-09-28..10-28 (113 auto-thinking, 51 `find`), all
  `provider:"openrouter"`, `api:"openrouter-decisions"`, total **$0.0121**. The last was
  2026-10-28T13:52:47Z; `~/.omp/agent/config.yml` was rewritten three minutes later.
- After that every judgment ran as `role:"judge"` on prompted `google-antigravity/gemini-3.5-flash-lite`
  (1 on 11-02; 6 auto-thinking + 2 `judge_batch` on 11-03) with 0/1 probabilities.
- **No TypeSafe credential ever existed.** `auth_credentials` has 12 rows (anthropic,
  google-antigravity x5, mistral, nvidia, openai-codex, openrouter, xai-oauth, one `mcp_oauth`),
  none `typesafe`; no `TYPESAFE_API_KEY`; no session row with `provider:"typesafe"`; `git log -S
  typesafe` finds nothing before v36 (`4c5110c`). Credential ids 3, 5, 11, 13, 14 are gone, so a
  deleted row cannot be strictly excluded; nothing supports one. **[INFERENCE]** v36 misread
  pre-v36 rows whose `"role"` is `typesafe` while the provider is openrouter.
- **The warning** `Fallback chain for role 'judge' does not resolve to a compatible model:
  typesafe/jev-preview` is a symptom. `omp models --kind judge --json` (dummy `TYPESAFE_API_KEY`)
  seeds `typesafe/jev-1.14.0` and `typesafe/jev-latest` ($0.042/M input) but not `jev-preview`,
  which only appears if a logged-in account's `/v1/models` lists it. TypeSafe's docs say both
  `jev-preview` and `jev-latest` point at `jev-1.14.0` now, so they add nothing even after login.
  It fires on agent-session startup (`omp -p`), not in `omp models` or `omp find`.
- **`find.enabled: auto`** needs `judge` to resolve first to a native System One model (TypeSafe
  direct or via OpenRouter); auto-prewalk and `tui.autoGraph: smart` need the same. Measured by
  listing tools under `omp -p --config <overlay>`: baseline no `find`; A, B, F have it.
- **Prompted tail rule.** If *every* native entry is uncredentialed, the prompted tail answers (the
  baseline). Once a native route is credentialed and *fails*, OMP never tries a prompted tail
  (docs; tested: dead-port OpenRouter `baseUrl` + Mistral tail -> `coverage: unavailable`, 22/22
  `ECONNREFUSED`, Mistral not tried; `judgment.attemptTimeoutMs: 1` + Mistral tail -> the next
  native answered at jev pricing). So the chain is natives only.

**Tested configs** (`omp find`, unique queries; repeats hit a cross-process cache, ~20 ms, 0
tokens; `or/` = `openrouter/`):

| Config (judge; chain) | Answered by | Wall | Req | Cost | Hits |
|---|---|---|---|---|---|
| Baseline v36 (`typesafe/jev-1.14.0`; jev-latest, jev-preview, Flash-Lite) | Flash-Lite (prompted) | 6.3 s | 7 | $0.0089 | **0**, `find` off |
| A (`or/typesafe/jev-1.14`; `or/jev-1.13`, Flash-Lite) | OpenRouter jev-1.14 | 1.98 s | 8 | $0.0012 | 4 (model-roles.yml 0.97, README.md 0.94) |
| B (`typesafe/jev-1.14.0`; `or/jev-1.14`, `or/jev-1.13`, Flash-Lite) | OpenRouter jev-1.14 | 2.19 s | 9 | $0.00107 | 4 |
| **F** (`or/typesafe/jev-1.14`; `or/jev-1.13`, `or/liquid/d1.1`) — **chosen** | OpenRouter jev-1.14 | 2.0 s | 9 | $0.00119 | 4 (model-roles.yml 0.98) |
| E (`typesafe/jev-1.14.0`; jev-latest, Flash-Lite) | Flash-Lite | — | — | — | warning gone, `find` still off |
| C1 `mistral/ministral-8b-2512` / C2 `mistral-small-2603` | prompted | 14.1 s / 5.7 s | 22 / 6 | $0.0112 / $0.0038 | 4 partial (1 "no answer line") / 3 |
| C3 `gemini-3.5-flash-lite` / C4 `@tiny` (Haiku; spends Claude quota) | prompted | 6.7 s / 7.4 s | 4 / 6 | $0.0060 / $0.0082 | 1 / 3 |
| D2 `or/liquid/d1.1` | native | 3.4 s | — | $0.0003 | 3 plausible |
| D1 `or/perplexity/pplx-decider-flash-v1.2`, D4 `or/upstage/solar-decide-flash`; D3 `or/inception/mercury-decide:free` | native; D3 404 "unavailable for free" (catalog trap) | — | — | D1/D4 322K / 332K input tokens ($0.0166 D4) | 0 |

`judge_batch` probe (6 sequential calls): baseline Flash-Lite 1.1-1.8 s, about $0.0000352/call,
bool answers all 1; A/B/F `openrouter/typesafe/jev-1.14-20261014` **0.40-0.56 s**,
$0.0000125/call, graded probabilities **0.89-0.96**; no `does not resolve` warning in any A/B/F log.

**Config F (v37, superseded by v37.1)**, in `model-roles.yml` v37:

```yaml
modelRoles:
  judge: openrouter/typesafe/jev-1.14
retry:
  fallbackChains:
    judge:
      - openrouter/typesafe/jev-1.13
      - openrouter/liquid/d1.1
```

`jev-1.13` is the same vendor and route; `liquid/d1.1` is a different vendor so a TypeSafe outage
does not kill the judge (tested only as a primary, not as a live fallback). `jev-latest` and
`jev-preview` are dropped. `find.enabled` and `judgment.attemptTimeoutMs` (3000) stay default: a
single call takes 0.40-0.56 s and a whole `find` cascade about 2 s over 8-11 requests. A timed-out
route is skipped 30 s; the last candidate runs to completion. If `Aborted: The operation timed
out` shows in `~/.omp/logs`, run `omp config set judgment.attemptTimeoutMs 10000`.

**Alternative (adopted in v37.1)** (tested as B, minus its dead Flash-Lite tail):
`judge: typesafe/jev-1.14.0` with chain `openrouter/typesafe/jev-1.14` -> `openrouter/typesafe/jev-1.13`.
At v37 the uncredentialed primary was skipped and OpenRouter answered; after login it bills TypeSafe.
Steps (`omp://environment-variables.md`; not run): console.typesafe.ai -> add credit under Billing
(required before a key can be created, per third-party reports) -> key at console.typesafe.ai/keys
-> `/login typesafe`, `omp login`, or `TYPESAFE_API_KEY` in `~/.omp/agent/.env`. Price is
identical ($42 per billion input tokens, output free; 64k context, 262k with the
`TypeSafe-Danger-Zone-Long-Context` header); there is no free API tier (jevhub.io/is-jev-free,
jevainews.com/news/typesafe-signups-paused; TypeSafe X post 2026-09-27). It adds a
second prepaid balance for no price benefit.

**Cost.** OpenRouter credit, $0.042/M input, output free. Observed: auto-thinking about
$0.0000125/call (historical $0.00002); `find` $0.0012-0.0017/call in tests, about $0.0002
historically; $0.012 for 164 judgments in a month. At 200 auto-thinking + 10 `find` per day: about
$0.015/day, about $5/yr. Credit: total 20, usage 12.484 before testing (about $7.52 left); testing
cost about $0.028. `/api/v1/key`: `limit: null`, `is_free_tier: false`. A 402 (credits exhausted)
is not a timeout: with native-only fallthrough judgments and `find` fail rather than degrade;
fail-open consumers (auto-thinking, auto-prewalk) continue without it. Not verified: a live
`liquid/d1.1` fallback after a jev failure; OpenRouter's top-up fee; whether `jev-latest` is 1.13
(OMP docs) or 1.14.0 (TypeSafe docs).

**v37.1 update (2026-11-03, omp 18.16.0).** The owner stored a TypeSafe API key (`/login typesafe`;
`agent.db` `auth_credentials` row `provider=typesafe`, `api_key`), so the alternative above is now the
chosen config, extended with `liquid/d1.1`: `judge: typesafe/jev-1.14.0`, chain
`openrouter/typesafe/jev-1.14` -> `openrouter/typesafe/jev-1.13` -> `openrouter/liquid/d1.1`. The tested
configs table, the F config and its cost paragraph above are the v37 history. Evidence: TypeSafe
discovery now lists `typesafe/jev-1.14.0`, `jev-latest` and `jev-preview` ($0.042/M input, output free);
a fresh omp process judged via `typesafe/jev-1.14.0` (P=0.98, about 4 s for the whole run). Forced
failover with a run-only overlay `judgment.attemptTimeoutMs: 1`: logs show `typesafe/jev-1.14.0`,
`openrouter/typesafe/jev-1.14` and `openrouter/typesafe/jev-1.13` each `Aborted: The operation timed
out.` and `openrouter/liquid/d1.1` answered (P=0.993), so the full chain walk is verified (this also
closes the "live `liquid/d1.1` fallback" gap above). `find` with the v37.1 overlay: coverage complete, 4
relevant hits, $0.0018. Direct `jev-latest` and `jev-preview` stay out of the chain: same provider and
endpoint as the primary, and TypeSafe's docs say both currently alias `jev-1.14.0`. TypeSafe credit and
OpenRouter credit are separate prepaid balances; OpenRouter is now fallback-only for `judge`.
Sessions started before the login keep their cached OpenRouter judge
route (one still judged via OpenRouter): restart OMP sessions to pick up the direct route.

**v37.2 update (2026-11-03).** Owner decision: `vision` chain gains `mistral/mistral-large-4` after
`openai-codex/gpt-6.1-sol` and before `xai-oauth/grok-4.7`. Evidence is the v37 probe data above (5
turns, 10.8 s, 0 edit errors; read the probe image correctly, best Mistral vision result; 1M context,
image input, catalog maxTokens 262,144), not a new run. The hop sits late because it only runs when
Gemini 3.8 Flash, Sonnet and Sol all fail, and Large 4 is a public-preview model with modest neutral
benchmarks (AA 26.0; Terminal-Bench 4.0 24.7% vs 41% in Mistral's harness). It draws the EDU monthly
allowance; the one-`mistral/*`-entry-per-chain rule still holds. The "No Mistral hop" `vision` verdict,
the "four hops" wording and the Large 4 "Not adopted" row above are the v37 history.

**v38 update (2026-11-03).** Owner decision: `mistral/zai-glm-5-3` becomes the `default` primary,
replacing `google-antigravity/gemini-3.8-flash`, which moves to the head of a two-entry fallback chain
(Gemini 3.8 Flash -> Sonnet 5.5; Sol 6.1 and Grok Build leave it). This is the one exception to the
v37 "no Mistral primaries" rule, taken by owner choice with owner priority "keep the default off the
Claude Max pool". Allowance impact, using the corrected $150/mo Vibe Code allowance (see the v38
correction in Subscription facts; resets on the 1st of each calendar month): repriced at Mistral rates,
this Mac's 279 default-only turns over 30 days cost about $4.65/mo, roughly 3% of $150; living on the
default (all 1,870 main turns) would cost about $92/mo, which fits within $150 on this Mac alone but
leaves about $58 for the Ubuntu server (same global config), Mistral Vibe CLI, and the five Mistral
fallback hops. On exhaustion (HTTP 402) the chain walks to Gemini 3.8 Flash, i.e. the v37 default. The
owner confirmed Mistral PAYG is off (both PAYG toggles show "Enable"), so there is no overage. GLM-5.3
is text-only: a pasted image in a default session is not seen (verified 2026-11-03); switch model or
ask the agent to `read <image>?q=...`, which uses the `vision` role. Full analysis, options and
measurements: [DEFAULT-ROLE-EVALUATION.md](DEFAULT-ROLE-EVALUATION.md). The statements above that say
"fallback hops only" and "no primaries" describe v37.

## Risks and open questions

1. **Quota size.** The v37 "about $15/mo at API prices" was an inference from the pricing card; the
   admin page (2026-11-03) shows $150/mo Vibe Code (what the OMP key draws, **[INFERENCE]**) and
   $15/mo API, independent monthly resets on the 1st. No per-model weighting documented; the owner's
   Mistral Vibe CLI (default GLM-5.3) draws the same budget, and since v38 so does the `default` role on
   every machine using this config (the Ubuntu server included).
2. **No meter in OMP.** `omp usage` shows no Mistral or OpenRouter section; exhaustion is learned
   only from a 402 (`billing_vibe_budget_exhausted`, shape from #1362). OMP's default
   `retry.fallbackOn: any` walks the chain on every provider error (`omp://settings.md`). Verified
   2026-11-03 with a throwaway overlay setting `tiny` to an end-of-life NVIDIA model: the `sonic`
   subagent (`@tiny`) got HTTP 410, then failed over to `mistral/zai-glm-5-3-flash`, which answered.
   A 402 itself was not reproduced. An uncredentialed role primary does NOT walk the chain at spawn;
   the subagent takes the parent's model instead (`omp://vibe-mode.md`). Each failed hop consumes a
   retry attempt; there is no preflight skip as for metered providers. Check the console URLs above.
3. **DeepSeek/Ministral on the plan meter?** Unverified; no source confirms it. Irrelevant to v37
   (GLM + Large 4 only), relevant before widening. Test: note the meter, make a few hundred
   `deepseek-v4-1-flash-1017` or Ministral calls through OMP, re-read the meter and the API-credit
   counter.
4. **Preview/new models.** GLM-5.3 Flash was hosted only on 2026-10-22; DS 1017 is preview, and Large 4
   is preview and, since v37.2, sits in the `vision` chain (late hop, error-driven only). The GLM hops
   are z.ai-trained models on Mistral hosting, not Mistral's own (its own are the weakest part of the
   lineup); Large 4 is Mistral's own.
5. **Thinking level not pinned.** Bare fallback entries inherit the failing turn's thinking level
   (`omp://settings.md`); the v37 entries (and the v37.2 Large 4 entry) have no suffix. OMP accepted every level on every
   probed model, so the risk is latency/cost, not errors. Pin a suffix if inherited `xhigh`/`max`
   proves wasteful.
6. **Plan terms.** Whether EDU may enable PAYG overage is unknown (org setting, off by default;
   https://admin.mistral.ai/subscription). The $5.99 price is limited to 12 months with no stated
   renewal price; when the plan ends the key may lose entitlement and the hops fail into the next
   entry (revert below).
7. **Terms/training.** Plan key under consumer terms; training opt-out listed for Pro, EDU assumed
   the same **[INFERENCE]**. Third-party-harness terms for a student plan are unchecked (README
   records such a risk for Anthropic). GLM is hosted by Mistral in the EU per press summaries (Le
   Fil IA, AGI Hunt).
8. **Every machine needs `/login mistral`;** quota is account-level, so load sums across machines.
   Behavior of an uncredentialed fallback hop was not tested.
9. **Review precision and tool-use quality beyond one planted-bug task and the smoke test are
   unmeasured**; the `review` hop must stay non-blocking. No `omp commit --dry-run` probe was run.

## How to revert

- **Remove the hops:** delete the five `mistral/*` chain entries (`smol`, `tiny`, `task`, `review`,
  and, from v37.2, `vision`) from `retry.fallbackChains` in `model-roles.yml`,
  restoring the v36 chains in the table above (and, for `vision`,
  Sonnet 5.5 -> Sol 6.1 -> Grok 4.7); re-apply with `omp config set retry.fallbackChains '{...}'`,
  verify with `omp config get`, bump the snapshot version. To drop only the v37.2 hop, delete
  `mistral/mistral-large-4` from the `vision` chain. The `mistral` login can stay: with no
  role or chain referencing it, it is inert.
- **Revert the v38 default:** set `modelRoles.default` back to `google-antigravity/gemini-3.8-flash` and
  `retry.fallbackChains.default` back to `anthropic/claude-sonnet-5-5` -> `openai-codex/gpt-6.1-sol` ->
  `xai-oauth/grok-build` in `model-roles.yml` (re-apply with
  `omp config set modelRoles.default ...` and `omp config set retry.fallbackChains '{...}'`, verify
  with `omp config get`, bump the snapshot version). The five fallback hops stay valid on their own.
- **Judge:** do not return to v36 (no working native route). To use TypeSafe direct, log in and
  switch to the alternative config above.

## What would change this answer

- Per-model weighting of the $150 Vibe Code allowance being published, a measured Vibe Code counter delta from OMP calls (confirming the key draws it), or `omp usage` gaining a Mistral meter.
- Sustained default-role use pushing the $150 allowance toward exhaustion (the v38 default would then need a cheaper model, e.g. GLM-5.3 Flash, or a Gemini-first order).
- A live exhaustion test showing OMP walking (or failing to walk) the chain on a 402.
- Large 4 leaving preview with an OMP-harness Terminal-Bench 4.0 near Mistral Vibe's 41%.
- A local review-precision measurement for GLM-5.3, or evidence on whether DeepSeek/Ministral usage
  hits the plan meter.

## Sources

Plan, pricing, issue and OMP-docs URLs are cited inline above. Additional sources:

- **Benchmarks:** https://artificialanalysis.ai/leaderboards/models ;
  https://artificialanalysis.ai/evaluations/terminalbench-4-0 ;
  https://artificialanalysis.ai/agents/coding-agents ; https://deepswe.datacurve.ai/ ;
  https://www.tbench.ai/ ; https://www.benchleader.com/benchmarks/lmarena_text ;
  https://openrouter.ai/rankings ; https://docs.mistral.ai/models (per-model pages) ;
  https://mistral.ai/news/mistral-large-4 ;
  https://www.airealist.ai/p/mistral-large-4-weights-score-comes-with-harness ;
  https://docs.z.ai/guides/llm/glm-5.3.md ; https://kunavo.com/guides/mistral-vibe-pricing.
- **Mistral Vibe default model:**
  https://www.lefilia.fr/article/6223909-mistral-met-glm-5-3-par-defaut-dans-vibe-code-et-relance-le-proces-en-renoncement ;
  https://agihunt.info/en/p/1a0c48b276d9ef310ff7d405fbd.
- **Judge:** https://docs.typesafe.ai/models ; https://typesafe.ai ; https://console.typesafe.ai ;
  OpenRouter `typesafe/jev-1.14` model page; OMP docs `omp://environment-variables.md` ("TypeSafe
  judgments"), `omp://tools/find.md`, `omp://prewalk.md`, `omp://models.md`.

**Method.** Five reports (plan/billing, benchmarks, live OMP probes, judge with 14 overlay configs,
methodology critic). API keys were read into shell variables only and never printed; the research
workers edited no repo or `~/.omp` file.
