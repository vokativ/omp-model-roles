# Changelog

Version history of `model-roles.yml`, newest first. Rationale and evidence live in `research/`.

## v41

Image generation on the Antigravity subscription (owner decision, 2026-11-12). `generate_image.enabled: true`
(the tool is otherwise off by default), `modelRoles.image: google-antigravity/gemini-3-pro-image` (Nano Banana
Pro), chain `google-antigravity/gemini-3.1-flash-image` (Nano Banana 2) -> `openai-codex/gpt-image-2` (last
resort, ChatGPT Plus hosted). Verified the same day on omp 18.18.8 with one identical prompt through both
Antigravity models (`omp -p --tools generate_image --auto-approve`, model pinned per request): both returned
1264x848 JPEGs via the google-gemini-cli transport. Quota: two image calls moved the shared Gemini buckets
3.7% -> 4.1% weekly and 0.1% -> 1.0% 5h (fresh `omp usage` readings; the orchestrating sessions ran on
Mistral, so the movement is attributable to the images) — image generation draws the AI Pro subscription's
Gemini chat quota, with no separate billing observed; Argon and Claude/GPT shared buckets untouched. The
catalog's $2/$120 and $0.5/$60 per-M figures are cost estimates only. Quality (vision-model rubric, n=1 per
model): Pro adhered better (wings structurally formed of code, all rendered text correctly spelled); Flash
layered code behind solid glowing wings and garbled fine-print code. Revert = remove the `image` role/chain
entries and set `generate_image.enabled: false`.

## v40

Owner-approved items from the 2026-11-11 Fable 5.2 review (`default` stays on `mistral/zai-glm-5-3`; the
proposed swap to GLM-5.3 Flash and the Claude/Codex 300k compaction trial were declined).

- `extendedContext: false` (reverses the 2026-10-02 policy). Measured 2026-11-11 with `omp models find`: off
  shrinks only openai-codex/gpt-6.1-sol 922K -> 500K, gpt-6-luna 872K -> 272K, and anthropic/claude-haiku-5-5
  1M -> 100K. GLM-5.3, Claude Sonnet/Opus/Fable, Gemini 3.8 Flash/Argon, and Mistral Large 4 keep ~1M.
- `compaction.modelThresholds` keeps only `mistral/zai-glm-5-3: "f150000"` (v38.1): GLM's window is unchanged
  by the toggle. Check 2026-11-11: 0 of 44 GLM-5.3 calls since v38.1 exceeded 150k (avg prompt 65k, max 95k,
  $0.026/call) vs 690 of 766 on 2026-11-10 ($0.069/call); no session reached the trigger yet, so the trigger
  itself is still unexercised. No threshold for Gemini 3.8 Flash.
- `commit` chain: `openai-codex/gpt-6-luna` -> Gemini 3.5 Flash-Lite -> `xai-oauth/grok-build` (was Grok Build
  first: 44.8 s vs 5.6 s for Haiku in the commit dry run, 5 edit errors in 11 calls, weekly meter peaks 90%/99%).
- `defaultThinkingLevel: auto` carried in the overlay (docs said auto; omarchy ran `high`).
- `update.auto: false` carried in the overlay: the omp 18.18.6 auto-update dropped `google-antigravity`
  (2 primaries, 21 of 61 chain entries); 18.18.8 lists 13 Antigravity models again (catalog only).
- Not in the overlay (machine-local, holds an account email): `auth.accountPolicies` with `reservePct: 0` for
  `openai-codex`, so OMP's usage preflight stops skipping Sol on contradicted meter readings (PR #104 review fell
  to Grok 4.7). Documented key; behaviour at a real Plus limit is untested.
- Repo: `profiles/anthropic-heavy.yml` (same data minus `compaction`) and the inert `models-overlay.yml`
  removed; version history moved here; `scripts/check-live.sh` and `scripts/omp-spend.sh` added.

## v39

