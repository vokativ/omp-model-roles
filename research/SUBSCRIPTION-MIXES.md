# Four-provider subscription mixes (opt-in planning)

**Sources checked: 2026-10-08. Recheck on 2026-10-15**, and sooner if checkout,
terms, catalog, or account eligibility changes. This is not a new root snapshot:
`model-roles.yml`, the v32 allocation, custom agents, and existing logins stay unchanged.
No Max account or alternative mix was exercised against a provider. No local
quality, throughput, or quota benchmark was performed for this planning work.

The goal is to choose which pool should carry general work, reserve deeper models
for harder work, and retain a genuinely different model family for critical review.
Selection follows [../instructions/SELECT-MODEL-MIX.md](../instructions/SELECT-MODEL-MIX.md),
the single behavior contract for OMP, **not a standalone program** or price-to-token optimizer.
A subscription's native-app allowance, an API balance, and a technically reachable
OMP OAuth route are three different things. Buying a plan does not itself authorize
its use through OMP or fund API requests.

## Prices, products, and actual entitlements

USD reference prices below are public US/web prices unless stated otherwise, not
universal checkout quotes. Country, currency, tax, app-store channel, annual billing,
rollouts, trials, student/nonprofit offers, and account-specific promotions can change
both price and access. Confirm checkout before paying. Annual equivalents are not
monthly cancelable prices. No unsourced Lite/Heavy price or universal promo is assumed.
Organization licenses are included for comparison; evaluate their contracts and administrator controls separately.

### OpenAI: ChatGPT / Codex

The current [Codex pricing page][o-pricing] redirects to ChatGPT Work documentation.
It gives these prices and developer entitlements:

| Public SKU | Price | What matters for this mix |
|---|---|---|
| Free | $0 | Luna Standard in desktop, rollout-dependent; not the full CLI entitlement assumed by this planning example |
| Go | $8/month | Lightweight desktop Luna, rollout-dependent; not a substitute for Plus CLI access |
| Plus | $20/month | Full Codex web/CLI/IDE/iOS access, Sol and Luna; modest general-work pool |
| Pro $100 | $100/month | Bulk-work starting tier; lower allowances than higher Pro options |
| Pro $200 | $200/month | Higher Pro tier; choose on observed usage, not an inferred fixed task multiplier |
| Pro $500 | $500/month | Highest listed Pro tier; Astra Ultrafast access, not required by the example role map |
| Business | $25/user/month monthly; $20/user/month annually, minimum two users | Codex plus organization controls; shared workspace/credit terms need administrator review |
| Enterprise / Edu | Contact sales | Flexible credit-based or contracted per-seat limits; not a personal Pro alias |

Plus/Standard Business estimates are **15–160 Sol 6.1** or **350–3,000 Luna** local
messages per five hours, not guaranteed caps. Local and cloud work share allowances;
weekly caps may apply. Pro currently has no five-hour limit, **not unlimited use**.
Context, reasoning, tools, retrieval, caching, and speed mode affect consumption.
ChatGPT Work shares Codex usage. The source's subscription-credit rates are distinct
from API token rates; do not convert catalog dollars into subscription tasks.
[o-pricing] and [Pro help][o-pro] govern current details.
Current [Pro-tier help][o-pro] also warns that Pro $200 allowances are lower than
the historical tier: eligible grandfathered September 22–29 accounts retain their
previous allowance only through **2026-10-29**. Historical 5x/20x claims or existing
v32 usage readings cannot predict a new subscription's quota. Fast mode consumes
2.5x the included allowance and Astra Ultrafast 8x in the pricing table; these are
consumption rates, not speed guarantees.

ChatGPT subscriptions and developer API billing are [separate][o-billing]. An API
key has its own billed usage and model availability; Codex API-key access lacks
some cloud features. No included ChatGPT API credit is assumed. Verify current
provider permission for the installed OMP Codex integration, not just native Codex
access. No universal personal annual discount or referral reward is assumed; current
checkout and promotion terms are authoritative.

### Anthropic: Claude native plans and a separate API-credit benefit

[Claude pricing][a-pricing], [Max help][a-max], and [Team help][a-team] give:

