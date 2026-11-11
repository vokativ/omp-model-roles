# `default` role: GLM-5.3 primary, Gemini 3.8 Flash fallback — v38 evaluation

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root,
one level up.*

Written 2026-11-03 for snapshot v38 (omp 18.16.0). Prompted by a question the owner asked after the
Mistral adoption (`MISTRAL-EVALUATION.md`): is `google-antigravity/gemini-3.8-flash` still the right
`default`? This evaluation **ran the models** (a live OMP probe, same harness as the Mistral study)
and **mined this Mac's session logs** for how the default is actually used. It did **not** measure
review precision, long-session quality, or the Ubuntu server's traffic (see risks).

**Terminology.** This repo uses "Vibe" for OMP's good/fast worker tiers. "Mistral Vibe" and
"Mistral Vibe CLI" here always mean Mistral's coding product and its plan budget.

Evidence reports lived in `/tmp/omp-mistral-research/reports/` (`REPORT.md` usage forensics,
`RESULTS.md` live probe, `2-benchmarks.md`) with scripts in `/tmp/omp-default-analysis/`. That
scratch tree is not committed; every number below is copied from those reports and attributed.
**[INFERENCE]** marks anything not read directly from a source.

---

## Decision

- **Adopted (v38, 2026-11-03, owner decision): `modelRoles.default` ->
  `mistral/zai-glm-5-3`**, was `google-antigravity/gemini-3.8-flash`.
- **Chain:** `retry.fallbackChains.default` -> `google-antigravity/gemini-3.8-flash` ->
  `anthropic/claude-sonnet-5-5`, was `anthropic/claude-sonnet-5-5` -> `openai-codex/gpt-6.1-sol` ->
  `xai-oauth/grok-build`. Sol and Grok Build leave the default chain (see Options).
- **Unchanged:** thinking for `default` stays on `defaultThinkingLevel: auto` (judge-driven). The
  owner rejected pinning Gemini to `:low` as "not a useful model". Ctrl+P `cycleOrder` is still
  `smol`, `default`, `slow`, `sage`. Nothing else changed from v37.2.
- **Owner priorities, in order:** (1) keep the default off the Claude Max (Anthropic) pool, so
  Sonnet 5.5 is the last hop; (2) a default that is actually fast in OMP; (3) cost stays inside the
  Mistral allowance. Mistral pay-as-you-go (PAYG) is **off**, confirmed by the owner and by the
  subscription page (below).
- **Exception to a v37 rule.** `MISTRAL-EVALUATION.md` adopted "no Mistral primary". This is one,
  by owner choice. The other five Mistral uses stay fallback-only hops.
- **Same config everywhere.** The Ubuntu server uses the same global config, so it also defaults to
  GLM-5.3 and draws the same allowance.

## Mistral allowance (corrected 2026-11-03)

Owner screenshot of https://admin.mistral.ai/subscription, 2026-11-03 12:26:

| Item | Reading |
|---|---|
| Plan | "Education — Pro plan with student discount", Active |
| Included API usage (API/Studio) | **$0 used of $15** |
| Included Vibe Code usage | **$5.35 used of $150** |
| Reset | Both "on the first day of each calendar month, independently of your subscription renewal" (page said "Resets in 28 days", i.e. 2026-12-01) |
| Pay-as-you-go | "API pay-as-you-go" and "Pay-as-you-go for Vibe Code" both show an **Enable** button: both **off** |

**[INFERENCE]** OMP's `/login mistral` key is a vibe-scope plan key (`MISTRAL-EVALUATION.md`,
subscription facts) and draws the **$150 Vibe Code** allowance, not the $15 API allowance: API usage
read $0 after a day of OMP calls through that key. The $5.35 includes the OMP research probes of the
day plus any Mistral Vibe CLI use. **Correction:** v37 inferred "$15/mo" as the single allowance from
the pricing card's "$15 /mo in API credits" line; the page shows two pools, and the one OMP draws is
$150. The $15 figures in `MISTRAL-EVALUATION.md` are v37 history.

## Why revisit

`default` fires on every turn of a session that stays on it, so it is the most-used role in the
file. The v37 default (`gemini-3.8-flash`) was kept on a speed-and-preference rationale: v18 "user
preferred every-turn model" (`model-roles.yml` history), and `README.md` v37 text "fastest measured
model and user daily preference". Three findings undercut that:

