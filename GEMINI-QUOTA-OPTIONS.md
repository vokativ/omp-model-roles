# Gemini/Antigravity quota — burnout options, and how to monitor usage over time

Written 2026-08-15 in response to: "a lot of stuff is on Google Gemini now, should I upgrade a
subscription or use an API key, and how do we check back in a month across multiple machines to
see if this allocation actually makes sense."

## TL;DR

- **Don't subscribe to anything yet.** Your current fallback chain already survives a Gemini
  burnout for free — it drops to `anthropic/claude-sonnet-5`, which sits at ~0-4% used.
- **If** you want overflow to land on *more Gemini* instead of switching model character mid-
  session, OMP's own maintainers document a specific pattern for exactly this: a
  `google-antigravity/*` provider-wildcard fallback to `google/*` (Gemini API, pay-as-you-go)
  then `google-vertex/*` (Vertex AI, GCP billing) — same model id, different (billed) pool. That
  only costs money when it actually triggers.
- **To check whether this was the right call, don't guess — `omp usage --history --days 30` is a
  local command that already answers it**, and the underlying quota numbers are account-level, so
  they reflect combined usage from every machine automatically. Only *per-machine attribution*
  needs extra setup (the auth-broker), covered below.

## Part 1 — What's actually happening, and the burnout options

### Current snapshot

Your morning's cross-repo research pushed heavy volume through `default`, which — since this
morning's `model-roles.yml` commit — primaries on `google-antigravity/gemini-3.7-flash`. Live
snapshot at time of writing:

| Antigravity meter | Latest | 30d peak | Feeds |
|---|---|---|---|
| Usage (Google), daily | 55.0% | 55.0% | `gemini-3.7-flash` (`default`, `vision`, `designer`) |
| Usage (Anthropic), daily | 100.0% | 100.0% | Antigravity-proxied Claude — **already hit the wall this window** |
| Usage (Anthropic), weekly | 70.5% | 70.5% | same proxy, weekly window |
| Usage (OpenAI), daily | 100.0% | 100.0% | Antigravity-proxied OpenAI — **also hit the wall** |
| Usage (OpenAI), weekly | 70.5% | 70.5% | same proxy, weekly window |

Pulled via `omp usage --history --days 30`. The two Antigravity-proxy *daily* meters (Anthropic
and OpenAI) have already peaked at 100% at least once in this window — direct evidence that
Antigravity's daily lanes do run dry under load, not just a hypothetical. The Google-native daily
lane (the one `gemini-3.7-flash` actually draws on) hasn't hit that yet, but `default`, `vision`,
and `designer` all now primary on that exact meter — more concentrated load than before this
morning's change.

**What happens today if the Google lane exhausts:** `retry.usageAwareFallback: true` +
`retry.usageReservePolicy: auto` proactively switches `default` to
`retry.fallbackChains.default[0]` = `anthropic/claude-sonnet-5` *before* a hard 429 — no
interruption, just a model-character change for the rest of that window, then
`fallbackRevertPolicy: cooldown-expiry` switches back once Gemini's window clears.

### How OMP's own authors handle this

`omp://settings.md`'s canonical `retry.fallbackChains` example (the maintainers' own documented
pattern, not third-party advice) includes this exact case:

