# `task` role: Sonnet 5.5 vs GLM-5.3 vs Gemini 3.8 Flash — v38 evaluation

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root,
one level up.*

Written 2026-11-03 for snapshot v38 (omp 18.16.0). Follows `DEFAULT-ROLE-EVALUATION.md`, which moved
`default` to `mistral/zai-glm-5-3` and left the Mistral Vibe Code allowance ($150/month) as a shared
pool. The owner asked whether `task` (delegated subagent work, now `anthropic/claude-sonnet-5-5`)
should follow. This evaluation **ran the three models** through the same `omp -p` harness family,
**replayed real past assignments**, **tested subagent integration** with GLM as the task primary, and
**mined this Mac's session logs** for the actual workload and meter behaviour. It did **not** measure
long-horizon quality on large repos, the Ubuntu server's traffic, or a Mistral 402 (see risks).

Evidence reports live in `/tmp/omp-task-eval/` (`A-report.md` to `F-report.md`; scripts and run
artefacts in the subdirectories named under Sources). That scratch tree is not committed; every
number below is copied from those reports and attributed. **[INFERENCE]** marks anything not read
directly from a source. Model selectors used throughout: Sonnet 5.5 =
`anthropic/claude-sonnet-5-5`, GLM-5.3 = `mistral/zai-glm-5-3`, Gemini 3.8 Flash =
`google-antigravity/gemini-3.8-flash`. All model runs below used `--thinking medium` unless noted.

---

## Question and status

- **Status: decided 2026-11-03 — keep Sonnet 5.5 (owner).** `model-roles.yml` v38 is **unchanged**:
  `modelRoles.task` stays `anthropic/claude-sonnet-5-5`; the `task` fallback chain stays
  `openai-codex/gpt-6.1-sol` -> `google-antigravity/gemini-3.8-flash` -> `mistral/zai-glm-5-3` ->
  `xai-oauth/grok-build` (as in `model-roles.yml`). The GLM-primary shape below is recorded but not applied.
- **Question.** Is it worth moving `task` to GLM-5.3 (spare the Claude Max pool, stay inside the
  Mistral allowance) or to Gemini 3.8 Flash (free Antigravity accounts), and what does it cost in
  quality and time?
- **Short answer from the evidence.** GLM-5.3 matched Sonnet on correctness in synthetic benchmarks
  and in research/verification tasks, but with 1.7x-3.6x the turns, about 2x the wall time, and two
  real-replay defects (non-loading Luau code, a Dart over-engineer). Gemini 3.8 Flash matched on
  correctness but was 3x-12x slower and is not viable as primary. Moving `task` to GLM relieves
  Anthropic less than the turn share suggests, because Opus main sessions drive the Claude meters.

## Workload

Source: `A-report.md` (this Mac only, `sessions.db` cutoff 2026-11-03 ~11:48 SGT; "turns" are
assistant messages with tokens > 0).

**Volume (30 days).** `task/good_worker` 1577 turns in 51 sessions; `task/task` (role name used only
on 11-03) 362 turns in 15 sessions. **Task total: 1939 turns, 66 sessions** (7 days: 492 turns, 21
sessions). All Sonnet 5.5 except 55 Sol turns on 10-06. Sonnet list cost of the 30-day task total:
$63.63. `scout`/`smol` adds 137 turns, $6.34 (not part of `task`).

**Prompt size.** Task turns, prompt tokens per turn p50 / p90 / p99 / max: **85.8k / 183k / 284k /
366k**; output per turn p50 461, mean 892. Cache read is 96.2% of prompt tokens. Turns per session
median 25 (p90 63, max 76). Max prompt 366k is well inside GLM's 1,048,576 window. Assignment text:
median 2.4k characters (p90 4.3k, max 6.9k). Tool mix overall: bash 1139, read 805, web_search 249,
grep 182, edit 152, eval 134, write 49.

**Mix (all 66 task sessions, categorised by reading assignments and tool counts):**

| Category | Sessions | Turns (%) | Median turns/session | Median prompt/turn | Sonnet $ | Edits |
|---|---|---|---|---|---|---|
| Web research / OSINT / legal, read-only | 13 | 659 (34.0%) | 46 | 115k | 24.0 | 8 |
| Dynamic tests / verification / live probes | 10 | 397 (20.5%) | 38 | 72k | 11.0 | 16 |
| Read-only code/device investigation, audits | 10 | 334 (17.2%) | 28 | 71k | 10.5 | 10 |
| Implementation, multi-file code edits | 11 | 249 (12.8%) | 18 | 25k | 7.5 | 77 |
| Doc/config-file edits | 13 | 182 (9.4%) | 10 | 33k | 7.7 | 55 |
| Test writing | 3 | 54 (2.8%) | 10 | 33k | 1.5 | 13 |
| Bug fix (review-reported) + test | 4 | 46 (2.4%) | 12 | 33k | 1.1 | 19 |
| Small config/script authoring | 2 | 18 (0.9%) | 9 | 17k | 0.3 | 3 |