1. **Gemini 3.8 Flash is not fast in OMP.** Tool-task wall time is 21.6 s (low) / 34.6 s (high)
   against 7.6 s for GLM-5.3 and about 9 s for Sonnet 5.5 (probe matrix below). TTFT is 2.7-3.3 s on
   every turn versus 0.64 s for GLM-5.3.
2. **The speed was a Gemini 3.6 Flash property.** In the owner's all-time main-session data
   (`REPORT.md` section 5): gemini-3.6-flash TTFT 1705 ms, turn duration p50 1.9 s, end-to-end 212
   tok/s (model_perf 128.7); gemini-3.7-flash TTFT 3257 ms, p50 3.7 s, 132 tok/s; gemini-3.8-flash
   p50 3.4 s, 109 tok/s. So 3.6 Flash was about 2x faster per turn than 3.8 Flash, and the default
   rolled forward through two generations on the original rationale.
3. **The owner mostly does not stay on it.** Every one of 16 main sessions in 30 days starts on
   Gemini 3.8 Flash, but only 15% of turns stay there; 10 of 16 sessions left within 6 minutes
   (usage forensics below). The default is mostly a launch pad, so its job is "good first turns and
   no Claude load while I decide", not sustained throughput.

Benchmarks point the same way for agentic work (`2-benchmarks.md`, Artificial Analysis v5.0, one
harness): GLM-5.3 AA Index 31.7 vs Gemini 3.8 Flash 30.5; Terminal-Bench 4.0 **41.9% vs 19.7%**
(Sonnet 5.5 43.9%); FrontierCode 2.0 21.6% vs 18.7%. Counter-evidence from `MISTRAL-EVALUATION.md`:
DeepSWE v1.1 has Gemini 3.8 Flash (high) 74% vs GLM-5.3 (max) 69%.

## Usage forensics (this Mac only, 30 days)

Source: `REPORT.md`; session files under `~/.omp/agent/sessions`, `agent.db`; cutoff 2026-11-03
11:48 SGT. 16 top-level main sessions on 14 active days, 1864 assistant turns with tokens > 0. Cost
is OMP's API-price estimate, not subscription cost.

**Main-session turns by model:**

| Model | Turns | % turns | Input-like tokens | Output tokens | Sessions | API-equivalent $ |
|---|---|---|---|---|---|---|
| `anthropic/claude-opus-5-5` | 990 | 53.1 | 370.4M | 616k | 3 | 148.0 |
| `openai-codex/gpt-6.1-sol` | 282 | 15.1 | 45.9M | 208k | 4 | 11.1 |
| `google-antigravity/gemini-3.8-flash` | 277 | 14.9 | 14.0M | 123k | 8 | 2.7 |
| `anthropic/claude-sonnet-5-5` | 154 | 8.3 | 34.2M | 273k | 2 | 11.5 |
| `xai-oauth/grok-4.7` | 127 | 6.8 | 8.4M | 77k | 3 | 5.7 |
| `openai-codex/gpt-6-astra` | 34 | 1.8 | 10.6M | 18k | 1 | 14.6 |

Last 7 days: 491 turns in 3 sessions, **Opus 92.3%**, Gemini 3.8 Flash 7.7%. All 16 sessions began
on the default (first `model_change`).

**How sessions leave the default** (`model_change` events, 30 days): 16 initial, 2 `default`
re-selects, 7 `slow` (5 to Sol, 2 to Opus), 6 `temporary` (3 Grok 4.7, 1 each Sonnet, Astra, Opus),
1 `fallback` (2026-10-24, Gemini to Sonnet after 249 s, no error recorded). First switch after
start, 11 of 16 sessions: 2, 4, 6, 20, 30, 77, 136, 249, 305, 360 s and one at 6046 s. So 10 of 16
left within 6 minutes, 5 within 30 s (before or at the first prompt). 5 sessions (6-75 turns each)
stayed on Gemini throughout.

**Context per main turn** (input + cache read, tokens):

| Model (30 d) | n | p50 | p90 | max |
|---|---|---|---|---|
| all main turns | 1864 | 201.7k | 636.7k | 836.9k |
| `claude-opus-5-5` | 990 | 342.2k | 696.4k | 836.9k |
| `claude-sonnet-5-5` | 154 | 225.4k | 305.5k | 388.9k |
| `gpt-6.1-sol` | 282 | 99.9k | 366.2k | 463.2k |
| `gemini-3.8-flash` | 277 | 39.7k | 101.0k | 119.7k |
| `grok-4.7` | 127 | 53.0k | 137.5k | 151.8k |

