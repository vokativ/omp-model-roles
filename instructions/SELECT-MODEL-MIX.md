# Select an alternative OMP model mix

**Instruction updated: 2026-11-03 (snapshot v38; installed OMP 18.16.0, role contract
last derived on 18.13.2). Source baseline: 2026-10-08; recheck by 2026-11-11**, or
immediately after a plan, permission, price, catalog, eligibility, or OMP role/agent
change. This is a prompt for OMP to follow, not a program or an installation step.

## How to use

Ask OMP:

> Read `instructions/SELECT-MODEL-MIX.md` and follow it to propose an alternative
> for these plans: Claude Max 5x, OpenAI Plus, Google AI Pro (non-trial), and X
> Premium. My budget is no new spend beyond those subscriptions; API use must stop
> at verified included credits. Use available read-only state and explain missing
> permission or balance evidence. Do not apply anything.

Replace the example with your actual or proposed plans and budget. No executable,
CLI flags, generated plan database, or selector tests are required.

## Your task and boundaries

Propose a complete, workload-aware alternative OMP overlay. **Preserve the current
live setup by default.** Do not import or apply the overlay, start an additional
provider session/trial, install anything, change authentication or billing, claim
credits, enable top-ups, edit root overlays/custom agents, or commit/push unless
separately and explicitly requested. Reading a proposal does not authorize any
new route or spend. Do not send additional selected-model probes, benchmarks, or
provider trial requests; send **no Fable requests** from a preview.
An ordinary planning reply from the existing OMP session uses its already-selected
model and may consume that session's existing allowance; it is not a selected-model
trial or verification of the proposed routes.

Scope is exactly the four requested provider groups: **OpenAI, Anthropic, Google,
and SpaceX/xAI/X**. Do not allocate to other providers or change their existing
logins/settings unless the user explicitly extends the scope. There are two
exceptions, each limited to a login that **already exists**; never add, buy, or fund
either from a preview:

- **`judge`:** the model-kind `judge` role may keep an already credentialed native
  judgment route (currently direct `typesafe/jev-1.14.0` via an existing `/login typesafe`
  API key, with native fallbacks `openrouter/typesafe/jev-1.14`,
  `openrouter/typesafe/jev-1.13`, and `openrouter/liquid/d1.1` billed to OpenRouter
  prepaid credit). Label it as separately funded API-key use outside the four
  subscriptions.
- **Mistral hops and the owner-chosen default primary:** an existing `mistral` plan login
  (currently the Mistral Education plan key from `/login mistral`) may be kept as **bounded
  fallback hops**: at most one `mistral/*` entry per chain, and canonical
  catalog ids only (for example `mistral/zai-glm-5-3` and `mistral/zai-glm-5-3-flash`),
  not alias ids that lack catalog metadata (`mistral-medium-3.5`, `zai-glm-5`,
  `mistral-vibe-cli-*`). Label it as a monthly plan allowance (owner's admin page, 2026-11-03:
  $150/mo Included Vibe Code usage, which the OMP key is inferred to draw, plus a separate $15/mo
  API allowance; both reset on the 1st of the calendar month) shared with Mistral Vibe CLI and
  every machine using the config (not one of the four subscriptions), with no
  `omp usage` meter and an HTTP 402 stop on exhaustion. Mistral has no native judgment
  API, so it never belongs in `judge`. The v37 and v37.1 snapshots use it only in `smol`,
  `tiny`, `task`, and `review`; v37.2 adds `vision` (`mistral/mistral-large-4`, an
  image-capable hop after Sol 6.1 and before Grok 4.7). It stays out of `critical`,
  `slow`/`plan`/`security`, and `sage`. It is **never a primary by default**; the single
  exception is the owner-chosen v38 `default` primary `mistral/zai-glm-5-3`, allowed only
  while all of these hold: (1) the `default` chain ends in non-Mistral models with a 1M-context
  model reachable (v38: `google-antigravity/gemini-3.8-flash` -> `anthropic/claude-sonnet-5-5`);
  (2) Mistral pay-as-you-go stays off, so exhaustion fails over (HTTP 402) instead of billing;
  (3) the owner accepts that GLM-5.3 is text-only, so pasted images in a default session are
  not seen (switch model or use `read <image>?q=...`, which uses the `vision` role). Do not
  extend the exception to any other role or propose it without the owner's explicit choice.
  Evidence: [default-role evaluation](../research/DEFAULT-ROLE-EVALUATION.md).