```yaml
retry:
  fallbackChains:
    # A `provider/*` KEY covers every model of a provider — current or
    # future. A `provider/*` ENTRY keeps the failing model's id and swaps
    # the provider: google-antigravity/x -> google/x -> google-vertex/x.
    google-antigravity/*:
      - google/*
      - google-vertex/*
```

Two things worth knowing before touching this:

1. **It's the documented answer to "Antigravity ran dry."** It keeps `gemini-3.7-flash` (same
   weights, same character) and swaps which *pool* pays: first pay-as-you-go Gemini API
   (`google/*`, needs `GEMINI_API_KEY`), then Vertex AI (`google-vertex/*`, needs a GCP project).
2. **Provider wildcards outrank role chains.** OMP picks a chain by specificity: exact
   `provider/model-id` → `provider/*` wildcard → the active role's chain → `default`. A
   `google-antigravity/*` entry fires *before* `modelRoles.default`'s chain, for every antigravity
   model in every role.

**Not applied yet** — you have no `GEMINI_API_KEY` or Vertex credentials configured
(`omp models google` / `omp models google-vertex` both come back empty), and a bare wildcard
would shadow the working Sonnet-5 safety net with two unauthenticated, unselectable entries. If
you want this, it needs to chain into the existing fallback, and it needs real credentials —
covered in the ready-to-paste snippet at the end.

### Options, compared

| | Do nothing (Recommended) | OpenRouter (50% Promo) | Gemini API (Google AI Studio) | Google AI Pro ($19.99/mo) |
|---|---|---|---|---|
| Cost | **$0** extra | **$0.375/1M in, $1.875/1M out** (pay-as-you-go) | $0.75/1M in, $3.75/1M out | $19.99/mo flat |
| What it buys | Immediate Sonnet 5 / Terra fallback (already paid, 90%+ idle) | Same-model Gemini 3.7 Flash overflow at half direct Google cost | Direct Google Gemini overflow tier | 4x bigger *free* Antigravity quota + $10/mo Cloud credit |
| Setup | None | Fund OpenRouter credits → `openrouter/google/gemini-3.7-flash` | `ai.google.dev` → GCP billing setup | Google One upgrade |
| Billing risk | Zero | Zero (isolated prepaid balance) | Can collide with existing app GCP billing accounts | Fixed recurring subscription |
| Right for you if | **Current state**: Antigravity is healthy, flat subscriptions absorb overflow | Antigravity runs dry daily AND you want same-weights overflow with zero billing hassle | Strict requirement for first-party Google endpoint | Antigravity IDE UI itself is needed |

### Price comparison: Google AI Studio vs OpenRouter

Live rates for `gemini-3.7-flash` (checked 2026-08-16):
- **Google AI Studio Direct**: $0.75 / 1M input, $3.75 / 1M output (standard context ≤128k).
- **OpenRouter (Discounted)**: **$0.375 / 1M input, $1.875 / 1M output** (50% cheaper, 1M context).

### Updated Recommendation: Do Not Buy API Keys Right Now

1. **Antigravity daily Google lane is at ~4% capacity**: You are far from exhausting the free quota under your current solo/exploratory volume.
2. **Your paid pools have 90%+ idle headroom**: If Antigravity ever exhausts, your fallback chain immediately routes to `anthropic/claude-sonnet-5` (4% 7d used) and `openai-codex/gpt-5.6-terra` (8% 7d used). These are already paid for by your monthly subscriptions — paying per token to OpenRouter or Google would be paying twice for overflow you already have for free.
3. **If you ever need same-model overflow in the future**: Prefer OpenRouter (`openrouter/google/gemini-3.7-flash`). It is 50% cheaper than direct Google AI Studio and avoids touching or complicating existing Google Cloud billing accounts tied to your production apps.

### When to review
Re-evaluate during the monthly check-in (`omp usage --history --days 30`). Only consider adding OpenRouter if:
- Antigravity's daily Google meter hits 100% regularly, **and**
- You notice and dislike the model character switch when Sonnet 5 takes over.

## Part 2 — Monitoring usage over time, and across multiple machines

### On one machine: this already exists, no setup needed

```bash
omp usage --history --days 30          # sparkline trend, human-readable
omp usage --history --days 30 --json   # same data, machine-readable
```

`omp` records an **hourly snapshot** of every authenticated account's usage into the local
`agent.db` (SQLite) whenever it's running. `--days` accepts any window (tested up to 30 here);
each meter reports `latest`, `peak`, and snapshot count for the window. This is exactly the "come
back in a month and see how it actually went" tool — run it again in September and compare peaks
per meter instead of relying on memory or this morning's spike.

What to actually watch for, next check-in:
- **A meter's 30-day *peak* pinned at 100% repeatedly** (like the two Antigravity-proxy daily
  meters already are) → that lane is genuinely saturated under real workload, not just today's
  research burst — worth moving that role off it or adding the paid-API fallback.
- **A meter that never exceeds ~20-30% even on your heaviest days** → over-provisioned; safe to
  point *more* volume at it (e.g., shift another role onto it) rather than leaving headroom idle.
- **Anthropic's peak staying low** (currently 0-4%) confirms the "reserve it as fallback only"
  strategy from this morning's swap is working as intended — it's absorbing overflow, not
  routine traffic.

### Across multiple machines: the quota numbers are already combined — attribution is the only gap

Important distinction: `omp usage`'s percentages are **provider/account-level**, not per-install.
Anthropic, Google, OpenAI, and xAI all track quota against the OAuth account itself — so if you
run `omp` from a laptop in the morning and a desktop in the evening under the same logins, both
machines already see the *same combined* 5h/daily/weekly numbers, automatically, with zero
cross-machine setup. You don't need anything special to get the aggregate picture — `omp usage
--history` on *either* machine already reflects both machines' combined draw on that account.

What you *don't* get for free: **which machine burned how much**. Each machine's hourly-snapshot
log only has entries for the hours that machine's `omp` was actually running, and there's no
built-in "laptop used 30%, desktop used 70%" breakdown from the plain CLI.

If you actually want that per-machine split (useful once you're routing similar workloads from
both machines and want to know if one is disproportionately hot), OMP ships exactly this via the
**auth-broker** (`docs/auth-broker-gateway.md`):

1. Pick one always-on host (could be either machine, a home NAS, or a small VPS reachable over
   Tailscale/Wireguard) and run:
   ```bash
   omp auth-broker serve --bind=0.0.0.0:8765
   omp auth-broker token          # prints the bearer token once, save it
   ```
2. On every machine (including the broker host itself, if you want it to route through its own
   broker), point `omp` at the broker instead of local credentials:
   ```bash
   export OMP_AUTH_BROKER_URL=https://broker-host:8765
   export OMP_AUTH_BROKER_TOKEN=<token from step 1>
   ```
   Log in once through the broker (`omp auth-broker login anthropic`, etc.) — every machine then
   shares the same credential set instead of each holding its own OAuth session.
3. Query per-machine attribution over HTTP (no dedicated CLI subcommand exists for these two
   endpoints yet, so use `curl` with the bearer token):
   ```bash
   # Full persisted history, broker-side (doesn't depend on any one machine being on)
   curl -H "Authorization: Bearer $OMP_AUTH_BROKER_TOKEN" \
     "https://broker-host:8765/v1/usage/history?sinceMs=$(( $(date +%s%3N) - 30*24*3600*1000 ))"

   # Per-machine ("client") breakdown for the same window
   curl -H "Authorization: Bearer $OMP_AUTH_BROKER_TOKEN" \
     "https://broker-host:8765/v1/usage/clients?sinceMs=$(( $(date +%s%3N) - 30*24*3600*1000 ))"
   ```

This is a real infrastructure change (a persistent service, a reachable host, transport security
you own via Tailscale/Wireguard/TLS per the broker's own docs) — worth it only if per-machine
attribution actually matters to you. If all you want is "how much of my Claude Pro window is
left, combined across both machines," `omp usage` already answers that today with no broker.

### Suggested check-in

In ~4-6 weeks (matches this repo's own staleness window in `RESEARCH-PLAYBOOK.md`):

```bash
omp usage --history --days 30 --json > usage-$(date +%Y-%m).json
```

Run that on each machine you use, compare peaks per meter against the thresholds above, and
re-open `RESEARCH-PLAYBOOK.md`'s methodology if any meter's peak has shifted meaningfully — that's
also the trigger for bumping `model-roles.yml`'s snapshot version and re-deriving the allocation,
not just this Gemini question.

## Sources

- `omp://settings.md` — canonical `retry.fallbackChains` example incl. `google-antigravity/*` →
  `[google/*, google-vertex/*]`, and the chain-selection specificity order.
- `omp://providers.md` — `google` (`GEMINI_API_KEY`) vs `google-vertex` (`GOOGLE_CLOUD_API_KEY` /
  ADC) vs `google-antigravity` (OAuth) as three distinct provider IDs.
- `omp://non-compaction-retry-policy.md` — `usageAwareFallback`/`usageReservePolicy`/
  `fallbackRevertPolicy` mechanics.
- `omp://auth-broker-gateway.md` — broker/gateway architecture, `/v1/usage/history` and
  `/v1/usage/clients` endpoints, credential sharing across machines.
- `omp usage --history --days 30` / `omp usage` (this machine, fetched 2026-08-15) — live and
  30-day snapshot data quoted above.
- Gemini API pricing: [ai.google.dev/gemini-api/docs/pricing](https://ai.google.dev/gemini-api/docs/pricing).
- Google AI subscription tiers: [blog.google — Google One AI subscriptions](https://blog.google/products-and-platforms/products/google-one/google-ai-subscriptions/),
  [antigravity.google/pricing](https://antigravity.google/pricing).