Last 7 days: p50 577k, p90 756k, max 837k. Prompt > 200k on 51.3% of 30-day turns; > 400k on 22.0%;
> 900k on 0%. Context windows (`omp models <provider> --json`): GLM-5.3 1,048,576 (max out
131,072), Gemini 3.8 Flash 1,048,576, Sonnet 5.5 1,000,000, Sol 6.1 922,000, **Grok 4.7 500,000,
Grok Build 512,000**; Grok would have overflowed 15.3% of 30-day main turns. The long contexts are
usage-biased (the owner switched to Opus for long work), but the default must survive a switch back
mid-session, so a 1M-window GLM-5.3 fits and Grok Build does not.

**Errors and latency.** Zero `stopReason=error` turns on main sessions in 30 days (6 user aborts);
the all-time Gemini 3.8 Flash main error rate is 3/958 (0.31%: two 429 quota errors on 2026-09-16,
one "No API key" 2026-09-17). Real main-session latency, 30 days: Gemini 3.8 Flash TTFT p50 3802 ms
(p90 7795), turn p50 4.0 s; Sonnet 5.5 TTFT 1174 ms, turn p50 6.5 s; Opus 5.5 TTFT 2232 ms. Gemini
turns carry 3-9x smaller prompts, which flatters its turn time; its end-to-end tok/s (99) is no
better than Sonnet's (105).

**Meters** (`usage_history`, this Mac; readings exist only while an omp process runs):

| Series (30 d) | Max | Last | Note |
|---|---|---|---|
| Antigravity main Gemini 5h / weekly | 0.41 / 0.90 | 0.05 / 0.05 | mostly idle |
| Antigravity free accounts B-E, Gemini weekly | 1.00 / 1.00 / 0.94 / 1.00 | ~0 | each reached 94-100% at times |
| Anthropic 5h / 7d | 0.93 / 0.53 | 0.25 / 0.46 | 5h peaked at 93% twice |
| Codex Plus 7d | 0.78 | 0.78 | the reason Sol leaves the default chain |
| Antigravity Claude&GPT shared weekly | 1.00 | 0.93 | drained by traffic not seen on this Mac [INFERENCE: likely the server] |

Gemini is the cheapest lane to keep as the first hop: weekly pool mostly idle, and four free
accounts that are ~0% now. Anthropic is the pool the owner wants spared.

## Live probe matrix

omp 18.16.0, 2026-11-03 ~11:50-12:05 +08, fresh copy of a planted-bug fixture as cwd for every
run (`/tmp/omp-default-analysis/{drv.py,group.py,calib.py,meter.py}`; per-run JSON in `results/`).
Command per run:

```text
omp -p --no-session --auto-approve --mode json --model <sel> --thinking <lvl> "<prompt>" [@shapes.png]
```