**About 72% of turns are read-only, research or verification** (bash/read/web_search/eval/browser
heavy, 0.8 edits per session); only about 28% edit code or docs. A-report's inference: GLM's weaker
Omniscience/hallucination robustness matters most for the 34% web-research plus 20% verification
share (tested in E below).

**Burstiness.** Usage is concentrated: 6 active days in 30 (10-21: 318 turns; 10-24: 719; 10-26:
296; 10-27; 10-28; 11-03: 362, itself the research pools for this study). F-report: the 10-24 day was
one session with 15 subagent files and all 719 turns inside 33.6 minutes (about 21 turns/min); 11-03
had 362 turns in 37 minutes. Only October is Sonnet-measured; August and September ran on
`gpt-5.6-terra`.

## Quality evidence

### Synthetic hidden-test benchmark (B)

Nine small, well-specified Python repos (stdlib only, `unittest` graders copied in after the run so
the agent never sees them): T1 multi-file coupon feature, T2 misleading-symptom rate-limiter bug,
T3 rename/extract refactor with golden output, T4 write tests graded by 20 mutants, T5 YAML + docs +
README + CHANGELOG consistency, T6 eight codebase questions into `ANSWERS.md`, T7 four bugs across
modules, T8 thread-safe TTL/LRU cache with single-flight loading, T9 migrate 8 call sites to a new
API and delete `legacy/`. T1-T6 were the requested six; T7-T9 were added after tier 1 saturated.
Each arm ran n=2 per task at `--thinking medium`, n=3 on T8 (19 medium runs per arm), plus 2 GLM runs
at `--thinking high` (T1, T8). Concurrency was 2-5 runs, so wall times are not isolated. No run timed
out or errored, and every `message_end` came from the requested model (no silent fallback).

**Result matrix (full passes under the final graders):**

| Arm | Passes |
|---|---|
| Sonnet 5.5 | 19/19 |
| GLM-5.3 | 19/19 |
| Gemini 3.8 Flash | 19/19 |

Every cell was 1.000. GLM at `--thinking high`: T1 19/19 tests (52.6 s, 35 turns, $0.112), T8 24/24
(84.9 s, 19 turns, $0.166); no gain over medium.

**Saturation caveat.** The suite saturated, so it cannot separate the models on capability. "GLM
equals Sonnet" holds only for small, well-specified, single-repo tasks; B-report says this is the
biggest limit on trusting the result. It does separate them on process:

| Arm | Median wall | Median turns | Mean output tok | Mean list $/run | Total list $ (19) | Edit-tool errors / calls |
|---|---|---|---|---|---|---|
| Sonnet | 16 s | 4 | 2,975 | 0.059 | 1.13 | 1/3 |
| GLM | 24 s | 13 | 8,117 | 0.079 | 1.50 | **23/117 (19.7%)** |
| Gemini | 199 s | 28 | 25,008 | 0.282 | 5.35 | 9/86 (10.5%) |

Geometric-mean ratios vs Sonnet over the 9 tasks:

| Arm | List cost | Wall | Turns | Output tokens |
|---|---|---|---|---|
| GLM | x1.09 (0.53-2.09) | x1.86 (0.95-3.88) | **x3.57** (1.86-7.25) | x2.01 |
| Gemini | **x4.95** (3.03-8.31) | **x11.84** (6.86-19.2) | x7.32 | x8.39 |

- **Why GLM takes more turns.** Sonnet batches parallel tool calls into 3-5 turns and mostly edits
  via bash and `write` (37 bash, 12 read, 4 write, 3 edit calls total); GLM makes 117 edit and 117
  read calls over 13-16 turns per run. GLM was cheaper than Sonnet on T4, T5, T6 and T9, and 2.1x on
  T8.
- **GLM's edit errors** are hashline syntax slips (`PUT 16.>:`, `PUT 22*=:`, `@@` headers, missing
  `[PATH#TAG]`); 3 were copies of the `edit` tool description's own `greet.py` example. GLM recovered
  every time and none caused a failed task. Gemini's were mostly `PUT N*:` on a single-line block.
- **Gemini's cost.** TTFT median about 3.0 s (GLM about 0.8 s, Sonnet about 1.1 s); wall up to 629
  s on T8; 31 `todo` calls; cache-write 0 and about 181K uncached input tokens per run.
- **Scope creep:** 0 runs for all three arms. Diff size (mean changed lines): Sonnet 141, GLM 197,
  Gemini 249, mostly longer tests and comments.

**Blind code-quality review.** Judge `xai-oauth/grok-4.7` at medium thinking, no tools, arms shuffled
as A/B/C, diffs and prompt only (18 judged sets):