sage -> anthropic/claude-fable-5-2 (owner decision; Fable 5.1 since v35). New model-level chain key
  anthropic/claude-fable-5-2 with the same order (Opus 5.5 -> Antigravity Opus 5.5 -> Sol 6.1 -> Argon ->
  Grok 4.7). The anthropic/claude-fable-5-1 and anthropic/claude-fable-5 chains are retained: both ids stay in
  the catalog, and a revert to 5.1 without its key would fall to the role-level sage chain (no direct-Opus hop).
  Catalog-verified 2026-11-11 via `omp models`: claude-fable-5-2, 1M context / 128K output, low..max
  thinking, image input. Two 2026-11-11 dispatches on anthropic/claude-fable-5-2 (repo review, tools on) were
  accepted via Max 5x OAuth with the delivered id verified from the event stream and no fallback hop.
  No quality claim is made for 5.2 over 5.1; the v35 UNRESOLVED verdict stands.
  Revert = set modelRoles.sage back to anthropic/claude-fable-5-1 (or Opus 5.5).

## v38.1

GLM 5.3 has a 1M window, so the default compaction trigger sat near ~890k tokens. A 2026-11-10 session grew to
483k with no compaction (710 calls re-reading ~296k cached tokens each, plus ~41 prefix-cache misses re-billing
the whole context at 10x): $50.86 of the $150 Vibe Code budget in one day. Compact `mistral/zai-glm-5-3` at
150k. See research/MISTRAL-BUDGET-2026-11.md.

## v38

default -> mistral/zai-glm-5-3 (owner decision); chain google-antigravity/gemini-3.8-flash -> anthropic/claude-sonnet-5-5.
  Evidence: research/DEFAULT-ROLE-EVALUATION.md. Gemini 3.8 Flash lost its speed case: in OMP probes it took 21.6 s
  (low) / 34.6 s (high) on the tool task vs GLM-5.3 7.6 s and Sonnet 5.5 ~9 s; TTFT 2.7-3.3 s per turn vs 0.64 s
  (GLM-5.3); 30-day main sessions on this Mac kept only 15% of turns on the default (10/16 sessions switched within
  6 min, mostly to Opus). GLM-5.3: AA Index 31.7 vs 30.5, Terminal-Bench 4.0 41.9% vs 19.7%, 1M context.
  Owner priority: keep the default off the Claude Max pool, so Sonnet is last. Thinking stays on defaultThinkingLevel
  auto (no :low pin on Gemini). Sol and Grok Build leave the default chain (Plus 7d meter 78%; Grok Build 512K
  context and 5/11 edit errors).
  Costs and limits: owner's admin.mistral.ai page (2026-11-03) shows two allowances, both resetting on the 1st of
  each calendar month: Included Vibe Code usage $150/mo ($5.35 used) and Included API usage $15/mo ($0 used); both
  pay-as-you-go toggles off. OMP's plan key draws the $150 Vibe Code allowance [inference: API read $0 after a day of
  OMP calls]. Repriced at Mistral rates, this Mac's default-only turns (279/30 d) cost ~$4.65/mo (~3%); living on the
  default would be ~$92/mo, which fits on this Mac alone but leaves ~$58 for the Ubuntu server (same config), Mistral
  Vibe CLI, and the five Mistral fallback hops. Exhaustion -> HTTP 402 -> chain walks to Gemini (= the v37 default).
  GLM-5.3 is text-only: pasted images in a default session are not seen (verified); switch model or ask for
  `read <image>?q=...`, which uses the vision role. Exception to v37's "no Mistral primaries" rule, by owner choice.

## v37.2

vision chain gains mistral/mistral-large-4 after Sol 6.1, before Grok 4.7 (owner decision). Large 4 had the
  cleanest OMP tool run and read the vision probe image correctly (1M ctx, image input); it is a public-preview
  model with modest independent benchmarks (AA Index 26.0), so it sits late in the chain only. Draws the Mistral
  EDU monthly allowance; still one mistral entry per chain.

## v37.1

judge -> typesafe/jev-1.14.0 (direct; TypeSafe API key now stored via /login typesafe);
  chain openrouter/typesafe/jev-1.14 -> openrouter/typesafe/jev-1.13 -> openrouter/liquid/d1.1. Same model and
  price ($0.042/M input) as v37; OpenRouter becomes the cross-route fallback. Direct jev-latest/jev-preview are
  omitted: same provider and endpoint as the primary (TypeSafe docs: both currently alias jev-1.14.0).