`grok-build` ran without `--thinking` (its catalog entry has no thinking levels). Prompts: TOOL
(the Mistral-study prompt: run the failing test, fix the planted bug, create and run `fizz.py` and
`test_fizz.py`; PASS means `python3 test_stats.py` and `python3 test_fizz.py` exit 0 afterwards and
`fizzbuzz(15)`/`(5)` are right), CHAT ("Read stats.py, then explain in 5 bullets ... and give one
risk"), IMG ("Describe this image briefly: shapes, colors, any text." with `@shapes.png`). All runs
exit 0; every `message_end` provider/model equals the requested selector (no silent fallback).

| Candidate | n (tool) | Tool wall median (range) | Turns | Edit errors / calls | Verified | TTFT median (p90) | Image |
|---|---|---|---|---|---|---|---|
| Gemini 3.8 Flash `low` | 6 | **21.6 s** (11.7-24.1) | 7.5 | 0/6 | 6/6 | 2661 ms (3321) | OK, 1 turn, 3.9 s |
| Gemini 3.8 Flash `high` | 6 | **34.6 s** (30.2-41.1) | 8.5 | 0/6 | 6/6 | 3345 ms (6497) | OK, 5 turns, 23.5 s, used `eval` on pixels |
| Gemini 4 Argon `high` | 4 | 26.7 s (22.7-28.7) | 4 | 0/4 | 4/4 | 5167 ms (7435) | OK, 6.6 s |
| Sonnet 5.5 `low` | 2 | 8.9 s | 5 | 0/2 | 2/2 | 1111 ms (1460) | OK, 2.3 s |
| Sonnet 5.5 `high` | 2 | 9.4 s (7.7-11.2) | 4.5 | 0/2 | 2/2 | 846 ms (1297) | OK, 2.4 s |
| Haiku 5.5 `low` | 2 | 10.7 s | 4.5 | 0/2 | 2/2 | 1593 ms (1668) | OK, 2.5 s |
| Grok 4.7 `high` | 6 | 15.5 s (10.4-21.5) | 6 | 0/6 | 6/6 | 1757 ms (2055) | OK, 2.4 s |
| Grok Build (default effort) | 6 | 22.5 s (13.7-30.0) | 11 | **5/11** | 6/6 (one fizz spec ambiguity) | 1009 ms (1249) | OK, 4 turns, 15.1 s |
| GPT-6.1 Sol `medium` | 1 | 44.8 s | 9 | 0/1 | 1/1 | 2115 ms (7299) | OK, 3.9 s |
| **GLM-5.3 `high` (mistral)** | 2 | **7.6 s** (6.1-9.2) | 7 | 0/3 | 2/2 | **643 ms** (773) | **text-only**; solved via `eval`, 12.7 s |

Chat wall medians: Gemini low 7.0 s, Gemini high 20.6 s (12.6-89.3), Sonnet 5.0-6.2 s, GLM-5.3
4.2 s, Grok 4.7 13.6 s, Grok Build 19.5 s, Sol 10.9 s. Per-run omp overhead (wall minus summed model
durations) 0.3-1.4 s, outliers 3.3 s (Grok Build) and 9.7 s (GLM).

**Caveats.**

- **n is 1 to 6 per cell** (Sol n=1; GLM-5.3, Sonnet, Haiku n=2 for the tool task): directional,
  not statistical. Ranges, not confidence intervals.
- **One task shape.** A small planted-bug fixture, not the owner's 200k-600k-token sessions. Turn
  counts and wall times will not transfer; TTFT and edit-error behaviour are the better signals.
- **Gemini decode tok/s is unusable** when thinking is on (values up to 3830 tok/s: thinking tokens
  are billed but not streamed), so the table reports wall and TTFT only.
- **One stall.** `gemini-3.8-flash high`, chat run 3: an assistant turn hung 60.0 s, stopped with
  `Request was aborted`, and OMP's `auto_retry` (attempt 1 of 10, 488 ms delay) succeeded; wall
  89.3 s. That is 1 stall in about 77 Flash-high turns and 0 in 55 Flash-low turns.
- **Gemini's cost on its own meter.** Over 26 runs (131 turns, $1.09 list): 5h +3.84 points, weekly
  +0.98. A calibration split puts high at about 3-5x low per run (low: 8 runs, 5h +0.24, weekly
  +0.07; high: 8 runs, 5h +1.29, weekly +0.60). `defaultThinkingLevel: auto` can pick high.
- **Meters.** The Anthropic usage endpoint returned 429 during the probe, so Sonnet/Haiku meter
  deltas were not read (list cost of those runs about $0.14, negligible **[INFERENCE]**). xAI
  (13+13 runs, $1.00 list) moved SuperGrok credits +8 and Grok Build +7 points; Codex (3 Sol runs)
  moved < 1 point. Antigravity readings carry about +-0.4 noise.
- **GLM-5.3 is also quick in the Mistral study:** 10 turns, 13.8 s, 0 edit errors on the same task
  in the v37 probe (`MISTRAL-EVALUATION.md`), against 7 turns / 7.6 s here (different runs, same
  harness family).

## Cost model

**Repricing.** This Mac's last 30 days of main-session turns, repriced at Mistral rates (GLM-5.3
$1.4 input / $0.14 cached / $4.4 output per million; GLM-5.3 Flash $0.15 / $0.03 / $0.5; Gemini 3.8
Flash list $0.75 / $0.075 / $3.75):

| Scenario | GLM-5.3 | GLM-5.3 Flash | Gemini 3.8 Flash list |
|---|---|---|---|
| Turns that actually stayed on the default (279) | **$4.65** | $0.69 | $2.66 |
| All main turns (1870), as if every turn ran on the model | $91.55 | $16.89 | $50.88 |

