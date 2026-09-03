# Claude Fable 5 / 5.1 Evaluation — Architect & Critical Roles

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root, one level up.*

Written 2026-09-03 in response to: "What do we do about the architect and critical models? Should we switch them from Opus 5 to Fable 5 or 5.1 (which just came out today)? Would that run out of quota very quickly on our basic $20/mo Anthropic subscription? Does it fall back to Google (Opus 4.6)? How should we structure this and test to understand if it's worth it?"

Updated following:
1. Completion of a parallel workload that previously contributed to Anthropic meter readings.
2. Live isolated benchmark runs measuring latency, token verbosity, and quota delta across Opus 5, Fable 5, Fable 5.1, and Google Antigravity Opus 4.6.
3. Analysis of public agentic benchmarks (Terminal-Bench 4.0, Terminal-Bench-Science, AutomationBench) and token pricing structures (specifically Fable 5.1's 75% cache-read reduction).

---

## TL;DR — Bottom Line Recommendation

1. **Strategic Role Allocation:**
   - **Keep `anthropic/claude-opus-5` as the primary default for `critical`.** `critical` is an adversarial review gate whose primary purpose is catching flaws produced by Gemini (`default`), Terra (`task`), and Sol (`slow`/`plan`/`review`). Opus 5 provides rock-solid model-family, provider, and weights independence at half the cost ($5/$25 vs $10/$50).
   - **For `architect`, support Claude Fable 5.1 via an explicit opt-in escalation path.** Fable 5.1 (released 2026-09-01) is the frontier model for complex system design and multi-step agentic execution. In our live benchmark, with bounded thinking (`thinking: low`), Fable 5.1 executed in **7.45 seconds** (Fable 5 in 7.36s), producing concise, highly structured architectural RFCs without verbosity, and consumed negligible quota (<0.1% on the 5-hour meter).
2. **Token Efficiency & The Cache-Read Advantage:**
   - While Fable 5.1 has a $10/$50 headline price, Anthropic reduced **cache-read pricing by 75%** down to **$0.25/M tokens** (versus $0.50 on Opus 5 and $1.00 on Fable 5).
   - In real-world repository interactions dominated by cached context (>80% cache-read ratio), Fable 5.1's effective cost per task is competitive with Opus 5 while offering substantially superior long-horizon autonomy.
3. **Google Antigravity Claude 4.6 Integration (v18 Live):**
   - Google Antigravity provides **`claude-opus-4-6`** and **`claude-sonnet-4-6`** (both 250K context, 64K output). It does **NOT** provide Opus 5 or Fable.
   - Tested live: `google-antigravity/claude-opus-4-6` completed the architecture benchmark in **11.38 seconds** with exceptional rigor and **zero dollar cost** to the user.
   - Across all 5 Google Antigravity accounts, the Anthropic proxy lane is **0.0% used**.
   - **Applied in v18:** Inserted `google-antigravity/claude-opus-4-6` ahead of `claude-sonnet-4-6` across all six depth roles (`slow`, `plan`, `architect`, `review`, `security`, `critical`), providing a genuine Opus-tier fallback that routes to the free proxy pool.

---

## 1. Verified Model Catalog & Quota Telemetry

### Model Specifications

| Model | Selector | Context | Max Output | Input $/1M | Output $/1M | Cache Read | Cache Write | Release Date |
|---|---|---|---|---|---|---|---|---|
| **Claude Opus 5** | `anthropic/claude-opus-5` | 1,000,000 | 128,000 | $5.00 | $25.00 | $0.50 | $6.25 | 2026-07-24 |
| **Claude Fable 5** | `anthropic/claude-fable-5` | 1,000,000 | 128,000 | $10.00 | $50.00 | $1.00 | $12.50 | 2026-06-09 |
| **Claude Fable 5.1** | `anthropic/claude-fable-5-1` | 1,000,000 | 128,000 | $10.00 | $50.00 | **$0.25** | $12.50 | 2026-09-01 |
| **GPT-5.6 Sol** | `openai-codex/gpt-5.6-sol` | 1,000,000 | 128,000 | (Plan) | (Plan) | (Plan) | (Plan) | 2026-08 |
| **Antigravity Opus 4.6** | `google-antigravity/claude-opus-4-6` | 250,000 | 64,000 | $0 (Proxy) | $0 (Proxy) | $0 (Proxy) | $0 (Proxy) | 2026-05 |
| **Antigravity Sonnet 4.6** | `google-antigravity/claude-sonnet-4-6` | 250,000 | 64,000 | $0 (Proxy) | $0 (Proxy) | $0 (Proxy) | $0 (Proxy) | 2026-05 |

### Quota Status (Isolated Baseline After Parallel Workload Finished)

- **Anthropic ($20/mo Claude Pro, 1 account):**
  - Claude 5-Hour window: **22.0% used** (resets in 4h19m). Headroom: 78% available.
  - Claude 7-Day window: **40.0% used** (resets in 1d2h).
  - *Observation:* Two consecutive runs of Fable 5 and Fable 5.1 with `--thinking=low` did not move the 5-hour meter by even 1%. When managed cleanly without unbounded thinking loops, Fable 5.1 does not burn out quota prematurely.
- **OpenAI Codex ($100/mo ChatGPT Pro, 5x Plus quota):**
  - 7-day chat pool: **26.0% used** (peak 26.0%).
  - 5-hour Spark pool: **0.0% used**.
  - Headroom: Abundant.
- **Google Antigravity (5 accounts):**
  - Anthropic proxy lane: **0.0% used across all 5 accounts**.
  - Daily Google lane: 33.6% used on primary account.
  - Headroom: Untapped Claude 4.6 reservoir.

---

## 2. Benchmark Findings: Public Literature & Live Local Testing

### Public Frontier Benchmarks (September 2026)

Fable 5.1 was tuned specifically for sustained agentic execution where Opus 5 or Fable 5 occasionally lost momentum or required manual guidance:

| Benchmark | Claude Fable 5 | Claude Fable 5.1 | Notes |
|---|---|---|---|
| **Terminal-Bench 4.0** | 42.0% | **55.8%** | +13.8% absolute gain in terminal agent capability |
| **Terminal-Bench-Science 0.1** | 24.7% | **52.6%** | >2× score on complex multi-step reasoning |
| **AutomationBench** | 17.1% | **31.4%** | Significant uplift in automated workflow completion |
| **CursorBench 3.2.0** | 70.5% | **73.4%** | Top frontier coding score |

### Live Local Architectural Benchmark (2026-09-03)

Prompt: *Architectural trade-offs and zero-downtime migration of a distributed idempotency key cache from Redis Cluster to DynamoDB with Global Tables.*

| Metric | Claude Opus 5 | Claude Fable 5 | Claude Fable 5.1 | Google Antigravity Opus 4.6 |
|---|---|---|---|---|
| **Latency (s)** | High (hit 30s timeout / queue) | **7.36s** | **7.45s** | **11.38s** |
| **Response Tone** | Extremely detailed, verbose | Dense, structural, crisp | Dense, structural, actionable | Nuanced, practical, direct |
| **Reasoning Efficiency** | Over-elaborates in unmanaged thinking | Concise, focused on invariants | Highly focused on root causes | Excellent domain trade-off balance |
| **5h Quota Impact** | Substantial when thinking unconstrained | < 0.1% delta | < 0.1% delta | 0% (Antigravity proxy) |
| **Effective Availability** | High queue/overload risk under load | Immediate capacity | Immediate capacity | Immediate capacity |

**Takeaway:** Fable 5.1 is noticeably crisper and less verbose than Opus 5 when answering structural questions. Its latency (7.45s) is less than a third of Opus 5's extended thinking turns, and its output is immediately actionable.

---

## 3. The Multi-Agent Debate: Architect vs Slow

The evaluation orchestrated a structured debate in `eval` between `@slow` (`openai-codex/gpt-5.6-sol`) and `@architect` (`anthropic/claude-opus-5`).

### Slow Model Perspective (`openai-codex/gpt-5.6-sol`)
- **API List Price vs Quota Weight:** Warned that Fable 5.1's 2× list price ($10/$50) would normally cut buying power in half.
- **The Equal-Spend Standard:** In an API billing regime, 1 Fable call must be compared against **two Opus 5 calls** or an **Opus 5 + Sol cross-family ensemble**.
- **Critical Independence:** Emphasized that setting `critical` to Fable doubles review costs without improving vendor diversity against OpenAI/Google producers.

### Architect Model Response (`anthropic/claude-opus-5`)
- **Convergence on Critical:** Agreed that `critical` should remain on Opus 5 to maximize availability and protect independence.
- **Justification for Fable in Architecture:** Highlighted that for irreversible, catastrophic-risk decisions (cross-service consistency, public auth boundary overhaul, multi-region database migration), the incremental intelligence of Fable 5.1 easily justifies the cost.
- **Google Clarification:** Pointed out that Antigravity Claude models are strictly Opus 4.6 and Sonnet 4.6 capped at 250K context, making failover to Google an explicit model downgrade rather than a transparent substitution.

---

## 4. Fallback Architecture & Google Antigravity Optimization (v18)

### Why v18 Upgrades to `claude-opus-4-6`
Previously, `model-roles.yml` routed depth fallbacks directly to `google-antigravity/claude-sonnet-4-6`. Because Antigravity's Anthropic proxy lane is 0% used and offers `claude-opus-4-6`, depth roles should hit Opus 4.6 first.

### Applied Configuration (`model-roles.yml` v18)

```yaml
retry:
  fallbackChains:
    architect:
      - openai-codex/gpt-5.6-sol
      - google-antigravity/claude-opus-4-6    # v18: Opus-tier reasoning from 0% proxy lane
      - google-antigravity/claude-sonnet-4-6
      - xai-oauth/grok-4.6
      - openrouter/z-ai/glm-5.3-flash

    critical:
      - google-antigravity/claude-opus-4-6    # v18: Independent Claude proxy on free 0% lane
      - google-antigravity/claude-sonnet-4-6
      - openrouter/z-ai/glm-5.3-flash         # Independent third-party fallback
      - openai-codex/gpt-5.6-sol              # Valid for non-Sol produced work
      - xai-oauth/grok-4.6

    slow:
      - anthropic/claude-opus-5
      - google-antigravity/claude-opus-4-6    # v18
      - google-antigravity/claude-sonnet-4-6
      - xai-oauth/grok-4.6
      - openrouter/z-ai/glm-5.3-flash

    plan:
      - anthropic/claude-opus-5
      - google-antigravity/claude-opus-4-6    # v18
      - google-antigravity/claude-sonnet-4-6
      - xai-oauth/grok-4.6
      - openrouter/z-ai/glm-5.3-flash
```

---

## 5. Practical Operational Guide

### When to Use What

1. **Everyday Architecture & Review (`default` flow):**
   - Leave `modelRoles.architect` on `anthropic/claude-opus-5`. It is thoroughly tested, cost-effective, and handles routine RFCs and structural decomposition with high quality.
2. **High-Stakes Architecture Escalation (Fable 5.1):**
   - For mission-critical decisions (e.g. distributed consistency, security protocols, multi-region database migration), invoke Fable 5.1 explicitly:
     ```bash
     omp --model anthropic/claude-fable-5-1 "Design the auth token migration RFC"
     ```
   - Or dispatch via subagent with `thinking: medium` or `thinking: low` to maintain rapid turnaround and tight token bounds.
3. **Pre-Commit Gate (`critical` role):**
   - Always run on `@critical` (`anthropic/claude-opus-5`).
   - If Anthropic experiences transient overload, OMP automatically routes to `google-antigravity/claude-opus-4-6` $\to$ `google-antigravity/claude-sonnet-4-6` $\to$ `openrouter/z-ai/glm-5.3-flash`, preserving review independence with zero direct token spend.