## v37

judge regression fix and bounded Mistral (EDU plan) adoption. Evidence: research/MISTRAL-EVALUATION.md.
  - judge -> openrouter/typesafe/jev-1.14; chain openrouter/typesafe/jev-1.13 -> openrouter/liquid/d1.1.
    v36's typesafe/jev-1.14.0 primary had no credential (no typesafe row ever existed in agent.db; the
    "stored TypeSafe credentials" claim was wrong), typesafe/jev-preview is unseeded (the logged
    "does not resolve to a compatible model" warning), and the chain had no OpenRouter route. Every
    judgment since 2026-10-28 fell through to prompted gemini-3.5-flash-lite (0/1 probabilities), which
    disabled find (find.enabled: auto), auto-prewalk, and smart autoGraph. Natives only on purpose: after a
    credentialed native judge fails, OMP never tries a prompted chat tail. Billed to OpenRouter credit
    ($0.042/M input, output free; 164 judgments cost $0.012 in Sep-Oct).
  - mistral login = Mistral EDU (student Pro, $5.99/mo list) plan key: bills the plan's monthly usage
    allowance shared with Mistral Vibe CLI (v37 inferred ~$15/mo from the pricing card; corrected in v38: $150/mo
    Vibe Code allowance, reset on the 1st of each calendar month; no omp usage meter; exhaustion = HTTP 402).
    Unmetered pool -> fallback hops only (v37), one mistral entry per chain:
      smol: mistral/zai-glm-5-3-flash ahead of Luna (relieves the Plus 7d meter; GLM-5.3 Flash AA 27.8 vs
            Luna 21.4, vision, 0 edit-tool errors in OMP probes, $0.15/$0.5).
      tiny: mistral/zai-glm-5-3-flash ahead of Luna (same reason).
      task: mistral/zai-glm-5-3 after Gemini 3.8 Flash, before Grok Build (Terminal-Bench 4.0 41.9%
            vs 19.7% for 3.8 Flash; 0 edit-tool errors).
      review: mistral/zai-glm-5-3 before Antigravity Opus, so the last independent (non-Claude) reviewer
            is not the same-family hop.
  - Not adopted: Mistral Large 4 (adopted late in vision by v37.2) / DeepSeek V4.1 Flash (public preview; DeepSeek emits thinking-only turns),
    Medium 3.5 (deprecated 2026-10-31, Terminal-Bench 4.0 0%, malformed edits), Small 4 / Ministral (weak,
    ministral-14b failed 47/47 edits), and every alias id (no catalog metadata: no thinking, null context).
    No Mistral model in critical, slow/plan/security, sage, vision, judge, or as any primary
    (v37 as written; superseded: vision gains Large 4 in v37.2, default primary is GLM-5.3 from v38).

## v36