**Against the allowance** (see "Mistral allowance (corrected)" above):

- The default-only pattern costs about **$4.65/month, about 3% of the $150 Vibe Code allowance**.
- "Living on the default" (every main turn on GLM-5.3) is about **$92/month, about 61% of $150**.
  That fits on this Mac alone but leaves about **$58 for the server, Mistral Vibe CLI and the Mistral
  hops**. It is a stress case: 53% of the turns are Opus turns with a 342k median context that would
  be priced at GLM-5.3 cache rates only in this hypothetical.
- **Already used:** $5.35 of $150 on 2026-11-03, including the research probes and any Mistral Vibe
  CLI use; the plan also carries $0 of $15 API usage.
- **Reset** is the first day of each calendar month (next: 2026-12-01), independent of renewal.
- The window is monthly, not 5-hour or weekly, so a spike in the first days of a month is the only
  way to starve the rest of the month.

**Exhaustion behaviour.** PAYG is off, so exhaustion means HTTP **402** (error shape seen in
Mistral Vibe issue #1362: `{"code":"2304","type":"billing_vibe_budget_exhausted"}`; not reproduced
here). OMP's `retry.fallbackOn: any` walks the chain on provider errors; the v37 forced-failover test
(an end-of-life NVIDIA primary returned HTTP 410 and `mistral/zai-glm-5-3-flash` answered) verified
the walk for another error class (`MISTRAL-EVALUATION.md`, risk 2). The v38 `default` chain itself was
verified live on 2026-11-03: a fresh `omp -p` session answered on `mistral/zai-glm-5-3`, and with a
run-only overlay setting `default` to the same end-of-life NVIDIA model, the 410 produced
`retry_fallback_applied` (role `default`) to `google-antigravity/gemini-3.8-flash`, which answered. A 402
itself was not reproduced. So after exhaustion `default`
falls to Gemini 3.8 Flash, which is exactly the v37 default, then to Sonnet 5.5. **No preflight
skip:** `retry.usageAwareFallback` ignores keys with no meter, so each turn may pay a failed GLM
attempt before the hop **[INFERENCE: not observed for a persistent 402]**.

**Shared consumers of the same $150.** Everything bills one account-level pool:

1. `default` on this Mac (v38, new).
2. `default` on the Ubuntu server, same global config (v38, new; traffic unseen here).
3. The owner's Mistral Vibe CLI (its own default is GLM-5.3; GrowthBook
   `vibe_cli_default_routing_model`).
4. The five fallback hops: `smol` and `tiny` (GLM-5.3 Flash), `task` and `review` (GLM-5.3),
   `vision` (Large 4).

**Exhaustion starves the Mistral fallback hops for the rest of the calendar month**, not just
`default`: each chain loses its Mistral hop and continues to the next entry (v36 shapes).

**Cheaper variant considered.** GLM-5.3 Flash as default would cost $0.69/month (default-only) and
$16.89 (all turns) and reads images, but is weaker (AA Index 27.8, Terminal-Bench 4.0 32.8%). With a
$150 pool the cost argument is weak; capability and the owner's "useful model" bar decided.

## Options considered

| Option | For | Against | Verdict |
|---|---|---|---|
| **GLM-5.3 -> Gemini 3.8 Flash -> Sonnet 5.5 (v38)** | Fastest measured in OMP (7.6 s, TTFT 0.64 s); Terminal-Bench 4.0 41.9%; 1M context; 0 edit errors; off the Claude pool until the last hop; about 3% of the allowance on this Mac | Text-only; 402 risk shared with the server, Mistral Vibe and five hops; always reasons; first Mistral primary; no meter in OMP | **Chosen** |
| A. Sonnet 5.5 default | Fastest frontier (8.9 s, TTFT ~1.1 s); no new dependency | Adds Claude Max load on the pool the owner wants spared (5h peaked at 93%, 7d about 46%); contradicts owner priority 1 | Rejected |
| B. Gemini 3.8 Flash `:low` | Cheapest on Gemini meters (low about 1/3-1/5 of high); 21.6 s | Owner: "not a useful model"; still the slowest candidate with TTFT 2.7 s | Rejected by owner |
| C. Opus 5.5 default | Strongest model | Most Claude cost: 990 of 1864 turns, $148 API-eq in 30 days; against priority 1 | Rejected |
| D. GLM-5.3 Flash default | Vision; $0.69/month; cheaper | Weaker (AA 27.8; Terminal-Bench 4.0 32.8%); owner wanted a useful default | Rejected |
| E. Gemini-first, GLM fallback | Image-capable default; no Mistral primary; Gemini meters mostly idle | Slow (TTFT 2.7 s); Gemini high 3-5x low on meter; 60 s stall seen once | Rejected |
| Old chain tail: Sol 6.1, Grok Build | Independent capacity | Sol: Plus 7d meter 78% (not available to the default). Grok Build: 512K window overflows 15% of turns; 5/11 edit errors in probe | Dropped from `default` chain |
| Mistral Large 4, DeepSeek V4.1 Flash | Strong on some axes | Preview models; AA 26.0 / 24.7% Terminal-Bench 4.0 (Large 4); thinking-only turns (DS) | Not considered further |