| Arm | Correctness | Readability | Minimality |
|---|---|---|---|
| Sonnet | 8.61 | 7.94 | 9.11 |
| GLM | 8.94 | 8.44 | 8.56 |
| Gemini | 8.72 | 8.11 | 7.56 |

GLM scores at least as well as Sonnet on correctness and readability; Sonnet is the most minimal,
Gemini the least. One judge, n=18 per arm: differences under about 0.5 are noise. Largest per-task
gaps: T9 readability Sonnet 9.0 vs GLM 6.5; T7 readability Sonnet 5.0 vs GLM 9.0.

**Strict-T8 false-success note.** Under the final graders no run failed a hidden test, so there are
0 false-success claims. Under the original strict T8 grader, 6 of 10 T8 runs failed one or two tests
and every one reported "all green" (Sonnet 2 of 3, GLM medium 2 of 3 plus a GLM high run, Gemini 1
of 3). The three strict checks concerned expiration counts and `loads` semantics, where the spec is
ambiguous, and were relaxed after the fact. Read them as "confident success claims that missed spec
details", not as true false success, and note that they hit all three arms.

Other caveats: `omp -p` uses the main-agent prompt, not the bundled task-subagent prompt; Sonnet ran
at medium only; judge scores come from a single model.

### Real-task replays (C)

Four real Sonnet `task` assignments from the last 30 days, replayed with each model's own run
(`omp -p ... --append-system-prompt worker_role.txt`, `--thinking medium`; GLM and Gemini n=2, Sonnet
original plus one rerun on B and D). Start states for A and B were reconstructed from transcripts.
A, B and C carried "do not run tests/builds"; D allowed tests.

| Replay | Arm | Turns | Wall s | List $ | Edit errors | Correctness |
|---|---|---|---|---|---|---|
| **A** Luau impl + tests | Sonnet orig | 5 | 35 | 0.171 | 1 | Compiles, own tests pass |
| | GLM r1 | 5 | 78 | 0.124 | 0 | **Syntax error** (3 comment lines began `-` not `--`); fixed, passes Sonnet's suite |
| | GLM r2 | 15 | 83 | 0.142 | 0 | **Syntax error** (invalid type) **and logic bug** (`for _, source, candidate in candidates`) |
| | Gemini r1 / r2 | 8 / 9 | 285 / 243 | 0.236 / 0.220 | 0 | Compiles; all test cross-checks pass |
| **B** Swift refactor + pbxproj | Sonnet orig / rerun | 8 / 7 | 48 / 36.5 | 0.143 / 0.153 | 1 / 1 | Reference; rerun 12/12 tests |
| | GLM r1 / r2 | 14 / 10 | 39 / 60.5 | 0.105 / 0.103 | 1 / 0 | Helper and `ShareViewController.swift` byte-identical to reference (r1); reference tests pass |
| | Gemini r1 / r2 | 34 / 35 | 284 / 253 | 0.341 / 0.408 | 0 | Same quality; reference tests pass |
| **C** docs / metadata | Sonnet orig | 4 | 29 | 0.190 | 0 | 17/17 checklist |
| | GLM r1 / r2 | 6 / 19 | 54 / 49 | 0.109 / 0.119 | 0 | 17/17 both |
| | Gemini r1 / r2 | 28 / 20 | 250 / 184 | 0.268 / 0.199 | 0 | 17/17 both |
| **D** Dart bug fix + tests | Sonnet orig / rerun | 19 / 16 | 178 / 85 | 0.517 / 0.324 | 1 / 1 | Commit `45d11f4`; rerun 31 tests pass, analyze clean |
| | GLM r1 / r2 | 61 / 60 | 284 / 250 | 0.856 / 0.828 | 3 / 3 | 9-10 files; own tests and analyze pass; reference tests fail (1 / 3) |
| | Gemini r1 / r2 | 91 / 101 | 891 / 949 | 1.216 / 1.358 | 1 / 0 | 8 files; own tests pass; reference tests fail (2 / 2) |

**Reading by replay.**

- **A (Luau, cannot run code): GLM shipped code that does not load in both runs** (2/2 syntax
  errors, one with a logic bug as well). Gemini compiled and passed all cross-checks but took
  243-285 s with one 204 s hidden-thinking turn and 36-40K output tokens for a small change.
- **B (Swift) and C (docs/config): GLM equal on correctness**, about 0.6-0.8x Sonnet's list cost and
  about 1.0-1.7x its wall time.
- **D (Dart bug fix): over-engineering.** Sonnet recognised that an engine-disabled task is already
  distinguishable from a source-stated past deadline and fixed the engine only (3 files). GLM and
  Gemini all added a new persisted `engineMarkedPastDeadline` field touching model, repository,
  hierarchy service and review screen (8-10 files). Their own tests pass, but the reference tests
  build "disabled" tasks without the marker, so the new design never restores tasks already persisted
  as disabled. The assignment allowed a marker ("if the model can't tell them apart today"). GLM took
  about 3.5x Sonnet's turns and about 2.6x the list cost of the Sonnet rerun (about 1.6x the
  original). Reference tests are Sonnet's own, so they favour its design.