| Public SKU | Price | Native allowance / API-credit distinction |
|---|---|---|
| Free | $0 | Limited native Claude access; no included monthly API credit |
| Pro | $20/month, or $200 upfront annually (advertised as $17/month) | Native Claude/Claude Code; no Max/Team monthly API-credit benefit |
| Max 5x | $100/month | 5x Pro per-session native allowance **and**, if claimed/eligible, $100 monthly Console API credit |
| Max 20x | $200/month | 20x Pro per-session native allowance **and**, if claimed/eligible, $200 monthly Console API credit |
| Team Standard | $25/seat/month monthly; $20/seat/month annually; minimum two seats | More native use than Pro; $20 monthly API credit per seat, pooled with Premium seats |
| Team Premium | $125/seat/month monthly; $100/seat/month annually; minimum two seats | 5x Standard native allowance; $100 monthly API credit per seat |
| Enterprise | $20/seat/month, billed annually, **plus usage at API rates** on current pricing FAQ; tailored sales terms available | Organization controls/usage billing; explicitly ineligible for Max/Team monthly API credits |

Native chat and Claude Code share a rolling five-hour allowance, paid weekly limits,
and possible other caps. Max's 5x/20x labels describe native per-session allowance,
not a guaranteed number of API calls or a Sonnet-versus-Opus depletion ratio.
There is no fixed message count. [Usage guidance][a-usage] explains dependence on
context, model, attachments, tools, and effort. Native usage credits/extra usage
are **not** the API-credit benefit below. Prices exclude tax. Discounted nonprofit
and scientist Team plans are also eligible for the API benefit; no discount amount
is inferred here. Educational/institutional arrangements require their own quote,
not substitution of personal Max or Team terms.
The current pricing model table includes Opus on paid plans and Sonnet/Haiku on
Free and paid plans. Fable is native usage-credit access on Pro and listed at
50% of weekly limits on Max, with caveats. These are native-product entitlements,
not third-party OAuth permission or proof of API/catalog availability. The static
alternative keeps Sonnet, Opus, and Haiku: **Opus 5.5 remains the provisional
`plan` and `architect` default**, with Fable 5.1 a credible conditional candidate,
not a categorically excluded family. See the
[2026-10-08 web comparison](FABLE-EVALUATION.md) and the role-specific decision below.
Historical Pro/Fable failures establish neither current quality nor future Max
access/quota economics. The user has no Fable access; this work sends no Fable requests.

#### New Max/Team monthly API credits: actionable route, not OAuth entitlement

The official [monthly API-credit article][a-credits] materially changes the planning
case for Max. It permits building your own apps/agents through the Claude Platform:

- Max 5x grants **$100**, Max 20x **$200** per monthly billing cycle. Team grants
  **$20 per Standard seat / $100 per Premium seat**, pooled into one balance with a
  **$500 monthly cap**. Credits are calculated from seats when granted.
- An active, good-standing plan must have been active for **seven days** before
  claiming. Rollout/account eligibility still matters; absent UI is not entitlement.
  Mobile subscribers claim on the web. No Console payment card is required.
- A Max subscriber, or Team Primary Owner/Owner, links **one** Console organization
  in Claude billing settings; they also need Owner/Admin/Billing permission in that
  Console organization. One organization receives credits from only one plan.
  The link cannot be changed self-service, so choose carefully.
- Credits refresh after billing payment (monthly even on annual plans), expire at
  cycle end, do not roll over, and are used **before purchased credits**. Every API
  key in the organization draws from the same pool. Workspace spend limits can
  constrain individual projects/teammates.
- They cover available Claude Platform models via Messages/Message Batches API,
  Console Playground, Managed Agents, and Agent SDK. They do **not** cover interactive
  Claude Code, native Claude/Cowork extra usage, or Bedrock/Vertex/Foundry.
  Self-run `claude -p`/Agent SDK with the linked organization's API key is specifically
  covered; a native-plan login, IDE/GitHub Action/desktop run is not equivalent.
- With **no other credits and no auto-reload**, API requests stop when the balance
  is exhausted. If purchased credits, auto-reload, or a sales-invoiced organization
  exist, usage can continue on those paid terms. This is not an unconditional $100
  bill cap. Canceling/downgrading stops future grants, not unexpired existing credits.