OMP 18.13.2 harness alignment, missing roles integration, and custom agent hardening.
  - critical: added structured: true to agents/critical.md frontmatter, repairing the silent contract
    break introduced in OMP 18.10.2+ where subagents spawned by task defaulted to unstructured plain
    text (missing the yield tool and schema validation). Also added read-summarize: false to critical.
  - widget: added built-in chat role (introduced in OMP 18.12.3) mapped to anthropic/claude-haiku-5-5:low.
    Defuses the silent quota trap where unassigned widget fell back to smol (Sonnet 5.5) on every
    background job status-line render. Fallback chain: gemini-3.5-flash-lite -> grok-composer-2.5-fast.
  - judge: added model-kind role mapped to typesafe/jev-1.14.0 using stored TypeSafe credentials in
    agent.db. Activates natural-language search (find) in architect and other agents under OMP's
    find.enabled: auto policy, and enables native System One judgments for typed eval judgments.
    Fallback chain: typesafe/jev-latest -> typesafe/jev-preview -> gemini-3.5-flash-lite.
  - Consolidation: deleted dead-weight designer role/chain (OMP has no designer agent/subsystem;
    invoke xai-oauth/grok-4.7 directly via /model if needed).
  - Consolidation: collapsed architect role into @slow (agents/architect.md now sets model: "@slow");
    removed redundant architect from modelRoles, fallbackChains, and cycleOrder ([smol, default, slow, sage]),
    eliminating the duplicate Opus stop in Ctrl+P cycling while keeping the consultant agent intact.
  - Retained critical as a dedicated role & agent: verified as the sole cross-provider independent
    adversarial gate (Sol 6.1 vs Anthropic producers) with structured GO/NO-GO enforcement.
  - Consolidation: deleted fast_worker and good_worker roles/chains. Bundled task already uses @task
    (same Sonnet 5.5 primary and chain as good_worker), so its override is gone. Bundled sonic defaults
    to @smol (Sonnet 5.5); one override, sonic: "@tiny", keeps Vibe/fast workers on Haiku 5.5:low with
    tiny's Luna -> Flash-Lite -> Composer chain. A bare model selector is avoided on purpose: a
    role-less pin falls back through the default chain (Sonnet first), not a cheaper tier.
  - review -> openai-codex/gpt-6.1-sol (bundled reviewer = PR review). Producers are mostly Claude, so
    the reviewer is cross-family; chain Argon -> Grok 4.7 -> Antigravity Opus 5.5 (same family, last).
    PR review moves off critical, which is narrowed to irreversible/operational go/no-go decisions.

## v35

sage -> anthropic/claude-fable-5-1 (provisional, reversible); Astra stays out of every role/chain.
  - sage failover: Fable -> direct Opus 5.5 -> Antigravity Opus 5.5 -> Sol 6.1 -> Argon -> Grok 4.7.
    The model-level anthropic/claude-fable-5-1 / -5 chains OWN this order (OMP checks exact model
    keys before role keys); the role-level sage chain only applies if sage reverts to Opus.
    Antigravity Opus (idle Claude/GPT pool) now precedes Sol so sage does not drain the Plus
    5h window that critical swarms exhaust; Argon kept late (weekly meter exhausted until ~10-24; reading as of 2026-10-20, ~37-40% on 2026-11-03, order unchanged).
  - Evidence: 2026-10-20 probes accepted Fable 5.1 via Max OAuth (no credits_required). Blind A/B of
    3 sage prompts was family-biased (Sonnet judges favored Claude, Sol judge favored OpenAI; Grok
    neutral: Fable 8.43 > Opus 8.13 > Astra 7.85 > Sol 7.74) and P1 leaked model identity, so
    Fable vs Opus is UNRESOLVED on quality. Chosen for low cost (~2 dispatches/week, est. +1.6
    weekly-pool points vs Opus), best published pushback evidence, and decorrelation from the
    Opus-based plan/architect/slow. Revert = set sage back to anthropic/claude-opus-5-5.
  - Astra: no role, no chain. Same Plus 5h/7d meter as Sol (no fallback resilience), ~5x list
    price per token, AA Intelligence Index 53 vs Sol 6.1's 52, Arena creative #38 vs Opus 5.5 #1.
    Use explicitly via --model openai-codex/gpt-6-astra only when stuck and Plus has headroom.
  - Fable runs reasoning that Opus cannot read: a mid-session Fable -> Opus failover drops that
    reasoning (fresh dispatches unaffected). Fable draws from the shared Max 7d pool (<=50% sub-cap).

## v34

integrated Google Gemini 4 Argon across critical gate and reasoning fallback tiers.
  - critical fallback tier 1 upgraded: replaced lightweight google-antigravity/gemini-3.8-flash
    with google-antigravity/gemini-4-argon (1M context, 66K output, high thinking).
    Preserves strict cross-provider independent provenance against both Anthropic producers
    and OpenAI Sol primary/fallbacks; operates safely within weekly WTU meter.
  - slow, plan, architect, sage, review, security fallbacks: inserted google-antigravity/gemini-4-argon
    as tier 2 reasoning fallback behind openai-codex/gpt-6.1-sol and ahead of Antigravity Claude Opus.
    Provides true multi-provider frontier depth (Anthropic -> OpenAI -> Google -> xAI) on failover.
  - Verified live Google AI Pro quota: gemini-argon-wtu-weekly meter active (13.2% used / 86.8% left);
    native 66K max-out requires no models-overlay.yml adjustment.

