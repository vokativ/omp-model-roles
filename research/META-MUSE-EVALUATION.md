# Meta Muse Spark — role-fit evaluation

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root,
one level up.*

Written 2026-08-25 in response to: "we just added the Meta models API to this harness. Should we
think about their Muse 1.2 Contributor model for orchestration, or are there other roles where it
might fit? We'd have to pay for it so I'm wary of putting it in a heavy role, but I heard it's fast
at reviewing multiple PRs from Theo (T3)."

Research-only evaluation — **the model was deliberately not benchmarked in this harness.** Every
capability statement below is therefore public evidence or vendor evidence, not a local
measurement. Contrast with `README.md`'s "2026-08-25 A/B", which *is* locally measured.

---

## TL;DR

- **No for orchestration / `default`.** On Meta's own published chart it places third behind the
  incumbent, and as a plain API key it is structurally excluded from `retry.usageAwareFallback` —
  so it cannot be hopped-off-of proactively, and cannot relieve any metered pool.
- **The blocker is disclosure, not cost.** The `-contributor` discount is explicitly purchased with
  permission for Meta to train future models on your prompts and completions. For a harness that
  transmits proprietary source (mobile apps, browser extensions, private programs) that is
  disqualifying almost everywhere, regardless of price.
- **Cost is a non-issue and the original worry was inverted.** Priced against a locally measured
  agentic token profile, Contributor costs **$0.0043/task** — 31× under `gpt-5.6-terra`'s list
  price. But Terra/Gemini/Sonnet are *already paid subscriptions* whose marginal cost here is **$0**,
  so Contributor is new spend, not a saving.
- **One defensible home: `review`**, split by code sensitivity — Standard tier for proprietary
  repos, Contributor only for public/OSS. Non-blocking second opinion, never a merge gate.

## What it actually is (verified)

Provider `meta` is authenticated with three models. Specs and prices below are corroborated
*twice*: Meta's primary docs and this harness's own `omp models meta --json`.

| Model | Context | Max out | $/1M in | $/1M out | $/1M cache-read | Trains on your data? |
|---|---|---|---|---|---|---|
| `muse-spark-1.1` | 1,048,576 | 131,072 | 1.25 | 4.25 | 0.15 | No |
| `muse-spark-1.2` | 1,048,576 | 131,072 | 1.25 | 4.25 | 0.15 | **No** |
| `muse-spark-1.2-contributor` | 1,048,576 | 131,072 | **0.10** | **0.20** | **0.002** | **Yes** |

- Released 2026-08-05 alongside Meta's "Muse Code" agent beta; 1.2 was **co-trained with Muse Code**.
- `-contributor` is **not a weaker checkpoint**. It is the same `muse-spark-1.2` weights on a
  discounted *pricing tier*; the discount is paid for with training rights.
- Rate limits: Contributor **100 RPM / 3,000,000 TPM**, shared **per team** across all API keys;
  Standard 3,000 RPM / 4,000,000 TPM. Exceeding either returns HTTP 429.
- Vision-capable, full `minimal…xhigh` thinking ladder.
- Also served by OpenRouter at the same $0.10/$0.20. **OpenRouter does not neutralise the training
  clause** — provider policies still apply and the only listed endpoint for this model is Meta.
- No `omp usage` entry, because it is an API key rather than a coding-plan subscription. OMP's
  `retry.usageAwareFallback` documents that "Ordinary configured API keys are excluded."

## Cost model, grounded in local measurement

Using the mean per-task token profile actually measured in the 2026-08-25 A/B (3 × `gpt-5.6-terra`
trials on the browser-extension fixture): **35,066 input / 1,769 output / 211,797 cache-read**.

| Model | $/task | $/100 tasks | vs Contributor |
|---|---|---|---|
| `meta/muse-spark-1.2-contributor` | **0.0043** | 0.43 | 1.0× |
| `meta/muse-spark-1.2` (Standard) | 0.0831 | 8.31 | 19.4× |
| `google-antigravity/gemini-3.7-flash` | 0.0488 | 4.88 | 11.4× |
| `anthropic/claude-sonnet-5` | 0.1302 | 13.02 | 30.4× |
| `openai-codex/gpt-5.6-terra` | 0.1337 | 13.37 | 31.2× |

Why it is so cheap: agentic turns in this harness are **cache-read dominated** (211K of 248K
tokens), and Contributor prices cache reads at $0.002/1M — 100× below Terra's $0.20.

**The comparison is against list prices we do not pay.** ChatGPT Pro sat at 2% of its 7d meter and
has never exceeded 5% in 30 days; Gemini's lane is free. Their marginal cost is zero. So cost
cannot justify adoption — only a capability or capacity argument could, and neither survives below.

## Why not orchestration / `default`

1. **It loses to the incumbent on Meta's own marketing chart.** DeepSWE v1.1, each model paired
   with its own agent product: Muse Spark 1.2 + Muse Code **59.3%**, GPT-5.6 Terra + Codex
   **64.8%**, Claude Opus 5 + Claude Code **65.0%**. Terminal-Bench 2.1: Muse **82.9%** vs Opus 5
   **86.7%**, Terra **81.8%**.
   - *Reconciling with `README.md`'s A/B section*, which cites DeepSWE v1.1 as Opus 5 74.0% / Sol
     73.0%: those come from DataCurve's **official leaderboard**, which standardises every model
     onto the common `mini-swe-agent` harness. Meta's chart instead pairs each model with its
     vendor's own agent. Both figures are real; they are different configurations and must not be
     compared across. Muse Spark 1.2 does **not** appear on the official common-harness board.