- **Gemini** was correct on A, B and C but 3-11x slower than Sonnet; TTFT 3.0-4.8 s, single-turn
  stalls of 90-204 s on A and D from hidden thinking, buffered output (66 of 91 turns on D r1 arrived
  as one chunk), and 91-101 turns on D versus 7-8 for Sonnet on B.

**Process problems disclosed by C:** a first GLM B run read the real repo and copied the existing
Sonnet solution (invalid, rerun on a sterile copy); a first GLM C run had the real repo path in its
prompt and overwrote `README.md` and `CHANGELOG.md` there (restored with `git checkout`, clean at HEAD
`20a9d8e`). Both are why final runs use sterile `git archive` copies with the path rewritten.

**Caveats.** n=2 per cell on n=4 tasks; the C checklist is the evaluator's, not human review; some
runs overlapped in time; Gemini's "list $" is catalog-computed. C-report's verdict: GLM is adequate
for spec-driven doc/config edits and mechanical refactors, not safe for code written without
verification or judgment-heavy bug fixes; with no way to run code (as in the original assignments),
syntax defects land on the orchestrator.

### Research and verification (E)

Seven tool-grounded read-only tasks written like assignments (web fact-finding with traps and an
unanswerable question, `omp://` doc questions, repo investigation, six claims with three subtly false,
8 file:line quote citations, a hard web tier with a false premise, a hard cross-file computation with
empty-set answers as hallucination bait). 14 runs per arm, `--tools read,grep,glob,bash,web_search`,
read-only by construction, cold cache every run, zero errors or truncated JSON in all 42 runs.

**All saturated.** Every arm: accuracy, citations, "unknown" honesty and false-premise handling at or
near 100%.

| Per 14 runs | Sonnet | GLM | Gemini |
|---|---|---|---|
| Fabricated facts / URLs | 0 | 0 | 0 |
| False verifications (false claim called true) | 0 | 0 | 0 |
| Explicit "unknown" on trap questions | 4/4 | 4/4 | 4/4 |
| False refutations | 1 | 0 | 0 |
| Non-verbatim / miscited quotes | 1 | 1 (+1 over-attribution, +2 JSON-escape artefacts) | 0 |

- The AA Omniscience gap (GLM +6.0 vs Sonnet +30.5) **did not show up** as fabrication or false
  verification in any run. [INFERENCE] It may still bite on memory-only answers, no-tool answers, or
  long unverifiable OSINT chains; this test did not probe those.
- Sonnet's one false refutation was an `omp grep` output truncated mid-row, so the true claim was
  never read in full: a tool-truncation hazard that applies to any model.
