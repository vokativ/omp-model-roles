# Fable 5.1 versus Opus 5.5 — `plan` and `architect`

**Web-evidence review: 2026-10-08.** This replaces the contradictory September evaluation. It is selection guidance, not a selector program, a local benchmark, or evidence of this user's Fable access. Sources below distinguish vendor measurements, vendor-reported external results, and independently retrieved evaluator reports. Living pages were observed on 2026-10-08; that is not an invented publication date.

## Decision and withdrawn evidence

**[INFERENCE] Retain Opus 5.5 provisionally for both `plan` and `architect` in the existing Anthropic-heavy alternative.** Public engineering/workflow and professional-analysis proxies generally support that choice at lower API list prices. Fable 5.1 remains a meaningful conditional candidate: its independent rubric-completeness and memorization-discounted coding-correctness results challenge any categorical Opus quality claim. Neither model is a demonstrated OMP role winner.

The existing alternative is unchanged as an evidence-based decision, not because Fable was ignored. This review does not change the current root configuration, models, agents, authentication, or provider routes. **The user has no Fable access: no Fable calls, probes, or local tests were made or are authorized by this note.** Preserve the independent OpenAI `critical` allocation; switching between two Anthropic models does not add model-family independence against an Anthropic producer.

**Withdrawn local claims:** the historical **7.36s / 7.45s** and **<0.1% quota** figures were not Fable measurements. The attempted Fable requests failed and fell back to OpenAI; outputs attributed to Fable therefore did not establish Fable identity. Those invalidated September records are the source of these quoted figures, not a new observation. The former local architecture table, “crisper/faster” conclusion, negligible-quota claim, and validated-local-architect recommendation are withdrawn, not qualified by a footnote. Historical Opus 5 comparisons cannot decide the present **Opus 5.5 versus Fable 5.1** question. Old quota snapshots and fallback configuration examples are not current evidence.

## Exact identities and access boundary