## v33

Anthropic-heavy allocation aligned with Claude Max 5x, ChatGPT Plus, Google AI Pro, and X Premium.
  - task, good_worker, smol, review, security -> anthropic/claude-sonnet-5-5 leveraging 5x Max capacity.
  - slow, plan, architect, sage -> anthropic/claude-opus-5-5 for deep reasoning and design reviews.
  - critical -> openai-codex/gpt-6.1-sol for strict cross-provider independent provenance against
    Anthropic producers; fallbacks strictly non-Anthropic (Gemini 3.8 Flash, Grok 4.7).
  - designer fallback promoted to anthropic/claude-opus-5-5 (superior visual/aesthetic judgment;
    Fable excluded to protect weekly allowance).
  - Aligned lightweight fallbacks: updated tiny, fast_worker, and commit fallbacks to Google's
    latest google-antigravity/gemini-3.5-flash-lite, preserving full 3.8 Flash quota.
  - Excluded disabled Google Gemini 4 Argon (unsupported under Google AI Pro in Antigravity)
    and external API tiers (OpenRouter, NVIDIA) to fit within the 4 paid subscription mix.

## v32

bounded Haiku 5.5 adoption on the direct Claude Pro subscription.
  - commit primary -> anthropic/claude-haiku-5-5:low; Grok Build retained as first fallback.
  - Native OMP 18.8.3 catalog, OAuth tool replay, and actual commit dry-run verified.
  - Keep high-volume and depth roles/chains unchanged to protect shared Pro headroom.
  - No Antigravity Haiku route or custom model registration; see README for evidence.

## v31

migrated Antigravity Claude fallbacks to the main paid Google AI Pro account.
  - Opus 4.6 -> Opus 5.5 and Sonnet 4.6 -> Sonnet 5.5 in all nine fallback chains;
    advisor primary -> Antigravity Sonnet 5.5. Existing chain order is unchanged.
  - Both 5.5 selectors verified through OMP at thinking: high, with fallback disabled.
  - Four free accounts still expose Claude 4.6, not 5.5; they are not extra 5.5 capacity.
    Google scheduled Claude 4.6 removal for 2026-11-02 (date now past; not re-verified). See README's account-tier notes.
  - Direct and Antigravity Opus 5.5 are not independent model votes.

## v30

updated smol fallback chain for prewalk and sub-default cost profile.
  - Upgraded tier 1 fallback from legacy gemini-3.1-flash-lite to gemini-3.5-flash-lite
    on google-antigravity (1M context, 66K output, verified live tool execution).
  - Inserted xai-oauth/grok-composer-2.5-fast as tier 2 fallback ahead of Nemotron,
    giving smol an independent, fast xAI tier (200K context, 0% used weekly pool).
  - Nemotron-3-Super retained as tier 3 $0 unmetered floor.

## v29

architect -> gpt-6.1-sol for frequent technical reviews as well as architecture.
  - Removed the architect's mandatory JSON schema; retained read-only evidence-based
    review/design guidance. critical keeps its structured gate; sage keeps its remit.
  - Removed the architect fallback back to its new primary. Cross-provider fallbacks
    remain; Astra stays available explicitly and in sage's existing fallback chain.
  - Cross-machine session review supports extended context for this workload.
    Owner chose one configuration everywhere: extendedContext: true.
    Prewalk remains opt-in; see README for Sol -> Luna implementation workflow.
  - No claim of measured quality parity or subscription-quota savings versus Astra.

## v28

upgraded all `openai-codex/gpt-6-sol` references to `openai-codex/gpt-6.1-sol`
across role assignments (slow, plan, task, review, security, good_worker -> gpt-6.1-sol)
and fallback chains (default, designer, vision, advisor, architect, critical, sage, fable).
  - Rationale: GPT 6.1 Sol expands context window from 872K to 922K (with 128K max output)
    and cuts prompt cache read costs in half ($0.10/M vs $0.20/M) at identical base pricing
    ($2/M input, $10/M output). Retains the full low..max thinking ladder and image input.
  - Quota: Live `omp usage` (2026-10-01) shows openai-codex at 27% used (73% headroom).