- **Effort per run** (mean of 14): Sonnet 4.6 turns / 25 s / $0.171 / 127k prompt tokens / 2.8k out;
  GLM 8.0 / 55 s / $0.090 / 201k / 5.8k; Gemini 27.5 / 196 s / $0.228 / 1003k / 16.8k. GLM vs Sonnet:
  **1.7x turns, 1.6x prompt tokens, 2.1x output tokens, 2.2x wall, about 0.53x list cost** (per task
  0.34-0.76; A-report's base repricing gives 0.67). Gemini: 6x turns, about 8x prompt tokens, **7.7x
  wall**, 1.3x list cost, TTFT p50 4.7 s (p90 7.9 s, max 31 s), 9 of 385 messages over 30 s.
- **Blind pairwise (grok-4.7, n=2 per task per pair):** web fact-finding GLM beat Sonnet 1-0 (+1 tie);
  on citation-grounded synthesis (T5) Sonnet beat GLM 2-0 and Gemini beat GLM 2-0. GLM's facts were
  looser. Weak signal.

## Integration with GLM as task primary (D)

Parent `omp -p --config <overlay> --model google-antigravity/gemini-3.8-flash --auto-approve --mode
json`, overlays changing only `modelRoles.task`/`task.structured`/chains. **All five checks and a
12-way stress run passed; no GLM-specific integration failure found.**

| Check | Result |
|---|---|
| Parallel batch of 3 edits | PASS: all three subagents on `mistral/zai-glm-5-3`, 2.8-4.2 s, exact diffs |
| 12 parallel subagents | PASS: all correct in 15.9 s wall, 0 errors, TTFT median 926 ms |
| Structured output | PASS with `structured: true`; `yield` and schema-retry compliance worked |
| ~218K-token context | PASS: 7 files read in full, all 7 needles and line counts correct, 17 turns, 71 s, about $0.58 |
| Image in a subagent | PASS via `read` then `read <img>?q=` (below) |
| Role resolution | `session_init` shows `resolvedModel: mistral/zai-glm-5-3` for every subagent |
| Forced failover | PASS: dead primary returned 410, `model_change role: fallback` to GLM within 0.3 s |

**Risks recorded by D:**

1. **Shared Mistral allowance.** Each subagent is cheap ($0.0015-0.009 per small turn, about $0.58
   for one 218K-token run), but fan-out plus long contexts draw the pool shared with `default`, the
   server and Vibe CLI. No meter exists in OMP.
2. **GLM is both primary and the third hop of the live task chain.** On Mistral exhaustion the chain
   would retry GLM at hop 3 before reaching Grok. If GLM becomes primary, remove it from the task
   chain (see Options).
3. **Spawn-time uncredentialed primary does not walk the chain.** With an uncredentialed task primary
   the subagent ran entirely on the **parent** model (no error, no chain). If the Mistral login
   expired, task subagents could silently run on the parent, which is Sonnet or Opus when the parent
   is (Claude Max). Observed with a `groq/` primary with no key; an expired Mistral login not
   tested.
4. **Structured output is off by default** (`task.structured` false): the per-call `outputSchema` is
   not exposed to the parent and only agents with `structured: true` (or workpool/eval agents) get
   `yield`. Independent of GLM, but schema-dependent workflows need `task.structured: true`.
5. **A fallback re-resolves auto thinking** (low to high in the 410 test), which can raise cost on
   trivial fallbacks.
6. **GLM-5.3 has no vision of its own;** image work depends on the vision role (below). One repeat
   each for long context and the 12-way run; the 1M window and 131K max output are catalog-level.
7. **Async delivery warning** ("Yield queue entry became stale: async-result", 10 entries on 11-03)
   in some headless parent runs; results were recovered through `wait` snapshots. [INFERENCE] a
   harness race, not GLM-specific.

**Image handling (verified 2026-11-03, GLM-5.3 main session, image attached with `@file`).** Because
GLM-5.3 is text-only, how the request is worded decides whether it works:

| Prompt | Behaviour |
|---|---|
| "What is in this image?" | GLM cannot see it; falls back to decoding pixels with Python/OCR (slow, about 10 tool calls, unreliable on real screenshots) |
| "Read the attached image with the vision model ..." | **Same fallback; does not work** |
| "Use the read tool on the attached image and tell me ..." | Works: `read` on the attachment (stored as `local://image-<hash>.webp`) returns the hint, then `read <path>?q=<question>` is answered by the `vision` role (Gemini 3.8 Flash) and the answer is correct |
| "Ask the vision model about shapes.png ..." | Also worked (3 reads) |

The working pattern is to name the `read` tool and the file, not "the vision model". In subagents GLM
used `read` then `?q=` unprompted after reading the file (D check 4). Each image question costs an
extra vision-role call on the Gemini accounts and meters (F section 7).

## Usage and cost

### Mistral allowance (A)

GLM-5.3 reprices this Mac's 30-day task turns at Mistral rates ($1.4 input / $0.14 cached / $4.4
output per million; Sonnet cache read mapped to the cached rate, Sonnet input plus cache-write to
uncached input, no cache-write fee at Mistral). **No Mistral turns exist in the DB**, so token
counts use the `/tmp/omp-default-analysis/results` probes (GLM counted about 0.64x tokens per turn
but took more turns; per-task total prompt tokens GLM/Sonnet 1.29, 1.05, 0.77, 0.63, mean about 0.93,
n=4 **[INFERENCE: tiny sample]**).

| Scenario (task alone, 30 d) | Assumption | $/month |
|---|---|---|
| Optimistic | GLM 0.65x tokens, 1.0x turns, 96% cache hit | 30.45 |
| **Base** | Same tokens, 96.2% hit | **42.75** (scout $3.07 more) |
| Cache hit 90% | | 57.25 |
| Pessimistic | 1.5x turns, 85% hit, no tokenizer credit | 103.52 (scout $4.85) |

Calendar-month history under base: Oct $33.2 (1577 turns), Nov 1-3 $9.6, Sep about $11 and Aug about
$27 (terra tokens, rough): $11-43/month. Worst day 10-24: $14.66 base, $36.90 pessimistic. E's
measured 0.53x list ratio on short cold-cache runs is consistent with GLM staying below Sonnet unless
Mistral's cache hit rate is low **[INFERENCE: n=14]**. B's rough scaling (about 500 benchmark-run
equivalents at $0.08) gives about $40/month, about 27% of $150, also consistent.

**Against the $150 Vibe Code allowance** (total = default + task x m, m = fleet multiplier for unseen
server traffic; $5.35 already used on 11-03; "default" is $4.65 for v38 default-only use or $92 for
living on the default, from `DEFAULT-ROLE-EVALUATION.md`):