Read [subscription research](../research/SUBSCRIPTION-MIXES.md), the
[research playbook](../research/RESEARCH-PLAYBOOK.md),
[Fable evaluation](../research/FABLE-EVALUATION.md),
[Mistral evaluation](../research/MISTRAL-EVALUATION.md), and
[default-role evaluation](../research/DEFAULT-ROLE-EVALUATION.md), then current `model-roles.yml`,
`models-overlay.yml`, relevant agent bindings, and any supplied plans/usage notes.
This instruction's **proposal-only** scope overrides the playbook's apply/ship
workflow and historical executable-selector directions. Existing allocations,
profiles, past failures, and prior checks are evidence with dates, not today's
mandatory winner or proof of a new account's entitlement.

When available, inspect current config, usage windows/reset times, and model
catalog **read-only** (for example, existing OMP config getters, `omp usage`, and
`omp models`). Do not initiate login, expose secrets, or probe models. If unavailable,
state that limitation and use supplied evidence without inventing measurements. The
Mistral plan key and the OpenRouter judge key have no `omp usage` meter; do not read
a missing meter as headroom.
Ask only for missing **material** subscription, budget, or route-permission facts
that cannot be obtained from available evidence and actually prevent planning the
requested scenario; do not repeat answered questions. Label other assumptions.

Distinguish a **current verified allocation** from a **conditional future-plan
preview**. For a requested future mix (for example, Max next week with unclaimed
credits and no Fable access today), provide a complete conditional 15-role proposal,
with per-route access/funding assumptions and prerequisites. Missing future claims,
permission verification, or account availability are risks to expose, not reasons
to silently substitute today's OpenAI setup or refuse the preview. A conditional
overlay is not runnable/covered/permitted merely because its config is well formed.

## Derive the allocation

1. **Separate three facts for each route:** native subscription entitlement;
   authorized OMP/API route and its funding; exact installed catalog identity and
   capabilities. Technical reachability or a native Max login proves neither OMP
   permission nor API coverage. Recheck dated official plan/model/usage/terms sources
   and account-specific conditions before treating them as current. Cite URLs and
   checked dates; distinguish primary evidence, historical observations, and
   `[INFERENCE]` recommendations.
2. **Filter for the requested scenario.** A current verified allocation excludes
   unavailable, inaccessible, and unverified routes from primaries and every fallback.
   An explicitly requested future-plan preview may include catalog-backed routes
   whose future permission, funding, or account access remains unverified, provided
   each is labeled conditional with its prerequisites; never assume authorization
   as fact. In both cases exclude omitted/canceled providers, explicitly unauthorized
   routes, and models known unavailable under the proposed tier. Verify exact
   tier/trial restrictions: Google trial Pro, Free, and Plus exclude Claude 5.5;
   only eligible non-trial Pro/Ultra can supply that proxy under the dated evidence.
   Recheck current terms rather than assuming a catalog entry bypasses restrictions.
   Do not invent a selector for an unlisted model.
3. **Budget real packages and pools.** Account for exact tier, region, billing
   cadence, promotions, organization sharing, expiry, reset windows, and optional
   overages. Native allowances, claimed API credits, purchased credits, and shared
   proxy pools are different budgets. Before execution, Max API credits require
   verified eligibility, claim, linked organization, amount/expiry, permitted API
   auth, and spending boundaries; in a future preview, list these as unmet
   prerequisites rather than assuming they are satisfied. Native Max 5x/20x is not
   an OMP/API multiplier. API price is not a subscription-quota conversion formula.
   OAuth usage meters do not measure Console
   API-credit balances; usage-aware retries do not enforce a bill cap. Purchased
   credits, auto-reload, or invoicing may continue spending after included credits.
4. **Choose on workload and observed headroom**, not a universal provider tie order
   or a plan's marketing label. Include high-volume workers, full-task `smol` use,
   frequent plan/architect work, advisor's per-turn load, reasoning/context length,
   tool/attachment costs, repeated reading, and concurrent machines sharing accounts.
   Prefer a sustainable general-work pool and preserve depth capacity where it pays
   off. If headroom is unknown, give a provisional choice and its assumptions; do
   not extrapolate current accounts' readings to an unowned tier. Recommend upgrades
   only for a stated need supported by actual usage, not invented quota ratios.