## v27

upgraded all `xai-oauth/grok-4.6` references to `xai-oauth/grok-4.7` across role
assignments (designer -> grok-4.7) and fallback chains (slow, plan, vision, architect,
review, security, critical, sage, fable). Kept `xai-oauth/grok-build` for `commit` and
`fast_worker` (sonic) and `xai-oauth/grok-composer-2.5-fast` for `tiny`.
  - Rationale: Grok 4.7 (released 2026-09-21) is SpaceXAI's upgraded coding and
    knowledge work model at identical pricing ($2/M input, $6/M output, $0.50/M cache).
    Features marked improvements across coding and reasoning benchmarks (DeepSWE v1.1
    71.0% vs 65.2%, CursorBench 4.0 46.3% vs 40.4%, Terminal-Bench 4.0 37.6% vs 20.3%)
    and stronger document/presentation design for the `designer` role.
  - Quota: Operates on existing X Premium SuperGrok weekly credits pool (currently 3% used /
    97% remaining). Retaining `grok-build` ($1.25/$2.50) preserves fast, low-cost commit and
    sonic tasks under the shared weekly allowance without flagship reasoning overhead.

## v26

upgraded all `openai-codex/gpt-5.6-terra` references to `openai-codex/gpt-6-sol`
across role assignments (task, good_worker -> gpt-6-sol) and fallback chains (default,
designer, vision, advisor -> gpt-6-sol). Also upgraded all `anthropic/claude-opus-5`
references to `anthropic/claude-opus-5-5` across role assignments (critical, sage ->
claude-opus-5-5) and fallback chains (slow, plan, architect, review, security, fable).
  - Rationale: Per Simon Willison's 2026-09-22 pricing analysis:
    1) GPT-6 Sol is $2/M in, $0.20/M cached in, and $10/M out (17% cheaper than Terra's
       $12/M out, with identical input/cache rates and no >272K surcharge). Any remaining
       reason to use Terra evaporated. Sol brings 872K context window, 128K max out, and
       low..max thinking ladder.
    2) Claude Opus 5.5 cut input/output pricing 20% ($4/$20 vs $5/$25) and prompt cache
       reads 60% ($0.20 vs $0.50). Communicates clearly with Fable 5.1-tier intelligence
       and high token efficiency. All agent definitions (critical, sage, architect) retain
       `thinking: high`, avoiding the Opus 5.5 "max" over-thinking SVG edge case.
  - Quota & Independence: Live `omp usage` (2026-09-23) shows openai-codex at 26% (74% left)
    and anthropic at 10% (5h) / 2% (7d). `critical` gate remains on Anthropic (claude-opus-5-5),
    preserving INDEPENDENT producer/reviewer provenance against Sol-produced work.

## v25

upgraded `openai-codex/gpt-5.6-luna` to `gpt-6-luna` and `gpt-5.6-sol` to `gpt-6-sol`
across all role assignments (smol -> gpt-6-luna; slow, plan, review, security -> gpt-6-sol)
and fallback chains (commit -> gpt-6-luna; architect, critical, sage, fable -> gpt-6-sol).
OpenAI released GPT-6 Luna and Sol on Codex (272K ctx, 128K out, low-max thinking). Terra
remains on `openai-codex/gpt-5.6-terra` as no GPT-6 Terra model exists in the catalog.

## v24

