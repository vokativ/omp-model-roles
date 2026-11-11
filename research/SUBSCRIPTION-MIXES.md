# Four-provider subscription mixes (opt-in planning)

**Sources checked: 2026-10-08. Recheck on 2026-10-15 (overdue; only the Mistral section was
rechecked, on 2026-11-03)**, and sooner if checkout,
terms, catalog, or account eligibility changes. This is not a new root snapshot:
`model-roles.yml`, the live allocation (v38), custom agents, and existing logins stay unchanged.
No Max account or alternative mix was exercised against a provider. No local
quality, throughput, or quota benchmark was performed for this planning work.

**Updated 2026-10-20:** the live root `model-roles.yml` is now snapshot v35 (not
v32): `sage` runs on `anthropic/claude-fable-5-1` (provisional, reversible) and
`openai-codex/gpt-6-astra` is in no role and no chain. The 17-role map below is the
static Anthropic-heavy alternative (sage on Opus), not the live v35 allocation. Also
on 2026-10-20, two OMP access probes (delivered model ids verified from events) were
accepted: Astra on a ChatGPT Plus account and Fable 5.1 via Max 5x OAuth. That
supersedes "no Max account was exercised" and "no Fable access" for the owner's own
accounts only; it is a reachability observation, not a permission or quota guarantee.

