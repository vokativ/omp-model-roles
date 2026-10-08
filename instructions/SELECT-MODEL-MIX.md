# Select an alternative OMP model mix

**Instruction updated: 2026-10-08. Source baseline: 2026-10-08; recheck by
2026-10-15**, or immediately after a plan, permission, price, catalog, or eligibility
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
provider trial requests; with no Fable access, send **no Fable requests**.
An ordinary planning reply from the existing OMP session uses its already-selected
model and may consume that session's existing allowance; it is not a selected-model
trial or verification of the proposed routes.

Scope is exactly the four requested provider groups: **OpenAI, Anthropic, Google,
and SpaceX/xAI/X**. Do not allocate to other providers or change their existing
logins/settings unless the user explicitly extends the scope.

Read [subscription research](../research/SUBSCRIPTION-MIXES.md), the
[research playbook](../research/RESEARCH-PLAYBOOK.md), and
[Fable evaluation](../research/FABLE-EVALUATION.md), then current `model-roles.yml`,
`models-overlay.yml`, relevant agent bindings, and any supplied plans/usage notes.
This instruction's **proposal-only** scope overrides the playbook's apply/ship
workflow and historical executable-selector directions. Existing allocations,
profiles, past failures, and prior checks are evidence with dates, not today's
mandatory winner or proof of a new account's entitlement.

When available, inspect current config, usage windows/reset times, and model
catalog **read-only** (for example, existing OMP config getters, `omp usage`, and
`omp models`). Do not initiate login, expose secrets, or probe models. If unavailable,
state that limitation and use supplied evidence without inventing measurements.
Ask only for missing **material** subscription, budget, or route-permission facts
that cannot be obtained from available evidence and actually prevent planning the
requested scenario; do not repeat answered questions. Label other assumptions.

Distinguish a **current verified allocation** from a **conditional future-plan
preview**. For a requested future mix (for example, Max next week with unclaimed
credits and no Fable access today), provide a complete conditional 17-role proposal,
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
5. **Evaluate Fable 5.1 versus Opus 5.5 separately for `plan` and `architect`.**
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
   - **Architect:** retain Opus provisionally for source-grounded trade-offs/design
     review, while guarding its documented narrow-feedback and self-authored-requirement
     failure modes. Favor Fable if task-relevant, preferably blind comparisons show
     fewer missed constraints/hazards or better root-cause reasoning and maintainability,
     or it reliably solves a demanding design problem on which tuned Opus falls short.
   Either change requires an authorized, funded route and exact installed catalog
   identity. Official API list prices/latency evidence are not native-quota ratios
   or a user's budget measurement. No Fable access is available now: keep this
   comparison web-only, without demanding local tests, probing, inventing a selector,
   or binding Fable by default. Describe future permission/catalog/credit prerequisites.
   If Opus is also ineligible, choose an eligible depth route and explain why.
   Same-provider Opus/Fable switching is a capability choice, **not cross-provider
   quota fallback**; keep fallback chains within the routing contract below.
6. The existing **Anthropic-heavy example**—Sonnet workers/review, Opus depth,
   Haiku cheap roles, Google default/vision/advisor, and OpenAI critical—is one
   candidate, **not the mandatory allocation**. Alternatives within these four
   provider groups may favor Anthropic, OpenAI, Google, or xAI according to packages,
   workload, headroom, permission, and evidence. Explain route ordering individually.

## Complete role and routing contract

Cover these **17 roles**, with a primary and an ordered fallback chain for each:

| Role | Work to account for |
|---|---|
| `default` | Every-turn general work and reader-facing output |
| `smol` | High-volume dispatch/classification and opted-in implementation |
| `slow` | Difficult full-task reasoning/prewalk |
| `plan` | Planning before implementation; explicit Fable/Opus decision |
| `task` | General delegated work |
| `designer` | Design/image review; image-input-capable routes only |
| `vision` | Image understanding; image-input-capable routes only |
| `commit` | Infrequent commit-message work |
| `advisor` | Per-turn advice; count its added pool load |
| `tiny` | Small low-stakes work |
| `architect` | Frequent technical/architecture review; explicit Fable/Opus decision |
| `review` | Code review |
| `security` | Security review |
| `critical` | Adversarial independent final review |
| `fast_worker` | Fast, bounded delegated work |
| `good_worker` | General implementation work |
| `sage` | Deep thinking/ideation |

Use exact catalog selectors eligible for the verified allocation or explicitly
conditional future scenario, including supported reasoning suffixes.
Every `vision`/`designer` primary **and fallback** must accept image input; text-only
Composer is not an image route. Check companion model overrides if a route needs
one; do not silently inherit unrelated models or settings.

Chains must exclude the primary's entire routing provider, deduplicate selectors,
and use distinct eligible routing providers across fallback tiers wherever possible.
A different model on the same exhausted provider is not cross-provider resilience.
Empty chains are valid when no eligible alternative exists; warn, do not fabricate.
Proxy Claude can diversify a route/pool but is still the Claude model family.

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
   exposure, and any unresolved material prerequisites. Mark each future route's
   assumptions and unmet prerequisites; distinguish them from verified facts.
   Never invent missing prices.
3. **A 17-row role table:** exact primary, ordered fallbacks, and brief allocation
   rationale. Explain single-provider and image constraints and actual-provenance
   requirements for critical review.
4. **One full valid OMP overlay**, JSON or YAML, matching the table. Label it
   **current verified allocation** or **conditional future-plan preview**; valid
   config structure is not verified access. For the requested future mix, supply
   the complete conditional alternative rather than reverting to current routing.
   `modelRoles`
   contains all 17 roles; `retry.fallbackChains` contains all 17 role keys, including
   empty arrays as needed, with no inherited wildcard or exact-model legacy chains.
   Include `task.agentModelOverrides` with `security-reviewer: "@security"`,
   `reviewer: "@review"`, `sonic: "@fast_worker"`, and `task: "@good_worker"`;
   `retry.usageAwareFallback: true`; `retry.usageReservePolicy: auto`;
   `cycleOrder: [smol, default, slow, architect, sage]`; and
   `extendedContext: true`. Keep current custom agents unchanged; model bindings do
   not install their instruction contracts. List any required companion model
   override separately, without editing it or claiming a runtime check occurred.
5. **Fable decision and limits:** separate conclusions for plan and architect,
   exact compared versions, evidence strength, access/budget prerequisites, why
   Fable or provisional Opus was chosen, and what could overturn the decision.

End by making clear this is an **unapplied alternative**, identifying its verified
or conditional status—not a changed live snapshot, proof of provider access,
measured performance result, or authorization to spend.