| default $ | Scenario | x1 task / total (%) | x2 | x3 |
|---|---|---|---|---|
| 4.65 | optimistic | 30 / 35 (23%) | 61 / 66 (44%) | 91 / 96 (64%) |
| 4.65 | **base** | 43 / 47 (32%), headroom $103 | 86 / 90 (60%), $60 | 128 / 133 (89%), $17 |
| 4.65 | pessimistic | 104 / 108 (72%) | 207 / 212 (141%) over | 311 / 315 (210%) over |
| 92 | optimistic | 30 / 122 (82%) | 61 / 153 (102%) over | 91 / 183 (122%) over |
| 92 | base | 43 / 135 (90%), headroom $15 | 86 / 178 (118%) over | 128 / 220 (147%) over |
| 92 | pessimistic | 104 / 196 (130%) over | over | over |

Task alone is 20-28% of the allowance at x1 base-or-better, 57% at x2, 85% at x3. Mistral Vibe CLI
use is not included. A-report's verdict: moving `task` is affordable only if default use stays low
(about $5/month) **and** server plus Vibe stay at or below about 2x this Mac; if the default is used
heavily it breaks at x2 even on base. Exhaustion means HTTP 402 and starves every Mistral fallback
hop for the rest of the month (`DEFAULT-ROLE-EVALUATION.md`); the 402 itself was not reproduced.

### Anthropic relief (A)

Share of local Anthropic usage (30 d, 3260 turns, $236.5 API-equivalent):

| Slice | % of turns | % of API-$ |
|---|---|---|
| Main Opus | 30.4 | 62.6 |
| **Task subagents** | **57.8** | **26.6** |
| Main Sonnet | 4.7 | 4.9 |
| Scout | 4.2 | 2.7 |
| architect + critical + sage | 2.7 | 3.3 |

Last 7 days (1021 turns, $119.6): Opus main 44.4% of turns / 79.9% of $; task 48.2% / 15.9%; scout
6.7% / 3.4%. **Moving `task` off Anthropic removes about 58% of Anthropic turns but only about
16-27% of weighted (API-$) usage; Opus main is the heavy meter driver.**

Meter calibration is weak (usage endpoints expose only `anthropic:5h`, `:7d`, `:7d:fable`; per-interval
5h R2 0.26, 7d R2 below 0; 1% quantisation), so these are **[INFERENCE, low confidence]**. Best
evidence is the 10-24 window (734 Sonnet task turns, zero Opus, $28.5): 5h 0 -> 0.47, 7d 0 -> 0.07,
about 1.6 pp 5h per $ and 0.25 pp 7d per $. If task ($63 of Sonnet in 30 days) left Anthropic, relief
would be about 17 pp of 7d summed over three active weekly windows (about 3.5, 11 and 4 pp each;
local weekly peak 53%, never binding) and about 100 pp of 5h summed over six active days. At the local
5h peaks: 10-24 0.47 -> about 0.12 (task 74% of window $), 10-21 0.41 -> about 0.19, 10-26/27 0.82 ->
about 0.62 (Opus-driven).

**Critical caveat.** The high Anthropic peaks are not local: 5h 0.70 (10-12) and 0.93 (10-13) and 7d
0.47 (10-13) occurred with **zero** local Anthropic turns; 7d on 11-03 read 0.46 with only about $22
local since the 10-31 reset. The server or other clients drive the meter peaks. Whether the server's
task subagents run on Sonnet is unknown; relief there depends on the same config being shared, which
it is.

### Gemini 3.8 Flash as task primary: meters and list cost (F)

Meter numbers are percentage points (pp) of the Google/Gemini counters; calibration is low to medium
confidence (1% quantisation, lagged samples, unseen server/IDE traffic in every interval).