Official overviews identify [Fable 5.1](https://platform.claude.com/docs/en/models/fable-5-1/overview), released **2026-09-01**, API ID `claude-fable-5-1`, and [Opus 5.5](https://platform.claude.com/docs/en/models/opus-5-5/overview), released **2026-09-22**, API ID `claude-opus-5-5` (living docs, observed 2026-10-08). Earlier Fable 5 and Opus 5 are distinct versions.

The [Fable/Mythos announcement and system card](https://www.anthropic.com/claude-fable-and-mythos-5-1) (September 2026; [card dated 2026-09-01](https://www.anthropic.com/claude-fable-5-1-mythos-5-1-system-card)) describe shared weights but different safeguards/access programs. **Mythos is not Fable deployment evidence.** Product capability/creation labels, provider availability, and a catalog name do not prove this user's entitlement, an authorized OMP route, or the delivered model identity.

Anthropic's living [model-selection guide](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model) (observed 2026-10-08) recommends starting most workloads with Opus 5.5 and considering Fable 5.1 when Opus at `xhigh` or `max` still falls short on demanding reasoning/long-horizon work. Its “highest-capability” Fable positioning is not proof of superiority on these two roles.

## Comparable public results — relevant proxies, not role benchmarks

Vendor rows cite the **2026-09-22 [Opus 5.5 system card][card]**. Independent AA rows cite the original **2026-09-22 [Artificial Analysis report][aa]**. Equal effort labels do not establish equal compute, token budget, wall time, or cost.

| Evaluation | Opus 5.5 | Fable 5.1 | Provenance, settings, and limits |
| --- | ---: | ---: | --- |
| Terminal-Bench 4.0 | **64.8%** | **55.8%** | Anthropic, both **max**, Claude Code `--bare`; production safeguards/fallbacks. [Card §8.5, pp177–178][card]. |
| Terminal-Bench-Science 0.1 | **58.7%** | **52.6%** | Anthropic, both max, Claude Code `--bare`; task-clustered uncertainty prevents treating this point gap as decisive. [Card §8.6, pp178–179][card]. |
| FrontierSWE v2 | **62.3%** | **56.3%** | Proximal external result **as reported by Anthropic**, same max/Proximal harness; long-horizon engineering, not read-only architecture. [Card §8.7, p179][card]. |
| CursorBench 4.0 | **57.8%** | **51.8%** | Cursor production harness, both max, **as reported by Anthropic**; not independently fetched experiment evidence here. [Card §8.8, pp179–180][card]. |
| GDPval-AA v2.1 | **1846 Elo** | **1735 Elo** | Original independent AA professional-artifact evaluation, max/default fallback; also reported in [card §8.14.3, p209][card]. [AA report][aa]. Elo is not accuracy percent. |
| AA-Briefcase v1.1 | **1822 Elo** | **1678 Elo in card** | Both max; [card §8.14.4, p210][card]. Original [AA report][aa] says Opus leads by **143 points**, with analytical/presentation leads but **Fable ahead on rubric scoring**; see discrepancy below. |
| Toolathlon-Verified | **77.8% Pass@1** | **77.8% Pass@1** | Anthropic, same internal harness/adaptive thinking/max, classifiers on; workflow/instruction-following tie. [Card §8.14.5, pp210–211][card]. |
| AutomationBench | **40.0%** | **31.4%** | Zapier held-out policy/workflow evaluation **as reported by Anthropic**, both max; no fallback, safeguard intervention fails the task. [Card §8.14.6, pp211–212][card]. |

**Terminal-Bench headline caveat:** the advertised **66.4%** Opus score is at **xhigh**, not the equal-max point above. The card reports **66 tasks**, Opus **five trials/task**, and fallback on **2.5% of requests / 10% of trials**; it does not provide a confidence interval for the **64.8% max** point or specify Fable's trial count in that paragraph ([card §8.5][card], 2026-09-22). Do not combine the headline with Fable's max score as an equal-setting experiment. Production substitutions include Opus 4.8 for cybersecurity and Opus 5 for biology/frontier-LLM development ([card §1.5][card]); deployed-system results are not guaranteed pure named-model outputs throughout. Fable also has safeguard substitutions; Mythos has different safeguards.

**AA discrepancy and interpretation:** the original [AA report][aa] (2026-09-22) gives Opus **1822** and a **+143** Fable gap, while the [card §8.14.4][card] gives Fable **1678**. Do not present **1679**, obtained by subtraction, as an independently reported exact Fable measurement or silently resolve the discrepancy. AA's analytical/presentation lead and Fable's higher rubric result are distinct axes: persuasive, polished output is not necessarily more complete or correct.

Original [AA-Briefcase methodology](https://artificialanalysis.ai/evaluations/aa-briefcase) (observed 2026-10-08) covers realistic professional projects with source-file evidence and separate requirements/correctness rubrics. Each task starts independently with standardized prior artifacts; the “multi-week” framing does **not** demonstrate consistency of a model's own evolving plan across weeks. AA's original report and model pages describe **max/default fallback**; these are independent production-route measurements, not verified all-pure-model trajectories.

Independent AA Terminal-Bench uses a different harness from the vendor table: the original [AA evaluation page](https://artificialanalysis.ai/evaluations/terminalbench-4-0) (observed 2026-10-08) reports Opus max **59.6%** with mini-swe-agent; the original launch article does not supply a paired Fable percentage for that run. It cannot be merged with the Claude Code vendor row.

## Independent evidence and substantive Fable counterevidence

### Mercor: directional support, not a decisive winner

Original benchmark-owner pages were retrieved **2026-10-08**; exact model run dates, full setting/fallback provenance, and pinned run commits were not disclosed in the retrieved pages.

| Original evaluation / requested metric | Opus 5.5 max | Fable 5.1 max | Role relevance and uncertainty |
| --- | ---: | ---: | --- |
| [APEX-Agents 1.1, Pass@1](https://www.mercor.com/apex/apex-agents-leaderboard/?pass=pass-1) | **73.5% ±4.9%** | **68.6% ±4.9%** | Professional banking/consulting/law workflows; overlapping reported ranges. |
| [APEX-SWE, Terminus-2, Pass@1](https://www.mercor.com/apex/apex-swe-leaderboard/?harness=terminus-2&pass=pass-1) | **67.6% ±5.9%** | **63.6% ±6.3%** | Service integration, deployment, observability/debugging; overlapping reported ranges. |

These original Mercor results are independent evaluator evidence, unlike an external result copied into Anthropic's card. Same max and task family support a within-evaluation comparison, not equal resource budgets or a statistically established unique winner. Professional-task proxies are also not wholly separate capability dimensions merely because evaluators differ. See Mercor's [2026-09-08 APEX-Agents methodology](https://www.mercor.com/blog/introducing-apex-agents-1-1/) and [2026-03-24 APEX-SWE introduction](https://www.mercor.com/blog/introducing-apex-swe/).

### Endor Labs: correctness ordering matters

The original **2026-09-24 [Endor Labs experiment][endor]** is repository patch generation, not a measured plan-only, architecture-review, or security-review role. It executed **200 tasks**, scoring **179** after excluding overly strict/trap instances. Functional and hidden security tests were combined with trajectory-based recall/cheating detection and **LLM adjudication**; scores below apply the authors' memorization deductions.

| Memorization-discounted metric | Opus 5.5 | Fable 5.1 | Source |
| --- | ---: | ---: | --- |
| FuncPass: functional correctness | **68.7% (123/179)** | **87.2% (156/179)** | [Endor, 2026-09-24][endor] |
| SecPass: functional AND security correctness | **33.5% (60/179)** | **37.4% (67/179)** | [Endor, 2026-09-24][endor] |

**Material limits:** Claude Code versions differed: Opus **2.1.280**, Fable **2.1.258**; effort/temperature were not stated. Without recall deductions, the functional/security ordering favors Opus, so adjudication materially affects the result. Endor reports no smaller-model fallback for Opus, but that does not make the mismatched agent setups a controlled pure-model architecture study ([Endor, 2026-09-24][endor]; [methodology, 2026-04-15, updated 2026-05-07](https://www.endorlabs.com/learn/agent-security-league-evaluating-the-security-of-ai-coded-software)).

Fable's substantial functional-correctness edge is a real reason to preserve it as a conditional option for correctness-sensitive work. The narrower security gap in this experiment does not prove a universal Fable security-review or architect advantage. Nor can fast completions associated with recalled solutions be treated as superior reasoning.

## Performance, effort, and API prices are different ledgers

The original [AA report][aa] (2026-09-22) reports approximately **119k Opus versus 78k Fable output tokens per Intelligence Index task at max**. That is more output for Opus in this workload, whereas Endor's patch-generation workload reports the opposite direction. Live [Opus](https://artificialanalysis.ai/models/claude-opus-5-5) and [Fable](https://artificialanalysis.ai/models/claude-fable-5-1) AA pages (observed 2026-10-08) distinguish decoding speed from first-answer latency; page-labelled “TTFT” includes reasoning in the chart interpretation. These are not OMP role latencies. **No universal faster, less-verbose, or lower-per-task-cost claim follows.**

Both models support adaptive thinking and low/medium/high/xhigh/max effort. Official API defaults are **Opus medium / Fable high**, and effort is a behavioral signal rather than a strict token budget ([effort guide](https://platform.claude.com/docs/en/build-with-claude/effort) and model overviews, observed 2026-10-08). More effort is not always better: unnecessary/out-of-scope edits can reduce FrontierCode scores ([card §8.4][card], 2026-09-22). Effort/settings must be considered with the actual role and route, not inferred from a generic model label.

**Standard global Claude API list prices, USD per million tokens**, living [pricing guide][pricing] observed 2026-10-08; not measured subscription deductions or a provider-specific quote:

| Token category | Fable 5.1 | Opus 5.5 |
| --- | ---: | ---: |
| Uncached input | **$10** | **$4** |
| Output | **$50** | **$20** |
| Cache read/hit-refresh | **$0.25** | **$0.20** |
| Cache write, five-minute TTL | **$12.50** | **$5** |
| Cache write, one-hour TTL | **$20** | **$8** |

[Pricing guide][pricing] and the [Fable](https://platform.claude.com/docs/en/models/fable-5-1/overview) / [Opus](https://platform.claude.com/docs/en/models/opus-5-5/overview) overviews (observed 2026-10-08) source every entry. **[CALCULATION] Fable input/output/write prices are 2.5× Opus at identical billable token counts; cache reads are 1.25×**, not 2.5×. These are neither quota ratios nor per-task/per-success ratios: output length, tool steps, cache mix, write TTL, and actual route pricing matter. Both API overviews list **1M context / 128K synchronous output**, which is capacity, not evidence of correct synthesis or native-plan limits.

Anthropic's launch speed/cost improvement claims compare Opus 5.5 with **Opus 5**, not Fable ([launch, 2026-09-22](https://www.anthropic.com/claude-opus-5-5)). They are not a substitute for a Fable comparison.

### Native allowance versus API credits

- **Native Max:** Fable models are included up to **50% of regular weekly usage limits**, within the shared pool, not an extra pool; they consume it faster without an exact multiplier published in the reviewed help. This is native Claude/Code/Cowork allowance, not API tokens or OMP entitlement. Pro uses pay-as-you-go credits for Fable. [“Claude Fable models on your plan”](https://support.claude.com/en/articles/15424964-claude-fable-models-on-your-plan) and [Max help](https://support.claude.com/en/articles/11049741-what-is-the-max-plan), living pages observed 2026-10-08.
- **Separate monthly API credits:** eligible Max **5x / 20x** plans can claim **$100 / $200 per month** after **seven days** on an active plan and link one Console organization. Credits expire each billing cycle, are shared by that organization's keys, and do not increase native limits. They cover available first-party API models; interactive Claude Code, native extra usage, and third-party cloud routes are not covered. [Monthly API-credit help](https://support.claude.com/en/articles/17154008-monthly-api-credits-for-max-and-team-plans), living page observed 2026-10-08.
- **OMP boundary [INFERENCE]:** claimed, available credits could fund an authorized first-party API-key route in that linked organization, if the relevant OMP catalog/provider route exists. They do not authorize arbitrary subscription OAuth, prove a credit claim/balance, or grant this user Fable access. Native **50% weekly inclusion** and **monthly API dollars** remain distinct ledgers. No entitlement, auth, credit, spend, or configuration changes are proposed by this research.

## Separate role recommendations and reversal criteria

### `plan`

**[INFERENCE] Keep available, authorized Opus 5.5 provisionally.** Its independent analytical/professional-output and workflow evidence supports requirements synthesis, dependency/risk mapping, migration sequencing, and actionable acceptance criteria. Use explicit source requirements, assumptions, unresolved questions, and runnable handoffs; a polished narrative is not a complete plan. Do not force max: start from the route's supported default and justify higher effort by task uncertainty and known budget.

Fable's higher AA rubric scoring is relevant counterevidence for missed requirements. **Reverse toward Fable only after access/identity/budget are genuinely established and task-relevant evidence shows materially better requirement coverage, dependency correctness, uncertainty handling, or executable sequencing than Opus at reasonable higher effort, with acceptable actual cost/latency.** A generic capability label, old Opus 5 comparison, native allowance table, or unavailable route does not satisfy that condition.

### `architect`

**[INFERENCE] Keep available, authorized Opus 5.5 provisionally, with a weaker claim about read-only architecture judgment.** Long-horizon engineering and service-integration proxies support it, but they do not measure missed architectural hazards, long-term maintainability, or critique of a fixed design. Require externally grounded constraints, competing designs, explicit trade-offs, and verification of factual premises.

The [card §2.3.3, pp35–36][card] (2026-09-22) documents architect-relevant Opus failures: narrowly addressing review feedback without reconsidering the design, testing plans against self-written rather than intended-user requirements, and favoring incremental hypotheses in open-ended research. Endor's Fable correctness evidence reinforces caution, but remains patch-generation evidence rather than architectural review.

**Reverse toward Fable only with an authorized, verified route and representative blind comparisons showing fewer missed constraints, stronger root-cause/trade-off reasoning, or more maintainable designs; alternatively, a reproducible demanding problem that Opus at reasonable higher effort fails and Fable solves.** The benefit must justify actual cost/latency. Reconsider either choice if safeguards change the delivered model or access/budget changes. Preserve the independent OpenAI `critical` gate rather than treating an Anthropic-to-Anthropic model switch as independent review.

## Scope of conclusion and exclusions

**No direct head-to-head OMP `plan` or `architect` comparison was found in the reviewed primary and independent sources/searches.** This is a bounded finding, not a claim that none exists anywhere. A future role-specific comparison would need the same repository evidence, prompts/instructions, verified identities, repeat counts, effort/resource limits, fallback policy, blinded correctness rubrics, and cost/latency per accepted plan/design. Fable is unavailable now; that comparison was not run.

[LLM Stats](https://llm-stats.com/models/compare/claude-fable-5-1-vs-claude-opus-5-5) aggregation, [OpenCode](https://opencode.ai/data/compare/anthropic/claude-fable-5-1/anthropic/claude-opus-5-5) catalog metadata, comparison/SEO benchmark reposts, and [Chudi](https://chudi.dev/blog/claude-opus-5-5-vs-fable-5-1) old-Opus transcript repricing were not counted as new independent experiments. The small [Wmedia fixture benchmark](https://wmedia.es/en/tips/claude-code-opus-5-5-vs-fable-5-1-vs-opus-5-benchmark) was too easy/ceiling-limited to decide these roles. Vendor-reported external copies remain labelled as such.

This update used verified web-research evidence only. No provider inference, local Fable tests, gates, tests, linters, or formatters were run.

[card]: https://www.anthropic.com/claude-opus-5-5-system-card
[aa]: https://artificialanalysis.ai/articles/claude-opus-5-5
[endor]: https://www.endorlabs.com/learn/opus-5-5-6x-cheaper-and-2x-faster-than-fable-5-1-but-memorization-keeps-it-off-the-top-spot
[pricing]: https://platform.claude.com/docs/en/about-claude/pricing