Grok 4.7 (15.5 s, 6/6) and Haiku 5.5 (10.7 s) probed fine but were not candidates (Grok 500K
window; Haiku below default capability).

## Risks

1. **Text-only default (verified 2026-11-03).** GLM-5.3 as the active model given an attached image
   (`@file`) cannot see it; OMP passes images to text-only models without warning. Four prompt
   variants were tried in a GLM-5.3 main session:
   - Plain "What is in this image?": GLM cannot see the image and falls back to decoding pixels with
     Python/OCR (slow, ~10 tool calls, unreliable for real screenshots).
   - "Read the attached image with the vision model ...": **same fallback; does not work.**
   - "Use the read tool on the attached image and tell me ...": works. GLM calls `read` on the
     attachment (stored as `local://image-<hash>.webp`), gets the hint, then calls
     `read <path>?q=<question>`, which the `vision` role (Gemini 3.8 Flash first) answers; correct answer.
   - "Ask the vision model about shapes.png ...": also worked (3 reads).

   In subagents GLM used `read` + `?q=` unprompted after reading the file (see
   [TASK-ROLE-EVALUATION.md](TASK-ROLE-EVALUATION.md), item D). Alternative: switch model (Ctrl+P to
   `smol`, `slow`, or `/model` to an image-capable model). Because the default is where attached
   screenshots land, this is the most user-visible regression.
2. **Allowance exhaustion starves the Mistral fallback hops for the month.** HTTP 402 ends the
   default's GLM hop and the five other Mistral hops until the 1st. Smol, tiny, task, review and
   vision keep working through their non-Mistral entries, with less depth. Headroom is large
   ($150 vs about $5 default-only here), but the worst case is a long-context stress ($92 on this
   Mac alone).
3. **Unmetered; no usage-aware skip.** `omp usage` shows no Mistral section;
   `retry.usageAwareFallback` has nothing to read. Exhaustion is learned from a 402 or the console.
   Each failed hop consumes a retry attempt.
4. **Server shares config and allowance.** Every machine needs `/login mistral`; the quota is
   account-level, so the server's default turns add to this Mac's. Server traffic is unseen
   (Antigravity meters suggest it is not small **[INFERENCE]**). An uncredentialed server would walk
   to Gemini; that path was not tested.
5. **GLM thinking "off" still reasons.** `reasoningDisableMode: 'lowest-effort'`: `--thinking off` on
   `zai-glm-5-3` still produced reasoning and answered 403 on the integer puzzle
   (`MISTRAL-EVALUATION.md`). Auto-thinking cannot make the default cheap per turn, so a default
   chat turn is a reasoning call at $4.4/M output.
6. **Gemini high stall, seen once.** A 60 s hang on `gemini-3.8-flash high`, auto-retried (1 in ~77
   high turns). The same stall risk now sits on the first fallback hop, not the primary, so the
   exposure shrinks.
7. **Capability tier.** GLM-5.3 is at the Gemini 3.8 Flash level on AA Index (31.7 vs 30.5), far below
   Sonnet 5.5 (54.2 at max effort) and the depth tier. DeepSWE (74% vs 69%) and Omniscience (+6.0 vs +23.3) favour
   Gemini on some axes. First turns that previously ran on Gemini now run on a model with weaker
   knowledge recall. Mitigation is behavioural: the owner switches within minutes anyway.