[Claude login policy][a-login] and [Claude Code legal guidance][a-legal] distinguish
native subscription use from third-party login/routing. A working local Claude OAuth
credential does **not** prove that Max native allowance is permitted or included for
OMP. The alternative below requires the **permitted API-key route**, with claimed
Max credits where available; Pro requires a separately funded API balance. A plan
can be considered for planning without being authorized, authenticated, or funded
for OMP. Following the selection instructions does not switch auth or claim credits.

### SpaceX / xAI / X: distinguish X bundles from standalone Grok

The current [xAI pricing page][x-pricing] is branded SpaceXAI. Its public product
names and the OMP provider name `xai-oauth` are not interchangeable entitlements.
[X Premium help][x-premium] (updated 2026-10-05, checked for this research) supplies
US web prices. Do not reuse older Premium+ price lists; checkout remains authoritative.

| Public SKU | Current price evidence | Planning interpretation, conditional on an authorized route |
|---|---|---|
| Grok Free | $0/month | Not selected for OMP work |
| X Basic | $3/month or $32/year | Social subscription, not a selected Grok pool |
| X Premium | $8/month or $84/year | Increased Grok use; light supplementary lane |
| X Premium+ | $40/month or $395/year | Includes SuperGrok; modest planning class, not Heavy |
| SuperGrok Lite | **Price unavailable in reviewed official page** | Light class only; verify price and model access at checkout |
| SuperGrok | $30/month | Standalone Grok, higher limits/frontier access; modest class |
| SuperGrok Plus | $100/month | Significantly higher usage/priority; bulk class |
| SuperGrok Heavy | **Price unavailable in reviewed official page** | Distinct from Plus; FAQ mentions an annual subscription, but no supported price here |
| Grok Business | **Price unavailable in reviewed official page** | Team-seat management/consolidated billing; organizational terms needed |
| Grok Enterprise | Contact sales | Organizational contract, not a consumer-plan alias |

X prices vary by region, tax, and web/iOS/Android purchase channel; annual charges
are upfront. Standalone Grok checkout/promotion/annual terms likewise need checking.
X and Grok accounts must be correctly linked for X subscription benefits; do not
assume two subscriptions are additive independent balances.

The [Grok FAQ][x-faq] describes **one shared weekly consumer usage pool** across
Chat, Imagine, Voice, Build, etc., with action-specific cost. Exhausted consumer
use can wait, upgrade, buy extra credits, or auto-top-up. These are **not developer
API credits**. [xAI API pricing][x-api] is a separate billing system. Neither these
sources nor X Premium help establishes third-party OMP OAuth entitlement or access
to every local model selector. All xAI recommendations remain conditional, with
explicit access caveats; do not buy a tier on the promise that OMP is included.

### Google: Google AI / Antigravity, not generic storage or API credit

The [Google AI plan page][g-ai] presents AI Plus, Pro, and Ultra, separate from plain
Google One storage. Its rendered US page omitted prices during research. Official
search snippets showed **Plus $4.99**, **Pro $19.99**, and **Ultra $99.99** monthly;
these are **snippet-only US indications, not verified checkout quotes**. Localized
pages showed different currency/benefits. The [Antigravity plan announcement][g-change]
provides a clear developer-tier reference: **Pro $20**, **Ultra $100 (5x Pro Gemini
tokens)**, **Ultra $200 (20x)**. It replaced the old $250 top-tier reference. Do not
collapse the two Ultra tiers into one $99.99 promise or assert a global annual price.

| Public SKU | Price evidence | Current developer planning access |
|---|---|---|
| Free | $0 | Antigravity Gemini, light weekly pool |
| Google AI Plus | $4.99/month official snippet only; checkout required | Light weekly Antigravity pool |
| Google AI Pro trial | Account-specific offer; payment method/renewal terms required | Pro-class Gemini pool; **no Claude 5.5** |
| Google AI Pro | $20 announcement; $19.99 snippet | Modest pool, including eligible Claude 5.5 access |
| Google AI Ultra lower | $100 announcement; $99.99 snippet indication | Bulk Gemini pool, 5x Pro tokens in announcement |
| Google AI Ultra upper | $200 announcement | Bulk Gemini pool, 20x Pro tokens in announcement |