**Updated 2026-11-03:** the live root `model-roles.yml` is now snapshot v37.1 (v37 earlier the
same day), superseding the v35 references above. Two changes sit outside the four provider
groups: the `judge` role runs on `typesafe/jev-1.14.0` (a direct native judgment model billed
to TypeSafe prepaid credit via an existing `/login typesafe` API key), with
`openrouter/typesafe/jev-1.14`, `openrouter/typesafe/jev-1.13`, and `openrouter/liquid/d1.1`
as native fallbacks billed to OpenRouter prepaid credit (v37 ran judge on OpenRouter first),
and an existing `mistral` login (Mistral Education plan key)
supplies bounded fallback hops in `smol`, `tiny`, `task`, and `review`, never a primary.
See the [Mistral section](#mistral-education-plan-key-fallback-hops-and-v38-default) and
[MISTRAL-EVALUATION.md](MISTRAL-EVALUATION.md). Only the Mistral section was checked on
2026-11-03: the other provider sections still date from 2026-10-08 (the 2026-10-15
recheck date has passed), and the 17-role map below was not revised for the 15-role
contract (it is now labelled historical; see the v38 note below).

**Updated 2026-11-03 (v38):** the live root `model-roles.yml` is now snapshot v38, superseding the
v37.1 reference above. The `default` role runs on `mistral/zai-glm-5-3` (owner decision; the one
Mistral primary), with fallbacks `google-antigravity/gemini-3.8-flash` -> `anthropic/claude-sonnet-5-5`;
the "never a primary" and four-role wording in the paragraph above describes v37.1. Rationale:
[DEFAULT-ROLE-EVALUATION.md](DEFAULT-ROLE-EVALUATION.md). The owner's admin page that day shows two
separate Education allowances, **$15/mo Included API usage** and **$150/mo Included Vibe Code
usage** (both reset on the 1st of each calendar month; PAYG for both off); OMP's `/login mistral`
key is inferred to draw the $150 Vibe Code allowance, which corrects the "$15" planning figure in the
Mistral section below (v37 inferred it from the pricing card's API-credit line).

**v38 status of the role map below:** the 17-role map and table in "Anthropic-heavy full primary
and fallback role map" is the historical 2026-10-08 design (pre-v36: `architect`, `designer`,
`good_worker`, `fast_worker` were removed in v36). The current 15-role map is the `modelRoles`,
`retry.fallbackChains`, and `cycleOrder` in [../model-roles.yml](../model-roles.yml).
The former `profiles/anthropic-heavy.yml` run-only copy was removed in v40; use
`../model-roles.yml` itself as the run-only overlay. It is not the 17-role table.

**Updated 2026-11-11 (v39/v40):** `sage` now runs on `anthropic/claude-fable-5-2` (owner decision;
Fable 5.1 since v35), with a new model-level failover chain key `anthropic/claude-fable-5-2` in the
same order; the `anthropic/claude-fable-5-1` and `anthropic/claude-fable-5` chains are retained.
No quality claim is made for 5.2 over 5.1. v40 turns `extendedContext` off (Codex Sol 500K, Luna
272K); see [../CHANGELOG.md](../CHANGELOG.md).

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
| Plus | $20/month | Full Codex web/CLI/IDE/iOS access, Sol and Luna, plus limited Astra (Help Center and Codex pricing; the learn.chatgpt.com Plus card lists only Sol/Luna, see the 2026-10-20 note below); modest general-work pool |
| Pro $100 | $100/month | Bulk-work starting tier; lower allowances than higher Pro options |
| Pro $200 | $200/month | Higher Pro tier; choose on observed usage, not an inferred fixed task multiplier |
| Pro $500 | $500/month | Highest listed Pro tier; Ultrafast (8x burn, applies to Sol 6.1 as well as Astra) is Pro $500/Enterprise only, not required by the example role map |
| Business | $25/user/month monthly; $20/user/month annually, minimum two users | Codex plus organization controls; shared workspace/credit terms need administrator review |
| Enterprise / Edu | Contact sales | Flexible credit-based or contracted per-seat limits; not a personal Pro alias |

Plus/Standard Business estimates are **5–45 Astra**, **15–160 Sol 6.1** (Sol 6:
15–150), or **350–3,000 Luna** local messages per five hours, not guaranteed caps.
Local and cloud work share allowances; weekly caps may apply. Pro currently has no five-hour limit, **not unlimited use**.
Context, reasoning, tools, retrieval, caching, and speed mode affect consumption.
ChatGPT Work shares Codex usage. The source's subscription-credit rates are distinct
from API token rates; do not convert catalog dollars into subscription tasks.
[o-pricing] and [Pro help][o-pro] govern current details.
Current [Pro-tier help][o-pro] also warns that Pro $200 allowances are lower than
the historical tier: eligible grandfathered September 22–29 accounts retain their
previous allowance only through **2026-10-29**. Historical 5x/20x claims or existing
v32 usage readings cannot predict a new subscription's quota. Fast mode consumes
2.5x the included allowance and is available on Plus; Ultrafast consumes 8x, applies
to Sol 6.1 as well as Astra, and needs Pro $500/Enterprise. These are consumption
rates in the pricing table, not speed guarantees.

**Updated 2026-10-20, Plus and Astra:** OpenAI's Help Center and Codex pricing say Plus
"includes limited GPT-6 Astra usage"; the learn.chatgpt.com Plus card lists only Sol
and Luna, so the sources are inconsistent. The pricing-table subscription-credit
rates per million tokens (input/cached/output) are Astra 250/25/1250, Sol 6.1
50/2.5/250, Luna 2.5/0.25/12.5 (API list: Astra $10/$50, Sol 6.1 $2/$10, Luna
$0.10/$0.50). A 2026-10-20 probe showed OMP's Codex OAuth route accepts
`openai-codex/gpt-6-astra` on a Plus account (delivered id verified). `omp usage`
shows one 5h and one 7d chat meter (plan: plus) with no Astra-specific meter, so
Astra shares the Plus meter with Sol. A coarse burn probe saw 13.8K Astra tokens
move the meter one point, the same as 40.8K Sol tokens; at whole-percent granularity
that supports only a hypothesis of roughly 3-5x per token, not a measured ratio.
Plus is the binding burst pool: its 5h window hit 100% five times 2026-10-17..19.

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
not third-party OAuth permission or proof of API/catalog availability. The historical
17-role alternative keeps Sonnet, Opus, and Haiku: **Opus 5.5 remained the provisional
`plan` and `architect` default** (2026-10-08; since v36 there is no `architect` role, the
`architect` agent is bound to `@slow`, which is Opus 5.5), with Fable 5.1 a credible conditional candidate,
not a categorically excluded family. See the
[2026-10-08 web comparison](FABLE-EVALUATION.md) and the role-specific decision below.
Historical Pro/Fable failures establish neither current quality nor future Max
access/quota economics. **Updated 2026-10-20:** the 2026-10-08 premise that the user
has no Fable access is superseded. An OMP probe (`omp -p --no-session --no-tools`,
delivered id verified) was accepted for `anthropic/claude-fable-5-1` via Max 5x
OAuth with no `credits_required`, unlike the 2026-09-04 Claude Pro 429. Metering
facts above still hold: Fable has its own 7d sub-meter (13% on 2026-10-20) inside
the shared weekly pool (7d 41% used, resets 2026-10-23 16:00Z), up to 50% of the
weekly limit, with no published multiplier; its movement so far came from Claude
Code usage (522 messages), not OMP. Acceptance shows the route is reachable, not that
third-party-harness use is sanctioned (see the login-policy sources below and
OMP issue 12487); Max's $100 API credit covers API-key use, not OAuth. Planning
previews in this repo still send no Fable requests.

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

### Mistral: Education plan key, fallback hops and v38 default

Mistral is not one of the four requested provider groups and is in no total below. The
repo keeps one existing `mistral` login (an OMP `/login mistral` plan key on a Mistral
Education account): fallback hops in `smol`, `tiny`, `task`, and `review`, `mistral-large-4`
in `vision` (v37.2), and since v38 the owner-chosen `default` primary (`mistral/zai-glm-5-3`),
the one exception allowed by
[../instructions/SELECT-MODEL-MIX.md](../instructions/SELECT-MODEL-MIX.md); the model
evidence is in [MISTRAL-EVALUATION.md](MISTRAL-EVALUATION.md). **Sources checked
2026-11-03.** "Mistral Vibe" here is Mistral's coding product (CLI, IDE, web), not OMP's
good/fast "Vibe" worker tiers.

| Public SKU | Price | What matters for this repo |
|---|---|---|
| Free | $0 | Limited Mistral Vibe access (chat, search, limited coding sessions) plus Mistral Studio ([pricing FAQ][m-pricing]); its allowance is not evaluated here |
| Pro | $14.99/month, excluding tax ([pricing][m-pricing]) | Mistral Vibe CLI, IDE, and web, more messages and web searches; the card lists "$25.5 /mo in API credits" (a third-party snapshot dated Oct 1, [Kunavo](https://kunavo.com/guides/mistral-vibe-pricing), lists $30, so the figures differ) |
| Education | $5.99/month, excluding tax ([pricing][m-pricing]) | The [help article][m-edu] (dated 2026-08-12) calls it "the Pro plan with a discount" for eligible students and teachers and requires a verified institutional email (student ID or enrollment letter not accepted). The pricing card limits it to a maximum of 12 months for verified students at accredited higher-education institutions who have not used Vibe (or Le Chat) before. Same Mistral Vibe CLI, IDE, and web access; the card lists "$15 /mo in API credits". The renewal price after 12 months is not stated. The owner reports paying about $5/month |
| Team | $24.99/user/month ([pricing][m-pricing]) | "Even higher limits"; organization terms not evaluated |
| Enterprise | Contact sales | Private deployments; not a personal-plan alias |

The Pro card's "$25.5 /mo in API credits" and the Education card's "$15 /mo in API
credits" differ although the help article calls Education Pro with a discount, so the
sources disagree on whether Education carries Pro's allowance. This repo plans on the
$150/mo Vibe Code allowance the OMP key is inferred to draw (v38); the card's $15 is the
separate API allowance.

**Allowance and reset.** "Each Mistral plan includes monthly usage that is shared across
Studio, the API, and Vibe Code. Usage consumes this monthly allowance first"
([subscriptions][m-subs]); plans are global across Mistral Vibe, Studio, and API
([key and profile notes][m-keys]), so the owner's own Mistral Vibe CLI use draws on the
same allowance as OMP. The size is **not published** in tokens or requests, only "fair
usage limits" ([pricing][m-pricing]); no per-model multiplier is documented, and
overage is "at API rate". The reset is the **1st of the calendar month** (v38 correction
below; v37 read it as a "billing period"): "the plan can
stop working until the next billing period" ([FAQ][m-faq]); no five-hour or weekly
window is documented. **[INFERENCE]** the $150 is the allowance in API-priced dollars
(the card line, the docs' "included monthly usage", and "at API rate"). At
[Mistral API prices][m-api-pricing], $150 buys roughly 1,140 GLM-5.3 agent sessions (200k
input, 80% cached, 12k output) or 8,930 GLM-5.3 Flash sessions: a planning ratio, not a
quota.

**v38 correction (owner's admin.mistral.ai/subscription page, 2026-11-03).** The page shows two
separate allowances, each resetting on the 1st of each calendar month: Included API usage ($0 of $15
used) and Included Vibe Code usage ($5.35 of $150 used), with pay-as-you-go off for both. **[INFERENCE]**
OMP's `/login mistral` key draws the $150 Vibe Code allowance (API usage stayed $0 after a day of OMP
calls). The v37 text this paragraph corrected (the "$15" planning figure, the "billing period" reset
wording, 114/893-session ratios) has been edited in place above to $150/mo and calendar-month reset.

**Exhaustion.** With pay-as-you-go (PAYG) off, the default, Mistral Vibe stops until the
next period ([key and profile notes][m-keys]). With PAYG on, usage past the plan draws
prepaid credits and requests fail with **HTTP 402** at a zero balance; PAYG needs
prepaid credits, and partner-bought Pro plans (Google, Apple, Free Mobile, Orange)
cannot enable it ([billing][m-billing]). Whether Education can enable PAYG is
unverified. The observed plan-budget error is
`402 {"code":"2304","type":"billing_vibe_budget_exhausted"}`, reported even with PAYG
active and credits, on a Free plan with a "vibe"-type key ([issue 1362][m-issue-1362]).
No exhaustion was produced or observed on this account; OMP's default
`retry.fallbackOn: any` is expected to walk the chain on that error **[INFERENCE]**.

**No OMP usage meter.** `omp usage` shows no Mistral section (2026-11-03), and no usage
or quota endpoint worked with this key: Mistral Vibe CLI 3.0.4 calls only
whoami/account-context, managed-config, experiment-eval, event, and connector-bootstrap
endpoints and has no usage command (its
November plan lists "Monthly usage indication in the TUI" as not yet done,
[issue 1366][m-issue-1366]), and direct probes of console and API usage and billing
paths returned 401 or 404. The live meter is console-only:
<https://console.mistral.ai/codestral/cli> ("View organization usage"),
<https://admin.mistral.ai/subscription> (plan, included usage, estimated usage, PAYG
toggle), and <https://admin.mistral.ai/organization/usage> ("Vibe usage beyond quota").

**Plan key versus Studio key.** `/login mistral` mints a key through Mistral Vibe CLI's
browser sign-in flow. The key has "vibe" scope (whoami `plan_type` CHAT, `plan_name`
EDU) and bills the plan's Mistral Vibe budget. A "Studio"-type key made in the console
bills PAYG or Free-mode usage and is governed by API rate limits ([FAQ][m-faq]; in
issue 1362 a vibe-type key hit 402 despite PAYG credits and a Studio-type key fixed it).
A third-party OMP extension,
[omp-mistral-subscription](https://github.com/Gauthier-Huguenin/omp-mistral-subscription),
claims 12 requests and 46k completion tokens moved the "Vibe Code" counter and not the
API-credit counter (the author's claim; models unspecified). The sources conflict: the
help article says "API rate limits are not the same as your Vibe plan budget", while
the undated docs pages describe one shared pool. Non-Vibe models (DeepSeek V4.1 Flash
1017, Ministral 3B/8B/14B, Codestral, Large 3, Small 4) answered 1-token probes through
this key and no document excludes any model from the shared allowance, so
**[INFERENCE]** all draw on it; nothing directly confirms DeepSeek or Ministral usage
lands on the Mistral Vibe meter. `has_paid_vibe_entitlement: false` in Mistral Vibe's
local whoami cache is a client default (the raw response has no such field) that only
suppresses an upgrade prompt; it does not mean Education lacks Mistral Vibe. Mistral
Vibe usage is included on Education by indirect evidence only: the help article, the
card's "Full access to Vibe for all-day coding", the Mistral Vibe maintainer saying
Large 4 requires "the Pro plan" ([issue 1366][m-issue-1366], 2026-10-30), and the CLI's
extra-model list, which is empty for a Free account but names Large 4, GLM-5.3, and
GLM-5.3 Flash for Education. The quota counter itself was not observed.

**Models** (details in [MISTRAL-EVALUATION.md](MISTRAL-EVALUATION.md)). The Education
account's Mistral Vibe CLI defaults to GLM-5.3 (Mistral-hosted, per a remote experiment
flag fetched 2026-11-03). The only catalog ids this repo uses are
`mistral/zai-glm-5-3-flash` (image input, 1M context, $0.15/$0.5 per million tokens;
[Artificial Analysis](https://artificialanalysis.ai/leaderboards/models) Intelligence
Index v5.0 27.8, Terminal-Bench 4.0 32.8%) and `mistral/zai-glm-5-3` (text-only, 1M
context, $1.4/$4.4; Index 31.7, Terminal-Bench 4.0 41.9% against 19.7% for Gemini 3.8
Flash). No Mistral-accessible model is a depth peer: the best Index is 32.5, against
Opus 5.5 at 58.4 and Sol 6.1 at 54.5. Large 4 and DeepSeek V4.1 Flash 1017 are labelled
public preview on Mistral's pages; Large 4's 41% Terminal-Bench 4.0 figure is from
Mistral's own Mistral Vibe harness (24.7% in Artificial Analysis's generic harness);
Medium 3.5 is deprecated (2026-10-31, per the [Mistral model docs][m-models]) at 0.0%
Terminal-Bench 4.0. Alias ids (`mistral-medium-3.5`, `zai-glm-5`, `mistral-vibe-cli-*`)
lack OMP catalog metadata and are not selectors.

**Cancellation and data.** Refunds are only within 14 days of the initial purchase;
otherwise access lasts to period end, then Free mode ([help 455205][m-help-455205],
[help 568728][m-help-568728]). The pricing card lists model-training opt-out for Pro;
the plan key falls under Mistral's [consumer terms][m-terms], and **[INFERENCE]** the
same applies to Education. OMP's provider docs describe `/login mistral` as minting a
plan-tied key; Mistral's terms for use through a third-party harness were not reviewed.

**Not verified:** the live meter reading over time, per-model weighting of the allowance (the
$150 Vibe Code draw by the OMP key is an inference), whether Education can enable PAYG (both PAYG
toggles show "Enable", i.e. off, on 2026-11-03), and the renewal price after the 12-month limit.

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
| Anthropic-heavy alternative | Claude Max 5x $100 + OpenAI Plus $20 + Google AI Pro ~$20 + X Premium $8: **~$148**; omit Google/X for **$120** | Sonnet bulk work, selective Opus depth, OpenAI Sol critical (live v38 `critical` is Sol; `default` is Mistral GLM-5.3, not Sonnet); claim Max API credits and enforce Console budget prerequisites first. Fable plan/architect consideration remains evidence-dependent |
| Anthropic higher tier | Replace Max 5x with Max 20x: **~$248** for the four-provider mix | More native allowance and $200 monthly API credit, not unlimited OMP work; upgrade only on observed permitted API usage/need |
| OpenAI-heavy | Pro $100 + Google AI Pro ~$20; no Anthropic/X: **~$120** | Sol workers/depth, Luna cheap work; native Gemini independent critical. Pro $200/$500 totals ~**$220/$520**; the same example models do not justify paying more without useful capacity/features |
| Google-heavy | AI Ultra $100 + OpenAI Plus $20; no Anthropic/X: **~$120** | Flash general work, **native Gemini Pro** depth; Sol critical. Ultra $200 gives ~**$220**, not 20x Claude proxy capacity |
| xAI-heavy, conditional | SuperGrok Plus $100 + OpenAI Plus $20 + Google AI Pro ~$20; no Anthropic: **~$140** | Ask to assess xAI as the main pool: Build work and Grok 4.7 depth, Sol critical, only if those routes/models are authorized and available. Heavy is a distinct SKU with an unknown price; do not substitute an invented total |
| Existing modest four-provider subscriptions | Claude Pro $20 + OpenAI Plus $20 + Google AI Pro ~$20 + X Premium $8: **~$68 plus separately funded Anthropic API** | Not a subscription-only OMP budget. Choose the actual permitted/headroom-rich main route from workload and spending limits; do not automatically prefer Anthropic merely because tiers look alike |
| Team / organization | Match license, seats, organization billing, and permission rather than adding personal tiers | Team API pool caps at $500; shared OpenAI credits, Google organization licenses, xAI business contracts require administrators. Do not treat organizational contracts as personal-plan aliases |

If no authorized/funded route is established, show the conditional planning result
and the material missing prerequisites; do not invent free OMP authorization.
If a cheaper pool cannot sustain workers, consider the next paying tier **after a
full usage cycle**, not because a model's API price appears low. Current (v38) live
usage readings describe existing accounts, not future Max/Ultra/Heavy capacity.

## Ask OMP for an instruction-only preview

Read [../instructions/SELECT-MODEL-MIX.md](../instructions/SELECT-MODEL-MIX.md)
for the selection behavior. There is no separate selector executable or flag
interface. From an OMP session in this repository, paste an ordinary request:

```text
Read instructions/SELECT-MODEL-MIX.md and follow it. Preview a complete conditional
future allocation for Claude Max 5x ($100), ChatGPT Plus ($20), non-trial Google AI
Pro (about $20), and X Premium ($8). Main work: frequent implementation, planning,
and architecture review; occasional vision; one active machine.
Subscription budget: about $148/month, no additional paid API spend or top-ups.
Max API credits are not yet claimed and third-party route permissions are
unconfirmed; mark those as prerequisites rather than assuming access. Inspect
existing state/catalog read-only if available and ask only for material missing
information. Show all 15 roles, ordered fallback chains, agent bindings, the full
proposed overlay, rationale, provenance/independence limits, and access/budget
caveats. Compare Fable 5.1 with Opus 5.5 separately for plan and architect (`slow`) from
web evidence only. Do not modify files/config/auth, install a profile, subscribe,
buy credits, or send Fable/additional selected-model probe requests.
```

Replace the example's plans, workload, machines, budget, credit status, and permissions
with your actual facts. Explicitly say when a provider is absent or should be omitted;
an omission request does not cancel a subscription. OMP should not silently fill
material unknowns from the current (v38) setup. Read-only state/catalog inspection, where
available, distinguishes local model identity from account permission and budget.

**Preview is the default and does not apply changes.** Reading these files offline
sends no inference request. Asking OMP to follow the instructions uses your existing
OMP/model route and may consume its allowance; it is not an offline zero-call program.
Do not turn preview into selected-model probes, particularly Fable requests.
Since v40 the run-only overlay is [../model-roles.yml](../model-roles.yml) itself (the former
`profiles/anthropic-heavy.yml` copy was removed); used via `--config` it is not
installed, auto-imported, an entitlement grant, or a budget controller.
Its local catalog references need no companion registration in the recorded catalog;
that does not guarantee the same catalog or access on another installation.
It includes the `mistral`, `typesafe`, and `openrouter` routes (the `default` Mistral primary, the
`judge` TypeSafe primary, and its OpenRouter judgment fallbacks, funded separately), so a run in
an isolated API-auth profile needs those logins or edits. No OpenRouter/NVIDIA chat-model floor is inherited.

### Why plan and architect still use Opus 5.5

**[INFERENCE, web evidence checked 2026-10-08]** Keep both roles on Opus 5.5
provisionally in the historical (pre-v36) 17-role table below. Public
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

**Updated 2026-10-20:** the Fable/Opus question for `sage` was resolved provisionally
in favor of Fable 5.1 in the live config (v35), not for `plan`/`architect`, which
stay on Opus 5.5. The supporting blind A/B (3 sage-style prompts, n=3, not 9) was
judge-family biased and the first prompt leaked model identity, so Fable versus Opus
quality is unresolved; the choice rests on low volume (~2 dispatches/week), cost
(estimate: ~2.4x Opus per dispatch), published pushback evidence, and decorrelation.

**Updated 2026-11-03 (v38):** `architect` has been a consultant agent bound to `@slow` since
v36 (no `architect` role); `slow` and `plan` are Opus 5.5 and `sage` is Fable 5.1 in the live config.

### Anthropic-heavy full primary and fallback role map (historical 17-role design, pre-v36)

These were **OMP 18.8.4 local catalog selectors** when recorded (installed is now 18.16.0; not
re-verified there), not public SKU/model identifiers or
proof of third-party entitlement. For example, the public xAI page still advertised
Grok 4.6 while the installed OMP catalog included `grok-4.7`. Do not turn a catalog
label into a public-release or account-access claim. The table below is the 2026-10-08 design, kept
as evidence; the current map is in [../model-roles.yml](../model-roles.yml).

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

Live v38 differs from this historical map: `critical` is Sol with chain Argon → Grok 4.7;
`sage` is Fable 5.1 with model-level chain Opus → Google Opus → Sol → Argon → Grok 4.7;
`default` is `mistral/zai-glm-5-3` with fallbacks Gemini 3.8 Flash → Sonnet 5.5; `smol` carries
a Mistral hop; `vision` includes `mistral-large-4`; Astra appears in no role or chain;
`architect`, `designer`, `good_worker`, and `fast_worker` no longer exist.

The 2026-10-08 static overlay included all 17 roles and all 17 role-keyed chains, plus
`task.agentModelOverrides` of `reviewer: @review`,
`security-reviewer: @security`, `sonic: @fast_worker`, `task: @good_worker`,
`retry.usageAwareFallback: true`, `retry.usageReservePolicy: auto`,
`cycleOrder: [smol, default, slow, architect, sage]`, and `extendedContext: true`.
The live v40 equivalent is `sonic: "@tiny"`, no `task` override,
`cycleOrder: [smol, default, slow, sage]`, and `extendedContext: false`.
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
   store. OMP 18.8.4 help documented `--profile` as isolating auth, sessions,
   settings, and caches (recorded then; installed is now 18.16.0, not re-checked). Configure **only Anthropic API-key auth** for Anthropic in
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
   omp --profile anthropic-api --config ./model-roles.yml
   ```

   `--profile` selects the isolated environment; `--config` changes session routing,
   not Console billing. The role file contains no auth, and it routes `default` to Mistral and
   `judge` to TypeSafe/OpenRouter, so the isolated profile also needs those logins (or edits).
   No persistent `omp config set`, root import, profile/auth creation, or selected-provider probe
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

On 2026-10-08 (historical, pre-v36), two ordinary OMP planning replies on the existing OpenAI Sol route
exercised the instruction: the four-provider Anthropic-heavy future mix, and a
Google Pro trial/no-xAI variant. Both completed without tool calls or Fable requests.
Their full 17-role overlays matched their response tables and passed catalog,
image-input, provider-exclusion, trial-eligibility, and critical-family checks.
The Anthropic-heavy proposal matched the then-unchanged static profile. Read-only OMP
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
[m-pricing]: https://mistral.ai/pricing
[m-edu]: https://help.mistral.ai/en/articles/698530
[m-faq]: https://help.mistral.ai/en/articles/698531
[m-help-455205]: https://help.mistral.ai/en/articles/455205
[m-help-568728]: https://help.mistral.ai/en/articles/568728
[m-subs]: https://docs.mistral.ai/admin/billing-usage/subscriptions
[m-billing]: https://docs.mistral.ai/admin/billing-usage/billing
[m-keys]: https://docs.mistral.ai/vibe/code/cli/api-keys-profiles
[m-api-pricing]: https://docs.mistral.ai/inference/pricing
[m-models]: https://docs.mistral.ai/models
[m-terms]: https://legal.mistral.ai/terms
[m-issue-1362]: https://github.com/mistralai/mistral-vibe/issues/1362
[m-issue-1366]: https://github.com/mistralai/mistral-vibe/issues/1366