8. **Preview/new model and plan terms.** GLM-5.3 was hosted 2026-09-15; the EDU price is $5.99/month
   limited to 12 months with no stated renewal price (`MISTRAL-EVALUATION.md`); when the plan ends
   the key may lose entitlement and the default walks to Gemini.
9. **Sample sizes.** All probe cells are n=1 to 6 and one task shape.

## How to monitor

- **Meter, console only:** https://admin.mistral.ai/subscription (Included API usage $x of $15;
  Included Vibe Code usage $x of $150; PAYG toggles); https://console.mistral.ai/codestral/cli
  ("View organization usage"); https://admin.mistral.ai/organization/usage;
  https://admin.mistral.ai/plateforme/limits. No usable API (`MISTRAL-EVALUATION.md`).
- **Check weekly** for the first month; the server's share is the unknown. A reading above about 40%
  by mid-month on the Vibe Code line would mean the default is heavier than this Mac's 3% suggests.
- **In OMP:** a `model_change` event with `role: "fallback"` and `resolvedModelIsFallback: true` in a
  main session file marks an automatic hop; `~/.omp/logs` shows provider errors (402 /
  `billing_vibe_budget_exhausted`). Re-run the forensics over a full reset cycle with
  `/tmp/omp-default-analysis/` (not committed; scripts `extract.py`, `q1b.py`, `q2.py`).
- **Notice images:** a reply saying the active model cannot see images, or the agent decoding pixels
  with Python/OCR, means the session is on the default; use the workaround in risk 1 ("Use the read
  tool on the attached image and ...").

## How to revert

1. In `model-roles.yml`, set `modelRoles.default: google-antigravity/gemini-3.8-flash` and
   `retry.fallbackChains.default` to the v37 chain (`anthropic/claude-sonnet-5-5`,
   `openai-codex/gpt-6.1-sol`, `xai-oauth/grok-build`).
2. Re-apply with `omp config set modelRoles '{...}'` and `omp config set retry.fallbackChains
   '{...}'` using the README's apply block, check with `omp config get`, then bump the snapshot
   version.
3. The `mistral` login stays; the five fallback hops need it. Restart long-lived OMP sessions to pick
   up the new default. Revert every machine (omarchy, Lubuntu, Mac); `scripts/check-live.sh` confirms each.
4. A partial revert is also possible: drop only the Mistral primary but keep the new chain
   (Gemini 3.8 Flash -> Sonnet 5.5), which keeps Sol and Grok Build off the default.

## What would change the answer

- A live 402 test showing OMP does **not** walk the chain (default turns would fail outright), or a
  persistent 402 that makes every turn pay a failed hop.
- The Vibe Code line passing about 60% by mid-month, or the server's draw proving large.
- A text-only default becoming a daily annoyance (images pasted into default sessions more than
  occasionally): move to GLM-5.3 Flash (vision) or Gemini-first.
- Gemini 3.8 Flash (or a successor) reaching 3.6 Flash's speed (TTFT near 1.7 s, turn p50 near
  1.9 s) in OMP probes, which would bring back the original rationale.
- Plan changes: EDU ends after 12 months, Mistral Vibe CLI drawing the allowance heavily, or a
  published per-model weighting.
- Neutral evidence that GLM-5.3's agentic edge does not hold in OMP's long contexts (200k+), since
  the probe was a small fixture.

## Sources

Reports (scratch, uncommitted): `/tmp/omp-mistral-research/reports/REPORT.md` (usage forensics),
`RESULTS.md` (live probe), `2-benchmarks.md` (Artificial Analysis v5.0, AA mini-swe-agent
Terminal-Bench 4.0, DeepSWE). Plan and meter URLs, pricing and the 402 shape:
`MISTRAL-EVALUATION.md` (https://help.mistral.ai/en/articles/698531,
https://docs.mistral.ai/admin/billing-usage/subscriptions,
https://github.com/mistralai/mistral-vibe/issues/1362). Allowance correction: owner screenshot of
https://admin.mistral.ai/subscription, 2026-11-03 12:26. Benchmarks: https://artificialanalysis.ai/
leaderboards/models ; https://deepswe.datacurve.ai/ .

**Method.** One orchestrator, three research reports and a live probe run through the same harness
as the Mistral study (fresh fixture per run, `--no-session`, verified afterwards by re-running the
tests). API keys were not printed; no `~/.omp` file was edited.