5. **Evaluate Fable 5.1 versus Opus 5.5 separately for `plan` and `slow`.** `slow`
   also serves the `architect` consultant agent (`agents/architect.md` binds to
   `@slow`; there is no separate `architect` role since v36), so the architect
   evaluation below decides `slow`.
   The [2026-10-08 web evaluation](../research/FABLE-EVALUATION.md) supports
   **Opus 5.5 provisionally for both depth roles in the Anthropic-heavy alternative**,
   not a proven role-specific winner. Public analytical/workflow and long-horizon
   engineering proxies favor Opus overall; no controlled head-to-head of OMP plan
   completeness or read-only architectural review was found in the reviewed sources.
   Fable remains a credible conditional candidate: Artificial Analysis reports better
   Fable rubric scoring despite Opus's analytical/presentation lead, and Endor Labs
   finds better memorization-discounted functional/security correctness for Fable.
   Those agent/work-product results are counterevidence, not direct role benchmarks;
   preserve their harness, effort, fallback, uncertainty, and scoring limitations.
   [Anthropic's selection guide](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model)
   (checked 2026-10-08) says to start most work with Opus and tune effort before Fable
   escalation when evals at `xhigh`/`max` still fall short. Its “highest capability”
   Fable positioning is not a universal benchmark win; maximum effort is not always
   better, nor equal compute/cost across models.
   - **Plan:** retain Opus provisionally for requirements, dependency/risk mapping,
     and actionable sequencing. Favor Fable if representative evidence shows materially
     fewer missed requirements, incorrect dependencies, or unusable handoffs at
     acceptable cost/latency after reasonable Opus effort tuning.
   - **Architect (`slow`):** retain Opus provisionally for source-grounded trade-offs/design
     review, while guarding its documented narrow-feedback and self-authored-requirement
     failure modes. Favor Fable if task-relevant, preferably blind comparisons show
     fewer missed constraints/hazards or better root-cause reasoning and maintainability,
     or it reliably solves a demanding design problem on which tuned Opus falls short.
   Either change requires an authorized, funded route and exact installed catalog
   identity. Official API list prices/latency evidence are not native-quota ratios
   or a user's budget measurement. Do not assume Fable access (an owner-account OMP probe on 2026-10-20 accepted `claude-fable-5-1` via Max 5x OAuth; that does not establish it for other accounts): keep this
   comparison web-only, without demanding local tests, probing, inventing a selector,
   or binding Fable by default. Describe future permission/catalog/credit prerequisites.
   If Opus is also ineligible, choose an eligible depth route and explain why.
   Same-provider Opus/Fable switching is a capability choice, **not cross-provider
   quota fallback**; keep fallback chains within the routing contract below.
6. The existing **Anthropic-heavy example**—Sonnet workers/review, Opus depth,
   Haiku cheap roles, Google default/vision/advisor, and OpenAI critical—is one
   candidate, **not the mandatory allocation**. Alternative primaries within these four
   provider groups may favor Anthropic, OpenAI, Google, or xAI according to packages,
   workload, headroom, permission, and evidence. Explain route ordering individually.

## Complete role and routing contract

Cover these **15 roles**, with a primary and an ordered fallback chain for each:

| Role | Kind | Work to account for |
|---|---|---|
| `default` | built-in chat | Every-turn general work and reader-facing output |
| `smol` | built-in chat | High-volume dispatch/classification, `scout`, prewalk target, opted-in implementation |
| `slow` | built-in chat | Difficult full-task reasoning/prewalk; also the `architect` agent; explicit Fable/Opus decision |
| `plan` | built-in chat | Planning before implementation; explicit Fable/Opus decision |
| `task` | built-in chat | General delegated work; bundled `task` agent and Vibe `good` tier bind to it directly |
| `vision` | built-in chat | Image understanding; image-input-capable routes only |
| `commit` | built-in chat | Infrequent commit-message work |
| `advisor` | built-in chat | Per-turn advice; count its added pool load |
| `tiny` | built-in chat | Small low-stakes work (titles, memory); also bundled `sonic` / Vibe `fast` tier via override |
| `widget` | built-in chat | One request per background job to author its status widget; cheap tier only |
| `judge` | built-in model-kind | Native judgments (native judgment models only): `find`, typed eval judgments, auto-thinking |
| `review` | custom | PR/diff review (bundled `reviewer` via override); primary from a different model family than the main producers (`task`/`smol`/`slow`), same-family routes last |
| `security` | custom | Security review (bundled `security-reviewer` via override) |
| `critical` | custom | Adversarial go/no-go before irreversible/operational actions (`agents/critical.md`); not routine PR review |
| `sage` | custom | Deep thinking/ideation (`agents/sage.md`) |

Do not reintroduce roles that duplicate a built-in binding: `architect` (use `@slow`),
`good_worker` (bundled `task` already binds `@task`), `fast_worker` (route `sonic`
to `@tiny`), or `designer` (no OMP consumer; select a model directly). Add a custom
role only when an agent or override needs a model that differs from every built-in.

Use exact catalog selectors eligible for the verified allocation or explicitly
conditional future scenario, including supported reasoning suffixes.
Every `vision` primary **and fallback** must accept image input; text-only
Composer and `mistral/zai-glm-5-3` are not image routes.

`judge` must resolve **first to a credentialed native judgment model** (a native
System One route such as direct `typesafe/jev-1.14.0` with a TypeSafe login, or
`openrouter/typesafe/jev-1.14`) for `find` to be enabled (`find.enabled: auto`),
auto-prewalk, and smart `tui.autoGraph`. Keep the judge chain **natives only**: once a
credentialed native judge fails, OMP never tries a prompted chat candidate, so a
prompted chat tail is dead config. It answers only when every native entry is
uncredentialed, and then judgments degrade (v36 ran that way from 2026-10-28 to
2026-11-03: `find` disabled, prompted 0/1 probabilities). An uncredentialed primary is
skipped, not a route, and an entry that does not resolve (for example the unseeded
`typesafe/jev-preview`) logs "does not resolve to a compatible model" and should be
dropped. Confirm a credential exists from read-only state before naming a judge
primary. In OMP 18.13.2 (not rechecked on 18.16.0) the widget author resolves
`@widget` but does not walk `retry.fallbackChains.widget`; keep that chain for
forward compatibility, not as delivered resilience. Check companion model overrides
if a route needs one; do not silently inherit unrelated models or settings.

Chains must exclude the primary's entire routing provider, deduplicate selectors,
and use distinct eligible routing providers across fallback tiers wherever possible.
A different model on the same exhausted provider is not cross-provider resilience.
Empty chains are valid when no eligible alternative exists; warn, do not fabricate.
Proxy Claude can diversify a route/pool but is still the Claude model family.

Record **routing provider and model family separately**: GLM (Z.ai) and DeepSeek
served through `mistral` are distinct third-party model families behind one routing
provider. Provider exclusion and the one-`mistral`-entry-per-chain limit follow the
provider; independence for `review` and `critical` follows the family. A
`mistral/zai-glm-*` hop is neither Mistral-family nor a separate pool from other
`mistral/*` hops.

For `critical`, exclude the **actual resolved producer's provider and model family**
from primary and all fallbacks, including proxies of that family. Record actual
resolved model/provider/auth-route provenance for producer and reviewer before
counting independent evidence; role names and planned primaries are insufficient.
If a worker fell back to the planned reviewer, reselect an eligible genuinely
independent reviewer; a static overlay cannot guarantee this on every execution.
With one eligible provider, output empty cross-provider chains and explicitly mark
critical **non-independent** (same-family/route review, not an independent gate).
Do not pretend a second subscription or proxy login creates model independence.
If no verified route can fulfill a required capability in a current allocation,
state the exact blocker instead of emitting a falsely usable overlay. In a future
preview, complete the conditional overlay when catalog/capability evidence supports
it and list unmet access/funding prerequisites separately. If even the proposed
scenario has no permitted potential route or required capability, identify that
specific blocker; do not invent a model, authorization, or capability.

## Required response

Return all of the following, without writing/applying files:

1. **Sources and date:** dated citations, recheck date/triggers, current-state
   observations, and explicit limits of available evidence.
2. **Plans and budget assumptions:** included/excluded providers with reasons,
   native-versus-OMP permission/funding distinctions, observed headroom and workload,
   recurring subscription total where supported, separately funded API/overage
   exposure (the OpenRouter judge credit and the Mistral plan allowance, neither on
   `omp usage`), and any unresolved material prerequisites. Mark each future route's
   assumptions and unmet prerequisites; distinguish them from verified facts.
   Never invent missing prices.
3. **A 15-row role table:** exact primary, ordered fallbacks, and brief allocation
   rationale. Explain single-provider and image constraints and actual-provenance
   requirements for critical review.
4. **One full valid OMP overlay**, JSON or YAML, matching the table. Label it
   **current verified allocation** or **conditional future-plan preview**; valid
   config structure is not verified access. For the requested future mix, supply
   the complete conditional alternative rather than reverting to current routing.
   `modelRoles`
   contains all 15 roles; `retry.fallbackChains` contains all 15 role keys, including
   empty arrays as needed, with no inherited wildcard or exact-model legacy chains.
   Include `task.agentModelOverrides` with exactly `security-reviewer: "@security"`,
   `reviewer: "@review"`, and `sonic: "@tiny"` (no `task` override: the bundled
   `task` agent binds `@task`; route `sonic` through a role, never a bare model, so
   its failover is not the `default` chain); `retry.usageAwareFallback: true`;
   `retry.usageReservePolicy: auto`; `cycleOrder: [smol, default, slow, sage]`; and
   `extendedContext: true`. Keep current custom agents unchanged; model bindings do
   not install their instruction contracts. List any required companion model
   override separately, without editing it or claiming a runtime check occurred.
5. **Fable decision and limits:** separate conclusions for `plan` and `slow` (architect agent),
   exact compared versions, evidence strength, access/budget prerequisites, why
   Fable or provisional Opus was chosen, and what could overturn the decision.

End by making clear this is an **unapplied alternative**, identifying its verified
or conditional status—not a changed live snapshot, proof of provider access,
measured performance result, or authorization to spend.