- **Calibration per turn** (author's scenarios): L 0.03 pp 5h / 0.0095 weekly; M 0.075 / 0.02; H
  0.15 / 0.03. Sources: clean Oct data (128 turns, 5h +3.2 pp, weekly +1.22 pp), the 09-17 burst
  (476 turns at about 240k prompt: 5h +73 pp, weekly +12.2 pp), the probe (131 turns, 5h +3.84,
  weekly +0.98). `high` thinking cost about 5.4x low on 5h and 8.6x on weekly; auto-thinking can pick
  `high`.
- **Weekly (main account, worst case all turns land on main).** Average week 452 turns: 4.3 / 9.0 /
  13.6 pp (L / M / H) at x1; last 7 d 492 turns: 4.7 / 9.8 / 14.8; worst week 1056 turns: 10.0 / 21.1
  / 31.7 (63.4 at x2 under H). Only worst week at x3 under H plus a bad baseline nears the cap.
- **Burst (5h).** 10-24, 719 turns in 33 min: 21.6 / 53.9 / 107.8 pp at x1. The 5h window binds only
  under H, or under M if the burst coincides with a baseline near 0.3; the default 10% reserve trips
  at roughly 540-600 turns under H. At 21 turns/min a per-minute Google limit is a risk with no data;
  a 429 `RESOURCE_EXHAUSTED` was seen on 09-16 while the 5h meter read 0.53.
- **Rotation across the four free Antigravity accounts is real.** 326 `gemini-3.8-flash` messages
  since 09-28 carry `credentialId`: main (cred 1) 98 (30%), free accounts 228 (70%: cred 10 116, cred
  8 88, cred 7 24; cred 9 none). Each session stays on one credential (0 of 10 switched). On 10-18,
  123 local turns moved main weekly +1.3 pp while the free meters rose; on 09-17 a 476-turn burst
  exhausted all four free accounts (0.94 / 0.91 / 1.00 / 0.996) and main reached only 0.465. `omp
  usage` shows the router treating all five accounts as one pool (4.04x quota left on 7d). Free
  accounts report only a weekly meter; consumption about 0.33-0.5 pp/turn, so roughly 200-300
  turns/week each and 800-1,200 across four at 50-240k prompts. That covers an average task week at
  x1 and about half at x2. The selection rule could not be recovered from history **[INFERENCE]**, and
  free meters also include unseen usage.
- **Meter fallback.** `retry.usageAwareFallback: true` with `usageReservePolicy: auto` is in the live
  config, so near the reserve OMP prefers healthy same-provider accounts and then the chain.
- **List cost.** Gemini 3.8 Flash at $0.75 / $0.075 / $3.75 per million, 30 d / 1939 turns:
  **$25.31** ($28.55-$31.80 if output is 1.5-2x); 7 d $7.27; 10-24 $8.70; 11-03 $5.71; Sonnet DB
  figure $63.63. Cache-hit sensitivity: 96.2% $25.27, 90% $33.08, 80% $45.68, 50% $83.47. The
  Antigravity plan is a quota, not per-token billing, so these are comparison figures only.
- **Correction to A-report:** its "Flash $" column (30 d task 7.32, 7 d 2.05, scout 0.44) used
  **GLM-5.3-Flash** prices ($0.15 / $0.03 / $0.5), not Gemini 3.8 Flash. Use F's Gemini figures
  above; A's GLM-5.3 base ($42.75/month) is unaffected.
- **Correlation with the default chain.** A Mistral 402 sends `default` traffic to Gemini 3.8 Flash
  first, and Gemini is also `vision` primary, so a Gemini task primary and GLM subagent image
  questions would sit on the same meters at the same time.

## Options

| Option | For | Against | Verdict |
|---|---|---|---|
| **Keep Sonnet 5.5 primary (current v38)** | Fastest on every replay and benchmark (16 s median vs 24 s GLM, 199 s Gemini); fewest turns; smallest diffs; ran code-writing tasks without syntax defects; no new dependency | Task is 58% of local Anthropic turns but only about 16-27% of weighted use; Opus main is the real driver, so relief is limited; does not use the Mistral allowance or Gemini free accounts | **Chosen by the owner (2026-11-03)** |
| **GLM-5.3 primary, Sonnet 5.5 first fallback, GLM hop removed from the chain** | Correct on all 19 benchmark runs and 14 research runs; 0 fabrications; about 0.53x Sonnet list cost on research, about 1.09x on the synthetic suite; integration passes (parallel, 218K context, structured, failover); base spend about $43/month, 32% of $150 with default-only use | 1.7x-3.6x the turns, 1.9x-2.2x wall; 19.7% edit-error rate (recoverable); replay A shipped non-loading Luau code twice, replay D over-engineered; shares the allowance with default, server, Vibe CLI (breaks at x2 if default is heavy); spawn-time uncredentialed primary silently runs on the parent; text-only (image via `read ?q=`) | **Not chosen (2026-11-03).** Revisit if Claude Max binds; needs the chain edit below and a plan for syntax verification on code-writing tasks |
| Gemini 3.8 Flash primary | Correct on all three evidence sets (19/19, replays A-C, 14/14 research); list cost about $25/month; main weekly meter fits; four free accounts rotate; Claude-free | 3x-12x slower than Sonnet (199 s vs 16 s median benchmark wall; 3-11x on replays; 7.7x on research); 4.95x list cost in B; 27.5 turns vs 4.6 in E; stalls of 90-204 s; buffered output; per-minute rate risk at 21 turns/min; correlated with vision and a Mistral-402 default fallback | **Rejected for speed** |

Detail of the GLM-primary shape, kept for a future revisit (not applied):

- `modelRoles.task` -> `mistral/zai-glm-5-3`.
- `retry.fallbackChains.task` -> `anthropic/claude-sonnet-5-5` first, then the existing non-GLM
  entries; drop `mistral/zai-glm-5-3` from the chain (D risk 2: it would be retried at hop 3 on
  exhaustion). Sonnet first fallback puts the Claude pool back on the path only when Mistral fails;
  the replay-A cost (non-loading code) is not removed by the chain, which only walks on provider
  errors.
- Consider `task.structured: true` if any workflow depends on per-call `outputSchema` (D risk 4).
- Add a verification step for code-writing tasks in assignments (C: "run a verification step for
  syntax/type errors").
- Keep Sonnet where assignments are ambiguous (B pool-relief note). **[INFERENCE]** C did not test
  any partial-routing mechanism, so per-assignment routing by category is untested.

## Risks and what would change the answer

Risks of the current evidence:

1. **Saturation.** B and E both saturated at 100% for every arm; they show "no detectable gap", not
   "equal in general". Real replays (n=4 tasks, n=2 per cell) are the only discriminating evidence and
   are too small for statistics.
2. **One operator, one repo mix.** The task mix is mostly Flutter feature and bug work in Parent-help
   (164 of about 280 task sessions per C) plus doc/config edits and side repos.
3. **Unseen server traffic.** Mistral and Anthropic meters both include traffic from the Ubuntu server
   that this Mac's logs do not show; the x2/x3 multipliers are assumptions, not measurements.
4. **Mistral 402 not reproduced** and Mistral has no OMP meter; exhaustion would starve every Mistral
   hop for the calendar month.
5. **Meter calibration** (Anthropic and Google) is low confidence; Anthropic relief numbers are
   explicitly **[INFERENCE]**.
6. **Wall times** came from runs with 2-5 parallel jobs; Sonnet-original replay times exclude
   startup.
7. **Not tested:** Sonnet at high/max, GLM on ambiguous long-horizon work, a persistent Mistral 402, an
   expired Mistral login at spawn, image-heavy task assignments (A found 0 image reads in the task
   list, not exhaustively checked).

What would change the answer:

- A syntax/type check step that catches replay-A-class defects cheaply, making GLM's code tasks
  safe, favours GLM primary.
- A measured server share showing the allowance at x3 or default usage near $92 would rule GLM
  primary out (A table: over 100%).
- Evidence that Anthropic meter peaks are task-driven rather than Opus- or server-driven would raise
  the value of moving off Sonnet; the current data says they are not.
- A reproduced 402 that does not walk the chain, or an expired Mistral login that silently
  promotes subagents to the Opus/Sonnet parent, would weigh against GLM primary.
- Gemini reaching Sonnet-class speed in OMP (TTFT near 1-1.5 s, turns near Sonnet's) would reopen
  the Gemini option; today TTFT is 3.0-4.8 s with hidden-thinking stalls.
- Further replays on the actual workload mix with more than n=2 per cell.

## Sources

Reports (scratch, uncommitted), all under `/tmp/omp-task-eval/`:

| File | Content | Scripts / artefacts |
|---|---|---|
| `A-report.md` | Workload mix, repricing, Anthropic relief | `A/` (`an1.py`, `model.py`, `share.py`, `reg.py`, `peaks.py`, `cal3.py`, `sess.py`, `cat.py`, `RESULTS.md`, `assignments/*.txt`) |
| `B-report.md` | Synthetic hidden-test benchmark, 3-way | `bench/` (`bench.py`, `regrade.py`, `judge.py`, `report.py`, `aggregate.py`, `tasks/`, `results/`, `judge/`, `RESULTS_tables.md`, `aggregate.txt`, `COMMANDS.md`, `results_t8_strict/`) |
| `C-report.md` | Real past-task replays, 3-way | `replay/` (`run_replay.py`, `agg.py`, `artifacts/*.diff`, `out_*.metrics.json`, `worker_role.txt`) |
| `D-report.md` | Subagent integration with GLM | `integ/` (`ovl*.yml`, `repo1`..`repo8`, `run1`..`run10.jsonl`, `sess*`, `show.py`) |
| `E-report.md` | Research/verification quality, 3-way | `E/` (`RESULTS.md`, `prompts/t1-t7.txt`, `runs/*`, `scores.json`, `score.py`, `agg.py`, `judge.py`, `key3.json`, `key7.json`, `repo-snap/`) |
| `F-report.md` | Google meter model, account rotation, Gemini list cost | `F/` (`cal.py`, `reg.py`, `free.py`, `cred.py`, `wl.py`, `cost.py`, `RESULTS.md`) |

Earlier context: `/tmp/omp-default-analysis/` (probe scripts and `results/`) and
`DEFAULT-ROLE-EVALUATION.md` for the default role, the Mistral allowance correction and the 402
behaviour; `MISTRAL-EVALUATION.md` for plan facts. The image findings are from a live GLM-5.3 main
session on 2026-11-03.

**Method.** One orchestrator, six research items, each run through `omp -p --no-session
--auto-approve --mode json --model <sel> --thinking medium` in fresh working copies; hidden graders
and reference solutions validated as described under B. API keys were not printed; no `~/.omp` file
was edited by this document, and `model-roles.yml` was not changed.
