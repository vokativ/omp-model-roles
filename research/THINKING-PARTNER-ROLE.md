# Thinking Partner (`sage`) Role & Allocation Architecture — 2026-09-04 · v19

> **Note (2026-10-20):** the body below is the v19 design (2026-09-04), kept as history. The current config is in `../model-roles.yml`; see section 5 for the v35 update.

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root, one level up.*

---

## 1. Executive Summary & Context

On 2026-09-04, empirical testing revealed that Anthropic Claude Pro ($20/mo) **strictly excludes Claude Fable 5 and 5.1**, returning HTTP 429:
```json
{"error":{"type":"rate_limit_error","message":"Usage credits are required for this model.","details":{"error_code":"credits_required","disabled_reason":"org_level_disabled"}}}
```
In v18, calls to `agents/fable.md` triggered this error and **silently degraded to `openai-codex/gpt-5.6-terra`** via OMP's default fallback chain. Terra (a lower-tier code workhorse) was answering under the `fable` name without notifying the caller.

Rather than patching Fable onto another code-focused endpoint, the role was re-architected into **Thinking Partner** (`sage`):
1. **Primary Model:** `anthropic/claude-opus-5` (authenticated, quota-covered by Claude Pro $20/mo).
2. **Fallback Chain:** Preserves Claude-family character first, then falls back to OpenAI Pro's deep reasoning flagship:
   `google-antigravity/claude-opus-4-6` $\to$ `openai-codex/gpt-5.6-sol` $\to$ `google-antigravity/claude-sonnet-4-6` $\to$ `xai-oauth/grok-4.6` $\to$ `openrouter/z-ai/glm-5.3-flash`.
3. **No JSON Schema:** Removed the rigid frontmatter `output:` block that turned Fable into an accidental `architect` clone. A thinking partner requires exploratory dialectic, lateral problem reframing, and organic dialogue.
4. **Machine Token:** `sage` (4 letters, single lowercase token, zero hyphen-parsing ambiguity across CLI, `@role` aliases, and Ctrl+P cycling).

---

## 2. Multi-Agent Consultation: Architect vs Slow Model

We conducted an isolated, parallel multi-agent debate in `eval` between:
- **`@architect`** (`anthropic/claude-opus-5`)
- **`@slow`** (`openai-codex/gpt-5.6-sol`)

### The Debate

| Topic | `@slow` (GPT-5.6 Sol) Perspective | `@architect` (Claude Opus 5) Perspective | Synthesis / Decision |
|---|---|---|---|
| **Primary Model** | Argued for Sol primary to preserve scarce Anthropic 5h quota during long, conversational brainstorming turns. | Argued for Opus 5 primary because ideation is 100% reader-facing prose and lateral taste. Noted that Codex endpoints skew technical/orthodox outside code tasks. | **Opus 5 wins as primary.** `usageAwareFallback` + `usageReservePolicy: auto` already guarantees graceful failover before `architect`/`critical` are starved. Ideation is episodic, which is what the reserved Anthropic quota is for. |
| **Fallback Tier 1** | Proposed Opus 5 as fallback if Sol is primary. | Proposed `google-antigravity/claude-opus-4-6` ahead of Sol to maintain Claude-family voice on the free 0%-used proxy lane. | **Antigravity Opus 4.6 is Tier 1, Sol is Tier 2.** Preserves Anthropic reasoning character with $0 spend, followed immediately by Sol's abundant ChatGPT Pro capacity. |
| **Agent Contract / Schema** | Agreed: avoid rigid JSON schema. Use a flexible Markdown interaction contract. | Agreed: "The schema is the role." Cloning architect's schema was why fable failed to differentiate. Use a Markdown skeleton for dispatch, freeform for interactive. | **Unanimous Agreement:** No frontmatter `output:` schema. |
| **Naming** | Proposed `thinking-partner`. | Proposed `sage` to avoid hyphen-parsing bugs in `@role` aliases and keep Ctrl+P cycling fast. | **`sage` canonical role & agent name**, with "Thinking Partner" as human-facing title. |

---

## 3. Canonical Architecture & Configuration

### Role Mapping (`model-roles.yml`)
```yaml
modelRoles:
  ...
  sage: anthropic/claude-opus-5
```