2. **It breaks the quota safety net.** As an API key it is invisible to `usageAwareFallback`, so it
   adds a hard-failure path to the exact role where v10 deliberately engineered graceful,
   quota-aware degradation.
3. **Tool-calling constraints.** On Meta's OpenAI-compatible Responses / Chat-Completions
   endpoints, `tool_choice` accepts only `"auto"` — `none`, `required`, and named-function choices
   return HTTP 400, as do tool names containing two or more dots. (Meta's Anthropic-compatible
   `/v1/messages` surface *does* accept `any`/`none`, so this is endpoint-specific, not model-wide.)
   Meta additionally warns that its Chat-Completions adapter loses reasoning between turns and can
   repeat completed work or drop task context in multi-step loops.
4. **The good numbers are native-harness numbers.** Meta co-trained 1.2 with Muse Code and its own
   methodology cautions that model-specific tools and system prompts mean results may not transfer
   to another harness. This is precisely the transfer OMP would be relying on.

## The "fast at reviewing PRs" lead — provenance and limits

The hearsay checked out, and is genuinely impressive — but narrower than the retelling.

- **Primary source found:** Theo Browne's video *"Meta's Claude Code clone is INSANELY cheap"*. He
  audited **222 open PRs in under 5 minutes for $0.10** — about **$0.00045/PR**.
- It was **triage/audit**, not authoritative review and not merging.
- It ran in **Muse Code**, Meta's own harness — not OMP.
- It was a live first-impressions exploration, not a controlled benchmark. The video was sponsored,
  but by **Greptile, not Meta**.
- **"Fast" does not survive as a model-level claim.** Public throughput evidence is mutually
  inconsistent: Artificial Analysis lists Speed **N/A**; OrcaRouter telemetry claims 576 tok/s;
  OpenRouter user telemetry ≈191 tok/s; Theo's own session showed 174 tok/s. No controlled
  measurement exists. The impression traces to **batch cost and breadth**, not measured latency.

## Adversarial verification results

Five load-bearing claims, each attacked by 3 independent skeptics instructed to refute and to
default to "refuted" when unsure.

| Claim | Outcome | Note |
|---|---|---|
| Contributor tier buys training rights on prompts/completions | **CONFIRMED 3/3** | The decisive finding |
| Muse 1.2 below Terra/Opus on DeepSWE (59.3 vs 64.8/65.0) | **CONFIRMED 3/3** | Valid only for Meta's vendor-paired chart, not the official leaderboard |
| Contributor limited to 100 RPM / 3M TPM per team, 429 on exceed | facts confirmed, **conclusion refuted 3/3** | Numbers are right; "therefore unsuitable for always-on roles" was over-categorical — throttling or Standard tier are legitimate answers |
| No public evidence it is fast | **refuted 3/3** | Scattered third-party telemetry does exist; the honest status is *inconsistent and uncontrolled*, not *absent* |
| `tool_choice` restricted to `auto`; multi-dot tool names rejected | **CONFIRMED 2/3** | Dissent correctly noted the `/v1/messages` endpoint is exempt |

Two claims in the third and fourth rows were **retracted by this process** rather than confirmed —
recorded here deliberately, so the doc is not read as uniformly damning.

## Role-fit verdict

| Role | Verdict | Reason |
|---|---|---|
| `review` | **Only candidate.** Standard tier for proprietary repos; Contributor for public/OSS only | Matches the one real datapoint (bulk PR triage). Must be non-blocking and human-verified: there is **zero** public evidence on review precision / false-positive rate |
| `default`, `advisor` | No | Highest volume / fires every turn; would stream the whole repo into a training-rights tier, and breaks usage-aware fallback |
| `task`, `good_worker`, `fast_worker` | No | Parallel subagent fan-out against a 100 RPM per-team cap |
| `tiny`, `smol` | No | Already free on Luna; and these handle conversation content |
| `critical`, `security` | No | Trust-sensitive, and it trails incumbents on every published coding benchmark |
| `slow`, `plan`, `architect` | No | Reasoning-depth roles; 59.3% DeepSWE is the wrong direction |
| `commit`, `designer`, `vision` | No | Already covered free by `grok-build` / `grok-4.6` / Gemini, with no evidence of an edge |

## What would change this answer

- Meta offering the Contributor **price** without the **training clause**, or a documented
  zero-retention enterprise tier.
- Muse Spark appearing on DataCurve's **common-harness** DeepSWE leaderboard at or above Terra.
- A local review-precision measurement (seeded bugs *plus* deliberately clean code, scoring true
  catches against false positives) showing it beats `gpt-5.6-sol` — which is already free to us.
  This is the one property no amount of public research can settle.
- Meta gaining a coding-plan subscription that reports quota, which would make it eligible for
  `usageAwareFallback` and change its structural role in a chain.

## Method note

Six research dimensions were fanned out in parallel (identity/pricing, orchestration/agentic,
code-review fitness, the Theo provenance, weaknesses/risks, role-fit comparison), each required to
grade every finding `high`/`medium`/`low`/`unverifiable` with a source URL, and each explicitly
told that a documented "no source found" was a successful outcome. 49 findings were returned. The
five load-bearing claims were then re-attacked by 3 independent refutation-seeking skeptics each.
Local specs and prices were cross-checked against `omp models meta --json`; the cost model reuses
the token profile measured in `README.md`'s 2026-08-25 A/B. No model call was made to any `meta`
model at any point.