[Current Antigravity plans][g-plans] specify Free/Plus weekly refresh and Pro/Ultra
five-hour refresh **with weekly caps**, not unlimited use or a fixed request count.
Flash and Pro consume **one shared Gemini pool**. Non-Gemini models have a separate
fixed rate limit: an Ultra Gemini multiplier is not a Claude multiplier. The
[model table][g-models] allows Gemini 3.8 Flash/3.1 Pro across tiers and Claude 5.5
only on **non-trial Pro/Ultra**. Old Claude 4.6 availability is not this example's
fallback strategy; removal is scheduled for 2026-11-02.

Overage credits are optional, with Never/Always controls. The announcement removed
base-plan Antigravity AI credits and offered a **$100 bonus expiring May 25, 2026**:
it is expired, not today's budget. Google AI page Cloud-credit benefits are different
from Antigravity overages and do not make Gemini API usage generally included.
Family storage sharing is not evidence of additive AI quota. [Offer terms][g-offer]
require eligible accounts/countries and qualifying payment methods, can differ from
paid limits, cannot generally be combined, and auto-renew at country price unless
canceled. Student and other promotions are account-specific.

The [June 18 migration announcement][g-migration] moved personal/free/Google One
Gemini CLI users to Antigravity CLI. Old consumer Gemini CLI tables of 1,000/1,500/
2,000 requests/day conflict with that change and are **not current promises**.
Separate [Gemini Code Assist business editions][g-business] list Standard at
**$22.80/user/month monthly or $19 annual commitment**, Enterprise at **$54 monthly
or $45 annual**. Organization CLI/agent mode quota is shared, with [organization
limits][g-cli] of 1,500/2,000 daily requests where the license supports them; these
are not personal Google AI caps. Workspace/Education/enterprise administration and
Gemini Enterprise Agent Platform terms are separate organizational products. Do not
infer generic Workspace subscription access to OMP, CLI, or API. [Gemini API][g-api]
and [Vertex AI][g-vertex] are separately billed. Antigravity native entitlements do
not alone establish authorization for every third-party OMP route.

## Recommended mixes by workload and paying tier

These are **recommendations [INFERENCE]**, not measured winners. Dollar totals use
rounded Google announcement prices and exclude tax, optional overages, API spend,
and unpriced SKUs. Retaining a provider you already pay for may make more sense than
adding subscriptions. **Eligible for planning** means worth considering in the
allocation discussion, never authorized/authenticated access, guaranteed capacity,
or entitlement to a catalog model. Native eligibility in provider terms remains a
separate claim. Qualitative workload labels below are not a fixed capacity-ranking
or tie-breaking algorithm; workload, permitted routes, budget, and observed pressure
drive the recommendation.