### Fallback Chain (`model-roles.yml`)
```yaml
retry:
  fallbackChains:
    ...
    sage:
      - google-antigravity/claude-opus-4-6  # Tier 1: Claude-family continuity on free 0% proxy
      - openai-codex/gpt-5.6-sol           # Tier 2: Deep reasoning flagship (abundant ChatGPT Pro)
      - google-antigravity/claude-sonnet-4-6 # Tier 3: Fast Claude fallback ($0 proxy)
      - xai-oauth/grok-4.6                 # Tier 4: Heterodox independent weights
      - openrouter/z-ai/glm-5.3-flash      # Tier 5: High-context capability tier
    # Defend explicit CLI invocations (--model fable-5) against the account 429 trap:
    anthropic/claude-fable-5-1:
      - anthropic/claude-opus-5
      - openai-codex/gpt-5.6-sol
      - google-antigravity/claude-opus-4-6
    anthropic/claude-fable-5:
      - anthropic/claude-opus-5
      - openai-codex/gpt-5.6-sol
      - google-antigravity/claude-opus-4-6
```

### Agent Definition (`agents/sage.md`)
- `model: "@sage"`
- `thinking: high`
- `tools: [read, grep, glob, web_search]`
- `spawns: []`
- **No `output:` JSON schema.**
- System prompt defines a 6-part Markdown section skeleton for dispatch mode:
  1. `## Read`: The problem/challenge as understood, sharpened.
  2. `## Assumption audit`: Implicit assumptions; which are unexamined; which are fragile.
  3. `## Directions`: 2–4 distinct approaches, with at least one intentionally unorthodox angle.
  4. `## Strongest objection`: The strongest counter-argument to the user's current intuition.
  5. `## Probes`: The cheapest experiment/check to discriminate between paths.
  6. `## Confidence & blind spots`: Grounded evidence vs prior beliefs.

In interactive dialogue (`/model @sage`), conversational interaction is unconstrained.

---

## 4. Migration & Clean Cutover

1. `agents/fable.md` is removed and replaced by `agents/sage.md`.
2. `~/.omp/agent/agents/fable.md` is deleted, and `agents/sage.md` installed to `~/.omp/agent/agents/sage.md`.
3. `modelRoles.fable` and `retry.fallbackChains.fable` are replaced by `sage`.
4. `anthropic/claude-fable-5-1` and `anthropic/claude-fable-5` model-level fallback entries are retained to prevent any explicit `--model` invocation from hitting Terra.
5. `cycleOrder` includes `sage`: `[smol, default, slow, architect, sage]`.

---

## 5. v35 update (2026-10-20)

Sections 1–4 are the v19 design and stay as written; where they conflict with this section, this section and `model-roles.yml` win. Evidence and caveats: [SAGE-FABLE-ASTRA-EVALUATION.md](SAGE-FABLE-ASTRA-EVALUATION.md); Fable-vs-Opus web evidence for `plan`/`architect`: [FABLE-EVALUATION.md](FABLE-EVALUATION.md).

- **Primary:** `sage: anthropic/claude-fable-5-1`, provisional and reversible. The 2026-09-04 `credits_required` 429 no longer applies: 2026-10-20 probes were accepted on Claude Max 5x OAuth with the delivered model id verified. Chosen on cost (~2 sage dispatches/week; est. +1.6 weekly-pool points vs Opus, a rough estimate), published pushback evidence, and decorrelation from the Opus-based `plan`/`architect`/`slow`. **Fable-vs-Opus quality for `sage` is UNRESOLVED:** blind A/B was n = 3 prompts, judge-family self-preference dominated, and P1 leaked model identity.
- **Current failover (model-level chain on `anthropic/claude-fable-5-1`, same on `claude-fable-5`):** `anthropic/claude-opus-5-5` $\to$ `google-antigravity/claude-opus-5-5` $\to$ `openai-codex/gpt-6.1-sol` $\to$ `google-antigravity/gemini-4-argon` $\to$ `xai-oauth/grok-4.7`.
- **Why model-level chains own the order:** OMP checks exact model-key chains before role-key chains. With `sage` on Fable, the `anthropic/claude-fable-5-1` chain is sage's failover; the role-level `sage` chain (`google-antigravity/claude-opus-5-5` $\to$ Sol 6.1 $\to$ Argon $\to$ Grok 4.7) applies only if `sage` reverts to Opus. Antigravity Opus precedes Sol so sage does not drain the Plus 5h window that `critical` swarms exhaust. Argon stays late because its weekly meter was exhausted until ~2026-10-24.
- **Caveats:** a mid-session Fable $\to$ Opus failover drops Fable's reasoning (fresh dispatches unaffected). Fable draws from the shared Max 7d pool (sub-cap up to 50%).
- **Astra:** `openai-codex/gpt-6-astra` is in no role and no chain (v20 put it in sage's fallback; that no longer holds). Explicit `--model` use only.
- **Revert:** set `modelRoles.sage` back to `anthropic/claude-opus-5-5`; the role-level chain then takes over.
