# Mistral Vibe Code budget: Nov 2026 usage audit (2026-11-11)

Dashboard on Nov 11: $140.75 of $150 used, resets in 20 days. GLM 5.3 became the `default` on Nov 3.
Data: omp session logs on Mac, Omarchy, Lubuntu (omp-recorded costs).

## Findings
- omp-recorded Mistral spend $108.69 (GLM-5-3 $103.66): Omarchy $100.66, Lubuntu $2.56, Mac $0.44. The $32 gap to the dashboard is **unresolved**: omp's GLM prices match Mistral's list ($1.40 in / $4.40 out / $0.14 cached per M); nothing is missing from the logs. Only a cached rate of about 1.6x list reproduces it. Check console.mistral.ai usage (per-model input/cached/output tokens) against 36.3M fresh / 352M cached / 0.80M output.
- Nov 10 = $52.46. One Omarchy session (`/Work/phone-based-agent`, 710 calls, 05:51-13:42 UTC) = $50.86. Subagents ran Sonnet/Fable, not Mistral.
- Not images: GLM 5.3 is text-only in omp's catalog; the session had 4 tiny image blocks.
- Cost split that day: cache reads 58% (217M tokens), fresh input 40% (15M), output 2%.
- Root cause 1: no compaction. Context grew 15k -> 483k; default trigger is about 890k on GLM's 1M window.
- Root cause 2: ~41 prefix-cache misses on 180-480k prompts, most within 60 s of the previous call (so not a TTL). About $17-19 wasted that day, similar on Nov 5. Cause not visible in logs; likely Mistral-side [INFERENCE].
- omp's `mistral-large-4` price is 2x Mistral's published rate ($1.36/$4.18 vs $0.7/$2.1).

## Action taken
`compaction.modelThresholds: {"mistral/zai-glm-5-3": "f150000"}` on all three machines (and in `model-roles.yml`). Estimated Nov 10 cost at a perfect cache would have been ~$33; compaction should cut it further.
Keep in mind: re-check the dashboard vs omp totals; watch for cache-miss calls (fresh input > 30k with cacheRead dropping) in long GLM sessions.

## Fallback verification (live test, mock provider, isolated config dir)
- 402 (JSON `billing_vibe_budget_exhausted` or plain text) hops to the next chain model on the first request.
- 429 retries the same model ~12 times (~30 s) before hopping.
- Hop is sticky ~30 min (quota) then restores at the next prompt; the new model re-reads full context uncached.
- Mistral's real cap error is inferred from mistral-vibe issue #1362, not observed. `usageAwareFallback` has no Mistral usage reader, so no pre-cap warning.
- `task`, `review`, `vision`, `smol`, `tiny` chains contain GLM, so hops can spend Mistral budget.