| Need / paying tier | Plans and approximate monthly subscription total | Main work pool and upgrade logic |
|---|---|---|
| Cheapest paid developer starting point | OpenAI Plus $20 + Google Free; no Anthropic/X: **$20** | Consider OpenAI for main work and Google for light default/vision and native independent review, conditional on authorized routes. Free/Go alone are not treated as full OMP Codex options |
| Cheap balanced | OpenAI Plus $20 + Google AI Pro ~$20; no Anthropic/X: **~$40** | Choose the main pool from workload and observed headroom, not a tier tie. Non-trial Google adds proxy depth while native Gemini can review independently. Optional X Premium adds $8 only after route permission is established |
| Anthropic-heavy alternative | Claude Max 5x $100 + OpenAI Plus $20 + Google AI Pro ~$20 + X Premium $8: **~$148**; omit Google/X for **$120** | Sonnet bulk work, selective Opus depth, OpenAI Sol critical; claim Max API credits and enforce Console budget prerequisites first. Fable plan/architect consideration remains evidence-dependent |
| Anthropic higher tier | Replace Max 5x with Max 20x: **~$248** for the four-provider mix | More native allowance and $200 monthly API credit, not unlimited OMP work; upgrade only on observed permitted API usage/need |
| OpenAI-heavy | Pro $100 + Google AI Pro ~$20; no Anthropic/X: **~$120** | Sol workers/depth, Luna cheap work; native Gemini independent critical. Pro $200/$500 totals ~**$220/$520**; the same example models do not justify paying more without useful capacity/features |
| Google-heavy | AI Ultra $100 + OpenAI Plus $20; no Anthropic/X: **~$120** | Flash general work, **native Gemini Pro** depth; Sol critical. Ultra $200 gives ~**$220**, not 20x Claude proxy capacity |
| xAI-heavy, conditional | SuperGrok Plus $100 + OpenAI Plus $20 + Google AI Pro ~$20; no Anthropic: **~$140** | Ask to assess xAI as the main pool: Build work and Grok 4.7 depth, Sol critical, only if those routes/models are authorized and available. Heavy is a distinct SKU with an unknown price; do not substitute an invented total |
| Existing modest four-provider subscriptions | Claude Pro $20 + OpenAI Plus $20 + Google AI Pro ~$20 + X Premium $8: **~$68 plus separately funded Anthropic API** | Not a subscription-only OMP budget. Choose the actual permitted/headroom-rich main route from workload and spending limits; do not automatically prefer Anthropic merely because tiers look alike |
| Team / organization | Match license, seats, organization billing, and permission rather than adding personal tiers | Team API pool caps at $500; shared OpenAI credits, Google organization licenses, xAI business contracts require administrators. Do not treat organizational contracts as personal-plan aliases |

If no authorized/funded route is established, show the conditional planning result
and the material missing prerequisites; do not invent free OMP authorization.
If a cheaper pool cannot sustain workers, consider the next paying tier **after a
full usage cycle**, not because a model's API price appears low. Current live v32
usage readings describe existing accounts, not future Max/Ultra/Heavy capacity.

## Ask OMP for an instruction-only preview

Read [../instructions/SELECT-MODEL-MIX.md](../instructions/SELECT-MODEL-MIX.md)
for the selection behavior. There is no separate selector executable or flag
interface. From an OMP session in this repository, paste an ordinary request:

```text
Read instructions/SELECT-MODEL-MIX.md and follow it. Preview a complete conditional
future allocation for Claude Max 5x ($100), ChatGPT Plus ($20), non-trial Google AI
Pro (about $20), and X Premium ($8). Main work: frequent implementation, planning,
and architecture review; occasional vision/design; one active machine.
Subscription budget: about $148/month, no additional paid API spend or top-ups.
Max API credits are not yet claimed and third-party route permissions are
unconfirmed; mark those as prerequisites rather than assuming access. Inspect
existing state/catalog read-only if available and ask only for material missing
information. Show all 17 roles, ordered fallback chains, agent bindings, the full
proposed overlay, rationale, provenance/independence limits, and access/budget
caveats. Compare Fable 5.1 with Opus 5.5 separately for plan and architect from
web evidence only. Do not modify files/config/auth, install a profile, subscribe,
buy credits, or send Fable/additional selected-model probe requests.
```

Replace the example's plans, workload, machines, budget, credit status, and permissions
with your actual facts. Explicitly say when a provider is absent or should be omitted;
an omission request does not cancel a subscription. OMP should not silently fill
material unknowns from the v32 setup. Read-only state/catalog inspection, where
available, distinguishes local model identity from account permission and budget.

**Preview is the default and does not apply changes.** Reading these files offline
sends no inference request. Asking OMP to follow the instructions uses your existing
OMP/model route and may consume its allowance; it is not an offline zero-call program.
Do not turn preview into selected-model probes, particularly Fable requests.
The static [../profiles/anthropic-heavy.yml](../profiles/anthropic-heavy.yml) is
an opt-in example, not auto-imported, an entitlement grant, or a budget controller.
Its local catalog references need no companion registration in the recorded catalog;
that does not guarantee the same catalog or access on another installation.
No OpenRouter/NVIDIA floor is inherited.

### Why plan and architect still use Opus 5.5