cut `tiny`/`fast_worker` over off retired openai-codex/gpt-5.3-codex-spark (OpenAI
retired Spark the week of 2026-09-13; confirmed 0 catalog hits via `omp models find
gpt-5.3-codex-spark` and multiple community reports of the model vanishing from Codex CLI's
selector while its dedicated quota meter stayed visible). Promoted each role's existing
tier-1 fallback to primary since both already run on healthy xai-oauth capacity (9% used,
91% left): tiny -> xai-oauth/grok-composer-2.5-fast, fast_worker -> xai-oauth/grok-build.
Trimmed the now-redundant leading fallback entry from both chains.
  - Investigation: live `omp usage` on 2026-09-18 showed openai-codex 7-day pool at 93% used
    (0.07x quota left, inside the 10% usageReservePct reserve margin) — NOT caused by Spark
    (its lifetime usage across all sessions was ~423K tokens, a rounding error against
    gpt-5.6-terra's 46.5M and gpt-5.6-luna's 15.7M). The real driver is `task`/`smol` role
    volume from heavy subagent fan-out; Spark retirement is a separate, real defect that was
    leaving `tiny`/`fast_worker` pointed at a model no longer in the catalog.
  - Also live-corrected the stale Anthropic/OpenAI capacity read that produced the v22
    "openai-codex abundant" narrative: Anthropic is now the pool with headroom (4%/14% used,
    0.86-0.96x left) and openai-codex is the constrained one (93% used, 0.07x left). See
    README.md's capacity table for the current reading.

## v23

replaced dead nvidia/minimaxai/minimax-m3 (HTTP 410 EOL 2026-09-09) with
nvidia/nvidia/nemotron-3-super-120b-a12b across all 8 fallback chains (default, smol,
task, commit, advisor, tiny, fast_worker, good_worker).
  - EOL discovery: scanned live NVIDIA NIM catalog (82 active models, 149 EOL/404);
    minimax-m3 reached EOL on 2026-09-09T09:00:00Z.
  - Replacement: nvidia/nvidia/nemotron-3-super-120b-a12b (120B MoE with 12B active,
    262K context, 262K max output tokens, minimal-xhigh thinking ladder, native tool calling).
  - Eliminates the server-side 16K token cap defect of MiniMax M3 (now 262K native out).
  - Sub-second TTFT (~0.5s) on NIM, robust unmetered $0 floor.

## v22

made Astra the architect primary; kept critical as an independent Opus 5 gate and Sage's
Opus 5 primary for diversity; removed the standalone Astra role; reordered architect failover
cross-provider first: Antigravity Opus, direct Opus, Sol, Antigravity Sonnet, Grok, then GLM.

## v21

replaced google-antigravity/gemini-3.7-flash with gemini-3.8-flash and
openrouter/google/gemini-3.7-flash with gemini-3.8-flash across all roles and fallbacks
(default, vision, task, designer, good_worker).

## v20

cutover `tiny` and `fast_worker` (sonic) to openai-codex/gpt-5.3-codex-spark; elevated
gpt-6-astra into `sage` (Thinking Partner) fallback chain.
  - Primary: openai-codex/gpt-5.3-codex-spark for tiny & fast_worker. Sustained decode: ~644 tok/s
    (12x faster than Luna) with 2.1s TTFT; routes volume to ChatGPT Pro's 0%-used dedicated Spark pool.
  - Sage fallback: inserted openai-codex/gpt-6-astra ahead of Sol. Preserves Opus 5 primary
    (protecting provider diversity) and Antigravity Opus 4.6 Tier 1 ($0 Claude continuity),
    elevating Astra's incisive dialectical reframing for Tier 2 OpenAI fallback.

## v19

replaced decommissioned `fable` with `sage` (Thinking Partner).
  - Primary: anthropic/claude-opus-5 (prose taste, conceptual reframing, and lateral ideation).
  - Fallback chain: google-antigravity/claude-opus-4-6 (0% proxy continuity) -> openai-codex/gpt-5.6-sol
    (abundant ChatGPT Pro) -> google-antigravity/claude-sonnet-4-6 -> xai-oauth/grok-4.6 -> openrouter/z-ai/glm-5.3-flash.
  - Model-level fallback chains for anthropic/claude-fable-5-1 and claude-fable-5 retained to defuse
    the account-level 429 credits_required hazard on explicit CLI invocations.
  - cycleOrder explicitly registered: [smol, default, slow, architect, sage].

## v18

