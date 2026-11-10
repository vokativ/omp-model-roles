# `review` role: Gemini 4 Argon vs Sol 6.1 on real PRs — 2026-11-10

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root,
one level up.*

Written 2026-11-10 against snapshot v38. Question from the owner: does Google's Gemini 4 Argon
(`google-antigravity/gemini-4-argon`) belong in `review` or `critical` instead of Sol 6.1
(`openai-codex/gpt-6.1-sol`), or even in `default`? This evaluation **ran a contamination-free
benchmark on 11 real PRs**, calibrated Argon's weekly meter, and mined both machines' sessions. It
also records two setup incidents found on the way (omp 18.18.6 losing the Antigravity provider, and
omp's Codex meter disagreeing with the ChatGPT account). **`model-roles.yml` is unchanged.**

Raw data: `~/pr-bench/` on `nemanja-lubuntu` (`cases.json`, `results.jsonl` 101 rows,
`grades.json` 99 grades, `run.log`, `run.py`); not committed. **[INFERENCE]** marks anything not
read directly from a source.

---

## Decision

- **Keep `review` on Sol 6.1, Argon as its first fallback. Keep `critical` on Sol 6.1. No Argon in
  `default`.** Owner has the recommendation; no config change made.
- **Why.** On 11 real regressions Argon tied Sol on detection (repo mode 6/11 each), but took ~1.9x the
  wall time and 3x the turns, timed out once, and costs ~5% of its weekly allowance per agentic
  review, so it cannot carry the ~21 reviews/week this machine runs.
- **The real threat to Sol reviews is omp's Codex usage preflight**, which skipped Sol on a meter
  reading the owner's ChatGPT page contradicts (section below), not Sol's quality.

## Prior evidence (before the benchmark)

| | Argon (high) | Sol 6.1 (high / max) |
|---|---|---|
| Release | announced 2026-09-30, GA 2026-10-13 | 2026-09-29 |
| AA Index v5.0 | 50.4 | 50.2 / 54.5 |
| Terminal-Bench 4.0 | 57.1 | 51.5 / 56.1 |
| FrontierCode 2.0 | 25.7 | 36.7 / 40.6 |
| Omniscience (net) | +46.1 | +42.0 |
| LMArena text | #2 (1520) | #27 (1481) |
| OMP tool task (2026-11-03) | 26.7 s, TTFT 5.2 s | 44.8 s (n = 1, medium) |

Sources: `MISTRAL-EVALUATION.md` (AA), `DEFAULT-ROLE-EVALUATION.md` (probe).

**Argon meter calibration (omarchy `usage_history`, `gemini-argon-wtu-weekly`).** 2026-10-30: 93
Argon turns moved it 0 -> 37.2%. 2026-11-03: 180 turns moved it 37 -> 100% (status `exhausted`, the
day Plus read 95-100% and work spilled onto Argon). 2026-11-06: 99 turns moved 4.3 -> 35%. So
roughly 280-320 Argon turns per week **[INFERENCE: three days of deltas]**.

**Review volume (omarchy, 21 days to 2026-11-10).** `review` on Sol: 62 sessions, 785 turns
(12.7/session); `critical` on Sol: 59 sessions, 824 turns. That is ~262 + ~275 Sol turns/week.
`critical` fell over to Argon twice (2026-11-05, PR #94): both produced a valid structured `yield`,
but took ~38 turns each vs Sol's 14.

**Synthetic planted-bug diff (2026-11-10).** 5 planted bugs (SQL injection, TOCTOU race, false
success after rollback, off-by-one, mutable default) plus two correct changes, no tools, thinking
high. Every model found 5/5 with 0 false positives. Only Sol also caught an unplanted regression
(`record_audit(sink=None)` now raises): Sol 4/4 runs, Argon 0/5, Sonnet 5.5 0/2, GLM-5.3 0/1.
Argon TTFT 8-14 s vs Sol 2.1-2.4 s; wall 17-28 s vs 22-29 s.

## Real-PR benchmark (2026-11-10, run on nemanja-lubuntu, omp 18.16.0)

**Case selection.** GitHub search for PRs merged 2026-10-28..11-08 that a later PR reverted or named
as the cause of a regression; 14 candidates checked by scout agents against the actual diffs; 3
dropped (openai-agents-js#2291 merge-only build break; PostHog#123644 product revert; harness-pilot#26
test-only). All merges post-date both models' releases.

| PR | Fix | Lang | Ground-truth defect | Difficulty |
|---|---|---|---|---|
| [sleep2agi/agent-network#3394](https://github.com/sleep2agi/agent-network/pull/3394) | #3395 | TS | vars declared inside `if (snap)` read for every row -> `/api/nodes` 500 | easy-medium |
| [supabase/auth#2868](https://github.com/supabase/auth/pull/2868) | #2912 revert | Go | repeat signup overwrites unconfirmed user's password -> pre-account takeover | medium |
| [nurockplayer/tachiko-fleetglint#32](https://github.com/nurockplayer/tachiko-fleetglint/pull/32) | #34 | Py | SIGTERM handler installed before the `try` | medium |
| [langfuse/langfuse#19631](https://github.com/langfuse/langfuse/pull/19631) | #19742 revert | TS | prompt-size cap on the read path + overcounting estimate | medium |
| [sunsided/loremaster#183](https://github.com/sunsided/loremaster/pull/183) | #184 | Rust | any open await makes every actor command "refused" | medium |
| [pypi/warehouse#20893](https://github.com/pypi/warehouse/pull/20893) | #20933 | Py | `_remember_device` reads `request.user` (None for frozen accounts) -> 500 | hard |
| [apache/devlake#9288](https://github.com/apache/devlake/pull/9288) | #9326 | Go | generator registers plugins by value; pointer-receiver methods lost | hard |
| [sympy/sympy#30882](https://github.com/sympy/sympy/pull/30882) | #30986 | Py | sign from derivative at integer points; poles break it | hard |
| [arkorlab/upwind#392](https://github.com/arkorlab/upwind/pull/392) | #400 | TS | throwing `process.*` stubs leak via the shared global | hard |
| [peerspan/peerspan#150](https://github.com/peerspan/peerspan/pull/150) | #151 | Rust | signed addresses dialled beside a manual peer hint | hard |
| [gaspardpetit/Docxport.Net#189](https://github.com/gaspardpetit/Docxport.Net/pull/189) | #192 | C# | restarted list never updates shared counter | hard |

**Protocol.** Same prompt for every model (report correctness/security/concurrency/regression defects
with file, severity, explanation; no nits). Two modes:
- **diff**: PR title + description + full diff, `--no-tools`, 2 runs per model per PR.
- **repo**: same, run inside a `.git`-free, read-only checkout of the PR head (no history, so the fix
  commits are unreachable), `--tools read,grep,glob --no-lsp`, 1 run per model per PR.

All `omp -p --no-session --thinking high`. No web access (fix PRs and bot review comments on the
original PRs are public). A run counted only if every assistant message came from the requested
model. Grading: Opus 5.5 (`completion(model="slow")`), blind to model identity, against the ground
truth: found yes/partial/no, severity given, findings claimed, dubious findings. Spot-checked by hand.

**Results (99 graded runs).**

| Model / mode | Runs | Found (all) | Easy/medium (5 PRs) | Hard (6 PRs) | False alarms | Median wall | Median TTFT |
|---|---|---|---|---|---|---|---|
| Sol, diff | 22 | 8/22 (36%) + 3 partial | 6/10 + 1 partial | 2/12 + 2 partial | 15% | 70 s | 2.6 s |
| Sol, repo | 11 | **6/11 (55%)** + 1 partial | 4/5 + 1 partial | 2/6 | 24% | **161 s** (8 turns) | 3.0 s |
| Argon, diff | 22 | 9/22 (41%) | 5/10 | 4/12 | 15% | 157 s | 12.3 s |
| Argon, repo | 11 | **6/11 (55%)** | 4/5 | 2/6 | 23% | **302 s** (24 turns) | 8.7 s |
| GLM-5.3, diff | 22 | 10/22 (45%) + 1 partial | **8/10** | 2/12 + 1 partial | **37%** | 113 s | 2.1 s |
| GLM-5.3, repo | 11 | 4/11 (36%) | 4/5 | **0/6** | 26% | 220 s (24 turns) | 1.6 s |

False alarms = grader-flagged speculative/wrong/nit findings / all findings claimed.

Per case (diff run 1, run 2 | repo; y/p/n):

| PR | Sol | Argon | GLM-5.3 |
|---|---|---|---|
| agent-network | yy y | yy y | nn y |
| supabase-auth | nn p | nn n | yy y |
| fleetglint | yy y | yy y | yy n |
| langfuse | yy y | yn y | yy y |
| loremaster | np y | nn y | yy y |
| warehouse | nn n | nn n | nn n |
| devlake | pp y | yy y | pn n |
| sympy | yy y | yy y | yy n |
| upwind | nn n | nn n | nn n |
| peerspan | nn n | nn n* | nn n |
| docxport | nn n | nn n | nn n |

\* Argon's first repo run on peerspan hit the 25-minute limit after 72 turns with no review; the
retry (60-minute limit) finished in 970 s / 41 turns and missed the bug.

**Reading it.** Sol and Argon tie (33 runs each: Sol 14 yes + 4 partial, Argon 15 yes). With 11 PRs
one case moves a rate ~9 points; the difference is noise. Four hard bugs (warehouse, upwind,
peerspan, docxport) were missed by everyone: they need framework internals or external behaviour
(Word numbering) not in the diff or the repo. GLM-5.3 is strongest on easy/medium diff-only reviews
but has the most false alarms and found no hard bug with tools: keep it as a late fallback.

**Argon quota.** Weekly meter (Lubuntu readings): 2.5% (11:57) -> 23.6% (12:55) -> 52.1% (13:51)
-> 83.5% (15:02) -> **91.4%** (15:19 SGT), about 89 points for 22 diff + 12 repo attempts plus one
killed partial run. Per review: **~1.1% diff-only**, **~5% agentic** on average (~3.6% medium,
~8% hard; the peerspan retry alone ~7.9%) **[INFERENCE: interval attribution]**. ~19 agentic reviews
per week vs ~21 Sol review sessions/week on omarchy alone. Side effect: **Argon is at 91% for the
rest of its weekly window**, above OMP's 10% reserve, so Argon hops in `review`, `critical`, and the
depth chains are skipped until it resets. Sol's cost could not be measured (next section).

## omp's Codex meter and the usage preflight

On 2026-11-10 `omp usage` reported openai-codex **5h 95% / 7d 72%** while the owner's ChatGPT page
showed **22% weekly and low 5-hour use** on the same account. omp's values come from the Codex usage
endpoint (`unit: percent`); why they differ is unknown.

- **Benchmark evidence.** One Sol run was skipped with `Usage preflight: available quota is at or
  below the 10% reserve. No request was sent to the source model for this attempt.` and answered by
  Gemini 3.8 Flash (discarded). The same Sol request with `retry.usageAwareFallback: false` (run-only
  `--config` overlay) was served immediately with no 429; every remaining Sol run used that overlay.
- **Real sessions.** 2026-11-10 12:16 SGT on omarchy, while the live meter read >= 85%: the PR #104
  `review` session and its `Pr104FixReview` subagent switched Sol -> Grok 4.7 with no error (Argon was
  skipped by the 18.18.6 bug below).
- **History.** Error-free Sol -> fallback switches while omp's stored meter read >= 90%: 25 on
  omarchy (2026-10-18..11-03), 23 on Lubuntu (10-13, 10-14, 11-03). Whether the meter was wrong on
  those dates cannot be checked now. Other error-free switches happened with the meter < 80% (cause
  not recorded in session files).

## Setup incidents and changes (2026-11-10)

| Item | Detail | Status |
|---|---|---|
| omp auto-update on omarchy | `~/.omp/agent/config.yml` line 122 `update: auto: true` updated `~/Work/git_different_profiles/shims/omp` 18.18.3 -> **18.18.6** at 09:08 SGT (`~/.omp/update/auto-update.log`). Not Tern: OMP docs say `update.auto` defaults to `false` and is ignored under Tern. Lubuntu has no `update` key (18.16.0) | reported, **not changed** |
| omp 18.18.6 drops `google-antigravity` | `omp models google-antigravity` is empty; every Antigravity selector is skipped with `no credential for google-antigravity` (Argon, Gemini 3.8 Flash, 3.5 Flash-Lite, Antigravity Claude). The 18.18.3 binary at `~/.local/share/mise/installs/github-can1357-oh-my-pi/latest/omp` lists 13 models and serves them with the same login and database. Effect on omarchy: `vision`/`advisor` primaries, `default`'s first fallback, and every Argon hop are dead in new 18.18.6 processes | reported, **not changed** (fix: pin 18.18.3 and set `update.auto: false`) |
| Antigravity re-login | owner re-ran `/login google-antigravity` on omarchy (new credential row, 2026-11-10 11:29); did not fix the above | owner action |
| Model cache | during diagnosis the `google-antigravity` row was deleted from omarchy's `~/.omp/agent/models.db` `model_cache`; the 18.18.3 run rebuilt it (cache v15) | done, self-healed |
| Benchmark scratch | `~/pr-bench/` created on nemanja-lubuntu (read-only PR checkouts, results, grades, logs) | kept as the data record |
| Quota spent by testing | Argon weekly 2.5% -> 91.4%; Codex unmeasurable; Mistral negligible | — |

No `config.yml`, `model-roles.yml`, or agent file was changed on either machine.

## Revisit when

- omp's Codex meter matches the ChatGPT page again (or the preflight can be scoped per provider), and
  omarchy runs an omp build that routes Antigravity.
- Argon's allowance grows enough for ~21 agentic reviews/week with headroom, or Argon beats Sol on a
  larger real-PR set (the 11-case set is reusable: `~/pr-bench/cases.json`).