**[INFERENCE, web evidence checked 2026-10-08]** Keep both roles on Opus 5.5
provisionally in the unchanged static profile and 17-role table below. Public
analytical/workflow and long-horizon engineering proxies generally favor Opus;
no controlled head-to-head isolating OMP implementation planning or read-only
architecture review was found in the reviewed sources. This is not proof of a
role-wide winner. The [full evaluation](FABLE-EVALUATION.md) preserves source
citations, settings, uncertainty, fallback provenance, and cost/latency limitations;
its historical local Fable speed/depletion figures are withdrawn because those
requests fell back to OpenAI.

Fable 5.1 has meaningful counterevidence: [Artificial Analysis's original report](https://artificialanalysis.ai/articles/claude-opus-5-5)
finds better Fable rubric scoring despite Opus's analytical/presentation lead, and
[Endor Labs' original comparison](https://www.endorlabs.com/learn/opus-5-5-6x-cheaper-and-2x-faster-than-fable-5-1-but-memorization-keeps-it-off-the-top-spot)
finds better memorization-discounted functional/security correctness for Fable.
These are professional-artifact/coding-agent proxies, not direct planning or
architect-review results; Endor's harness versions and undisclosed effort differ.
Do not equate polish, aggregate coding success, or fast decoding with correctness.

- **Plan:** Opus is the provisional choice for requirement coverage,
  dependency/risk mapping, and runnable sequencing. Prefer Fable if future
  task-relevant evidence shows materially fewer missed requirements, incorrect
  dependencies, or unusable handoffs at acceptable cost and time.
- **Architect:** Opus is the provisional choice for evidence-grounded design
  trade-offs/review, with explicit external requirements to guard its documented
  narrow-feedback and self-authored-requirement failures. Prefer Fable if
  representative, preferably blind comparisons show fewer missed constraints or
  hazards and better root-cause reasoning/maintainability, or reproducibly resolve
  a demanding problem that tuned Opus cannot.

[Anthropic's model-selection guide](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model)
says to start most work with Opus and tune effort before escalating to Fable when
evals at `xhigh`/`max` still fall short. Its Fable “highest capability” description
is vendor positioning, not a universal benchmark ordering; more effort is not
automatically better. Fable's API list input/output prices are 2.5x Opus's at equal
billable token counts, **not** a per-task-cost or native-quota ratio. Actual effort,
cache mix, latency, tool load, and accepted output matter.

Neither reversal requires unavailable local tests now. Future selection needs
task-relevant evidence, verified catalog identity/capabilities, an authorized route,
and known funding/spending boundaries. Native Max's Fable weekly allowance is not
OMP entitlement; a permitted first-party API route could use claimed linked-org
credits only if the model is actually available there. Unclaimed credits, account
access, and permissions remain prerequisites for a conditional future preview,
not facts established by public benchmarks. Do not invent a Fable selector or add
default bindings absent justified public/task evidence and those prerequisites.
Same-provider Opus/Fable switching would be capability escalation, not a
cross-provider quota fallback; it does not change the ordered chains below.

### Anthropic-heavy full primary and fallback role map

These are **OMP 18.8.4 local catalog selectors**, not public SKU/model identifiers or
proof of third-party entitlement. For example, the public xAI page still advertises
Grok 4.6 while the installed OMP catalog includes `grok-4.7`. Do not turn a catalog
label into a public-release or account-access claim.

| Alias used below | Exact local selector |
|---|---|
| Sonnet | `anthropic/claude-sonnet-5-5` |
| Opus | `anthropic/claude-opus-5-5` |
| Haiku | `anthropic/claude-haiku-5-5:low` |
| Sol | `openai-codex/gpt-6.1-sol` |
| Luna | `openai-codex/gpt-6-luna` |
| Flash | `google-antigravity/gemini-3.8-flash` |
| Gemini Pro | `google-antigravity/gemini-3.1-pro` |
| Google Opus | `google-antigravity/claude-opus-5-5` |
| Build | `xai-oauth/grok-build` |
| Composer | `xai-oauth/grok-composer-2.5-fast` (text-only) |
| Grok | `xai-oauth/grok-4.7` |

| Role | Primary | Ordered fallback chain |
|---|---|---|
| `default` | Flash | Sonnet → Sol → Build |
| `smol` | Sonnet | Luna → Flash → Build |
| `slow` | Opus | Sol → Google Opus → Grok |
| `plan` | Opus | Sol → Google Opus → Grok |
| `architect` | Opus | Sol → Google Opus → Grok |
| `task` | Sonnet | Sol → Flash → Build |
| `good_worker` | Sonnet | Sol → Flash → Build |
| `review` | Sonnet | Sol → Google Opus → Grok |
| `security` | Sonnet | Sol → Google Opus → Grok |
| `vision` | Flash | Sonnet → Sol → Grok |
| `designer` | Grok | Sonnet → Sol → Flash |
| `commit` | Haiku | Luna → Flash → Build |
| `tiny` | Haiku | Luna → Flash → Build |
| `fast_worker` | Haiku | Luna → Flash → Build |
| `advisor` | Flash | Haiku → Luna → Build |
| `sage` | Opus | Sol → Google Opus → Grok |
| `critical` | **Sol** | **native Gemini Pro → Grok** |

Critical's chain excludes both the Anthropic producer family **and proxied Claude**;
it does not slide back to the producer via a different login. Independence is from
the selected heavy provider/model family, **not from every possible resolved worker**:
a producer that already fell back to Sol needs another genuinely independent review.
Record actual model provenance before counting independent evidence. With only one
authorized/available model family, explicitly disclose that critical cannot be independent.

The static overlay includes all 17 roles and all 17 role-keyed chains, plus
`task.agentModelOverrides` of `reviewer: @review`,
`security-reviewer: @security`, `sonic: @fast_worker`, `task: @good_worker`,
`retry.usageAwareFallback: true`, `retry.usageReservePolicy: auto`,
`cycleOrder: [smol, default, slow, architect, sage]`, and `extendedContext: true`.
It does not carry inherited unrelated settings, credentials, obsolete exact-model
fallback keys, or wildcard chains. Custom agents remain separately installed and
unchanged; selecting a model role does not install an agent instruction contract.

### Rederiving other mixes

Follow [../instructions/SELECT-MODEL-MIX.md](../instructions/SELECT-MODEL-MIX.md)
instead of treating this example as a fixed allocation algorithm. This full role
map records one Anthropic-heavy alternative, not a universal ranking or a rule to
exclude Fable. Reassess the primary work pool, role volume, depth needs, independent
review, multimodal support, ordered fallbacks, account pressure, and permitted budget
for the exact requested plans. A proxied Claude model may diversify authentication
or quota routes, but it does not provide independent Claude-family reasoning.

## Safe opt-in API-auth prerequisites

**Offline reading sends no requests; an OMP planning preview can use its existing
model allowance.** Running the proposed alternative is a separate provider trial
requiring explicit authorization and all access/budget prerequisites below. No
Fable inference is part of this planning work. Existing OAuth/current setup stays unchanged.

1. Confirm provider permission and account model availability for **each** selected
   route before running it. Omit unverified routes from an executable allocation,
   or retain them only as explicitly conditional planning candidates. The
   four-provider example is not proof that all four subscriptions fund OMP.
2. For Max, wait seven days, claim the offered API credits into the intended Console
   organization, and inspect amount/expiry. Generate an API key belonging to that
   organization. No claim, rollout delay, or Pro subscription means no assumed
   included API balance. Do not print the key or commit it to an overlay.
3. In **Claude Console**, use a non-invoiced organization with no purchased-credit
   balance and auto-reload disabled if the goal is "stop at included credits."
   Check billing and workspace limits before use. If existing paid balances or
   invoicing are required, establish provider-enforced limits consciously; do not
   assume the proposed retry config prevents spend. Never enable automatic paid
   top-ups just to make the alternative work. Keep Google overages at Never and
   xAI/OpenAI extra-credit purchases/top-ups disabled unless deliberately budgeted.
4. Use an **isolated OMP profile** for the API-key experiment, not the current auth
   store. Installed OMP 18.8.4 help documents `--profile` as isolating auth, sessions,
   settings, and caches. Configure **only Anthropic API-key auth** for Anthropic in
   a separate profile such as `anthropic-api`, plus legitimate authentication for
   the other selected providers (or ask for a preview omitting those providers).
   OMP's help says `ANTHROPIC_OAUTH_TOKEN` takes precedence over
   `ANTHROPIC_API_KEY`; unset the OAuth variable in the isolated process and ensure
   no stored Anthropic OAuth credential is selected in that profile. Merely adding
   an API key or passing `--config` does **not** prove API-key auth or isolate
   credentials. Do not log out, replace, or modify the current OAuth login.
5. Only after those prerequisites, select the isolated profile and run-only role
   overlay from the repo root:

   ```bash
   omp --profile anthropic-api --config ./profiles/anthropic-heavy.yml
   ```

   `--profile` selects the isolated environment; `--config` changes session routing,
   not Console billing. The role file contains no auth. No persistent
   `omp config set`, root import, profile/auth creation, or selected-provider probe
   is needed for the planning preview. The command above is a later authorized
   alternative-provider run, **not** offline reading or the planning request.
6. Inspect actual request auth/model provenance and Console billing when making
   a deliberately authorized trial. OMP OAuth usage meters do **not** monitor Max
   Console API-credit balance. `usageAwareFallback` is useful when a provider exposes
   a supported meter, but cannot guarantee preemptive API-budget switching or avoid
   purchased-credit/invoiced overage. Provider-enforced billing settings are the
   spending boundary. Exhaustion/error-driven fallback is not a budget guarantee.

The historical v32 README records existing local tests and usage observations;
those are not changed or reinterpreted as Max entitlement, future-tier headroom, or
an authorization conclusion. Recheck sources next week before making purchases.

## Local verification

On 2026-10-08, two ordinary OMP planning replies on the existing OpenAI Sol route
exercised the instruction: the four-provider Anthropic-heavy future mix, and a
Google Pro trial/no-xAI variant. Both completed without tool calls or Fable requests.
Their full 17-role overlays matched their response tables and passed catalog,
image-input, provider-exclusion, trial-eligibility, and critical-family checks.
The Anthropic-heavy proposal matched the unchanged static profile. Read-only OMP
RPC loaded its overlay and resolved all 17 primaries; the trial variant's designer
and critical also resolved correctly. RPC state checks sent no inference requests.

These are instruction/configuration checks, not Fable/Opus performance measurements,
Max API-credit eligibility checks, route-permission verification, or future-capacity
proof. Ordinary planning consumed the existing OpenAI model's allowance; no proposed
Anthropic/Google/xAI role model was exercised. No language server or project
formatter is configured for these Markdown/config-only changes.

## Official sources

[o-pricing]: https://developers.openai.com/codex/pricing
[o-pro]: https://help.openai.com/en/articles/9793128-about-chatgpt-pro-plans
[o-billing]: https://help.openai.com/en/articles/9039756-managing-billing-for-the-chatgpt-and-api-platform
[a-pricing]: https://claude.com/pricing
[a-max]: https://support.claude.com/en/articles/11049741-what-is-the-max-plan
[a-team]: https://support.claude.com/en/articles/9266767-what-is-the-team-plan
[a-usage]: https://support.claude.com/en/articles/9797557-usage-limit-best-practices
[a-credits]: https://support.claude.com/en/articles/17154008-monthly-api-credits-for-max-and-team-plans
[a-login]: https://support.claude.com/en/articles/13189465-log-in-to-your-claude-account
[a-legal]: https://code.claude.com/docs/en/legal-and-compliance
[x-pricing]: https://x.ai/pricing
[x-premium]: https://help.x.com/en/using-x/x-premium
[x-faq]: https://docs.x.ai/grok/faq
[x-api]: https://docs.x.ai/developers/pricing
[g-ai]: https://one.google.com/intl/en_us/about/google-ai-plans/
[g-change]: https://antigravity.google/blog/changes-to-antigravity-plans
[g-plans]: https://antigravity.google/docs/plans
[g-models]: https://antigravity.google/docs/models
[g-offer]: https://one.google.com/offer/freetrial
[g-migration]: https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli
[g-business]: https://codeassist.google/products/business
[g-cli]: https://geminicli.com/docs/resources/quota-and-pricing/
[g-api]: https://ai.google.dev/gemini-api/docs/pricing
[g-vertex]: https://cloud.google.com/vertex-ai/pricing