upgraded depth fallback tier across all 6 deep reasoning roles (slow, plan, architect,
review, security, critical) by inserting cost-neutral google-antigravity/claude-opus-4-6 before
claude-sonnet-4-6. Leverages Antigravity's 0%-utilized Anthropic proxy lane for genuine Opus-tier
depth on failover without draining the scarce direct-Anthropic Pro account. Evaluated Claude
Fable 5 / 5.1; established opt-in escalation pattern for high-stakes architecture.

## v17

replaced dead nvidia/deepseek-ai/deepseek-v4-flash (HTTP 410 EOL 2026-08-07) and upgraded
fallback resilience across all chains.
  - default primary retained on google-antigravity/gemini-3.8-flash (user preferred every-turn model),
    falling back to gpt-5.6-terra -> openrouter/z-ai/glm-5.3-flash -> nvidia/minimaxai/minimax-m3.
  - openrouter/z-ai/glm-5.3-flash added as the subscription-independent capability tier in 8 chains
    (#1 on Tau2-Bench Airline/Agentic at 58.2, 1.31M context, 131K output, multimodal, $0.075/$0.25).
  - nvidia/minimaxai/minimax-m3 added as the unmetered $0 floor in 8 chains (1M context, 16K max-out).
    Deliberately excluded from depth roles (slow/plan/architect/review/security/critical) and vision.
  - vision primary remains google-antigravity/gemini-3.8-flash, with openrouter/google/gemini-3.8-flash
    (2026-08-22 A/B winner) as first fallback, followed by gpt-5.6-terra and grok-4.6.
  - critical first fallback switched to openrouter/z-ai/glm-5.3-flash, closing the v14 defect
    where Sol collided with slow/plan/review/security producers.
  - demoted NVIDIA to last fallback in tiny and fast_worker (measured queue on NIM).
  - dropped claude-sonnet-5 from default's chain (Anthropic 5h window reserved for Opus).

## v16

expanded the depth tier from two models/meters to three. Added the cost-neutral
google-antigravity/claude-sonnet-4-6 lane to slow/plan/review/security/architect/critical
after each chain's existing Sol/Opus flagship pair and before Grok. Preserves all A/B-backed
primaries and first fallbacks, keeps Claude-class depth through a separately-metered free
lane, and avoids dropping all six roles directly onto the smallest/slowest X pool.

## v15

kept `critical` on Opus 5 after wiring/history review showed it is an explicit final
implementation/operational gate, not an automatic architect reviewer. Opus is independent
from likely producers (Gemini default, Terra task, Sol depth/review, Grok designer); moving
it to Sol would weaken four common pairings to fix one architect pairing. Hardened
agents/critical.md instead: required producer/reviewer provenance + independence enum, and
forbid unconditional GO for SAME-MODEL/UNKNOWN. Live same-model test (architect Opus ->
critical Opus) returned SAME-MODEL + GO-WITH-CONDITIONS as required. Also corrected stale
docs: current cycleOrder contains architect but not critical; no automatic trigger exists.

## v14

hardened + TESTED the v13 agent definitions (4 live dispatches, both agents resolved to
anthropic/claude-opus-5). Added `thinking: high` to both and an `output:` JSON-schema to
critical (machine-checkable GO/NO-GO verdict). Fixed repo-vs-installed drift: v13 shipped
agents/*.md WITHOUT the hardening, so following the README would have downgraded a live
install. NOTE: the agents' `tools:` allowlist is NOT a sandbox - MCP tools are injected
regardless of it. Two open defects found by the agents auditing their own commit (critical
and architect share a model; critical's first fallback collides with review/security/slow/
plan) are documented but NOT fixed - they need a quota decision.
See research/ARCHITECT-CRITICAL-AGENTS.md.

## v13

architect/critical were modelRoles-only through v12 - no bundled agent name existed to
bind them to via task.agentModelOverrides, so they were unreachable except by manually
switching the whole session (/model @architect, Ctrl+P). Added agents/architect.md and
agents/critical.md (role-backed custom agent definitions) so both are now real task(agent=
"architect"|"critical", ...) dispatch targets. See research/ARCHITECT-CRITICAL-AGENTS.md.
