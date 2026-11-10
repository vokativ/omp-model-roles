# Mistral lineup: what each model is for, speed, and use-case tests — 2026-11-10

*In `research/`. Bare filenames such as `model-roles.yml` and `README.md` refer to the repo root,
one level up.*

Written 2026-11-10 against snapshot v38 (omp 18.18.6 on omarchy, 18.16.0 on nemanja-lubuntu). The
owner asked what each Mistral-hosted model is officially for (coding, orchestration, image reading,
PDF reading, image generation), including the hosted Z.ai GLM-5.3, and how fast tokens arrive. Only
the **latest canonical version** of each family was tested (owner instruction). Follow-on: a fleet
audit of the current role assignments, reviewed by the `slow` (Opus 5.5) and `review` (Sol 6.1)
models. **Nothing in `model-roles.yml` was changed by this work.**

**How the tests ran.** Direct calls to `https://api.mistral.ai/v1` with the `/login mistral` plan
key (EDU, Vibe Code allowance), streaming with `stream_options.include_usage`, default effort. Not the
OMP harness: for OMP-path behaviour (edit-tool errors, tool-task wall times) see
`MISTRAL-EVALUATION.md` and `DEFAULT-ROLE-EVALUATION.md`. **n = 1 per cell**: directional only.
Decode tok/s = completion tokens (including reasoning tokens) / time after the first chunk.
Scratch scripts lived in `/tmp` and are not committed.

---

## Lineup (live `GET /v1/models`, 64 ids, 2026-11-10)

| Selector | What it really is | Context / max out (OMP) | Input | Reasons | Official purpose |
|---|---|---|---|---|---|
| `mistral/mistral-large-4` | Mistral Large 4.0 (alias `mistral-large-4-0`) | 1,048,576 / 262,144 | text + image | yes | flagship general reasoning, multimodal |
| `mistral/zai-glm-5-3` | Z.ai GLM-5.3 (aliases `zai-glm-5`, `zai-glm-latest`); MoE ~753B/40B | 1,048,576 / 131,072 | **text only** | always | deep coding/agentic work; v38 `default` primary |
| `mistral/zai-glm-5-3-flash` | GLM-5.3 Flash, MoE 320B/18B | 1,048,576 / 131,072 | text + image | always | fast multimodal reasoning |
| `mistral/deepseek-v4-1-flash-1017` | DeepSeek V4.1 Flash, public preview | 1,048,576 / 128,000 | text + image (API caps; OMP 18.18.6 catalog now also lists image) | yes | low-latency reasoning and tools |
| `mistral/mistral-medium-latest` | Medium 3.5 (`mistral-medium-2604`; also aliased by `magistral-medium-latest`, `mistral-vibe-cli-latest`, `-with-tools`) | 262,144 / 262,144 | text + image | yes | balanced chat/reasoning |
| `mistral/mistral-small-latest` | Small 4 (`mistral-small-2603`; also `magistral-small-latest`, `mistral-vibe-cli-fast`) | 262,144 / 256,000 | text + image | yes | lightweight chat |
| `mistral/codestral-latest` | Codestral 25.08 (`codestral-2508`; also `mistral-code-latest`, `mistral-code-fim-latest`) | 256,000 / **8,192** | text | **no** | code completion and FIM |
| `mistral/ministral-{14b,8b,3b}-latest` | Ministral 3 (2512) | 262,144 (3B: 131,072) | text + image | no | edge/small instruct |
| `mistral-ocr-latest` | Mistral OCR 4.1 (`mistral-ocr-4-1`) | — | PDF / image | — | document extraction (`POST /v1/ocr`) |
| `voxtral-*` | transcription (mini/small, realtime), TTS (`voxtral-mini-tts-3`), audio understanding (`voxtral-small-latest`) | — | audio | — | speech |

Traps: `mistral-large-latest` still points to `mistral-large-2512` ("release candidate for ml3"),
**not** Large 4. `glm-5-2` / `zai-glm-5-2` (GLM 5.2) is still listed. No deprecation flags were set on
any id. GLM-5.3 rejects images with HTTP 400 `code 3051` "Image input is not enabled for this model"
on the raw API; inside OMP the image is replaced by a placeholder instead (no error).

**No image generation.** `POST /v1/images/generations` returns 404. Le Chat's image generation is a
consumer feature (Black Forest Labs FLUX), not part of this API.

## Speed baseline ("count 1 to 30")

| Model | TTFT | Decode tok/s | Total | Completion tok (reasoning) |
|---|---|---|---|---|
| `deepseek-v4-1-flash-1017` | **0.47 s** | 339 | **0.65 s** | 60 (0) |
| `zai-glm-5-3` | 3.11 s (other runs 0.51-0.83 s) | **556** | 3.30 s | 103 (42) |
| `zai-glm-5-3-flash` | 1.18 s | 406 | 1.44 s | 105 (44) |
| `mistral-large-4` | 0.73 s | 210 | 1.43 s | 147 (85) |
| `mistral-small-latest` | 0.54 s | 222 | 0.90 s | 81 |
| `codestral-latest` | 0.47 s | 202 | 0.97 s | 102 |
| `mistral-medium-latest` | 0.56 s | 200 | 0.97 s | 81 |
| `ministral-8b-latest` | 0.49 s | 169 | 1.00 s | 85 |
| `ministral-3b-latest` | 0.47 s | 121 | 1.28 s | 98 |
| `ministral-14b-latest` | 0.48 s | 116 | 1.32 s | 98 |

GLM-5.3 streams its reasoning as `content` parts of type `thinking`; a 5-line poem cost 1,607
completion tokens of which 1,558 were reasoning (TTFT 0.62 s, 8.2 s decode).

## Use-case tests

### Coding: minimum-window-substring, O(|s|+|t|), 5 hidden test cases

| Model | Tests | TTFT | Decode | tok/s | Tokens (reasoning) |
|---|---|---|---|---|---|
| `codestral-latest` | 5/5 | 0.45 s | 1.85 s | 176 | 325 (0) |
| `deepseek-v4-1-flash-1017` | 5/5 | 0.56 s | 1.45 s | 175 | 254 (0) |
| `mistral-medium-latest` | 5/5 | 0.56 s | 0.99 s | 259 | 257 (0) |
| `mistral-small-latest` | 5/5 | 0.90 s | 1.11 s | 231 | 257 (0) |
| `ministral-14b-latest` | 5/5 | 0.66 s | 2.93 s | 88 | 257 (0) |
| `zai-glm-5-3` | 5/5 | 0.83 s | 8.61 s | 338 | 2,910 (2,568) |
| `mistral-large-4` | 5/5 | 0.78 s | 17.05 s | 181 | 3,079 (2,835) |
| `zai-glm-5-3-flash` | 5/5 | 0.73 s | **96.5 s** | 270 | **26,035 (25,709)** |

GLM-5.3 Flash went into a 25.7K-token reasoning loop on this prompt (n = 1): a latency hazard for
early, latency-sensitive fallback hops.

### Orchestration: two parallel tool calls (`get_weather` + `book_flight`)

All eight chat models emitted both calls with correct JSON arguments. Latency: DeepSeek 0.65 s,
Medium 0.69 s, Small 0.82 s, Codestral 0.83 s, Ministral 14B 1.12 s, GLM-5.3 1.31 s, Large 4 1.67 s,
GLM-5.3 Flash 2.01 s.

### Constraint reasoning: 4 people / 4 seats, 3 constraints (2 valid orders)

All correct except **Codestral (found 1 of 2)**. Decode time: DeepSeek 0.96 s (447 tok/s), GLM-5.3
Flash 2.3 s, Small 3.1 s, Medium 4.2 s, GLM-5.3 6.0 s, Large 4 9.1 s, Codestral 7.6 s (wrong),
Ministral 14B 22.7 s.

### Image reading: synthetic invoice (number, amount, key, two coloured shapes)

All image-capable models read every field and both shapes. TTFT / tok/s: Large 4 0.91 s / 245 (most
detail), GLM-5.3 Flash 0.89 s / 367, DeepSeek 1.01 s / 339, Medium 0.91 s / 217, Small 0.92 s / 197,
Ministral 14B 0.75 s / 98. GLM-5.3: HTTP 400 (text only).

### PDF reading: `mistral-ocr-latest` (OCR 4.1)

`POST /v1/ocr` with `document: {type: "document_url", document_url: "data:application/pdf;base64,..."}`
(`type: document_base64` is rejected; `image_url` and `file` are the other accepted chunk types).
One-page PDF in **0.83 s**: Markdown per page, typed blocks (`title`/`text`/`image`) with pixel
bounding boxes, extracted sub-images with coordinates, page dimensions. This is an extraction
pipeline, not chat; chat-vision models answer questions about a page instead.

### Fill-in-the-middle

`codestral-latest` on `POST /v1/fim/completions`: 0.63 s, correct insertion between prefix and suffix.

## What each model is good for (owner summary)

| Use case | Pick | Then |
|---|---|---|
| Deep text coding, default sessions | `zai-glm-5-3` | `mistral-large-4` |
| Fast subagent / tool orchestration | `deepseek-v4-1-flash-1017` (public preview) | `zai-glm-5-3-flash` |
| Code completion / FIM | `codestral-latest` (no general reasoning; 8K output) | — |
| Image reading | `mistral-large-4` | `zai-glm-5-3-flash` |
| PDF / scanned documents | `mistral-ocr-latest` via `/v1/ocr` | `mistral-large-4` |
| Image generation | none on this API | other providers |

## Fleet audit and role recommendations (2026-11-10)

**Machines.** Tailscale peers with OMP sessions: `nemanja-omarchy` (this machine) and
`nemanja-lubuntu` (SSH). The MacBook Air was offline.

**Recent session mix** (assistant turns in the 15 most recent session files per machine, all
roles): omarchy Opus 5.5 117, Sol 6.1 123, Sonnet 5.5 103, GLM-5.3 74, Jev 68, Gemini 3.8 Flash 58,
Haiku 50, GLM-5.3 Flash 6. Lubuntu Sonnet 5.5 231, Gemini 3.8 Flash 100, GLM-5.3 82, Argon 24,
Haiku 7, Fable 7, Sol 4.

**Meters (`omp usage`, 2026-11-10 ~11:00 SGT).** Anthropic 5h 9% / 7d 13% (Fable 3%); openai-codex
5h 26% / 7d 61% (but see `REVIEW-ROLE-EVALUATION.md`: the owner's ChatGPT page disagrees with
omp's Codex meter); Antigravity Argon 0%, Gemini 2.8-5.7%, Claude & GPT 0%; xAI 0% on omarchy but
**SuperGrok 100% / Grok Build 99%** on Lubuntu (2026-11-09 19:33). Quota is per account, so the
omarchy 0% reading is probably stale **[INFERENCE]**.

**Reviews.** The proposals were reviewed in parallel by the `architect` agent (`@slow`, Opus 5.5)
and the `reviewer` agent (`@review`, Sol 6.1), each given the benchmark numbers, meters, and
session patterns.

- Both: never chain two `mistral/*` models in `default` (one HTTP 402 or outage kills both).
- Opus: keep `default` on GLM-5.3 (Terminal-Bench 4.0 41.9% vs DeepSeek 28.8% at high); inside OMP
  images are replaced by placeholders rather than erroring, so the chain order cannot fix images.
  The real xAI defect is `commit`, where Grok Build is the *first* fallback.
- Sol: preferred DeepSeek as `default` (speed, vision), conceded GLM-then-Gemini if GLM stays, and
  wanted exhausted xAI hops removed from the light chains.

**Recommended, not applied** (owner liked them; no config change yet):

| Role | Change |
|---|---|
| `default` | keep `mistral/zai-glm-5-3` -> Gemini 3.8 Flash -> Sonnet 5.5 |
| `commit` | Luna -> Gemini 3.5 Flash-Lite -> Grok Build (move Grok Build from first to last) |
| `widget` | Gemini 3.5 Flash-Lite -> Luna -> Grok Composer (add Luna) |
| `task` | replace the Grok Build tail with `google-antigravity/claude-sonnet-5-5` |
| `smol`/`tiny`, depth chains, `critical`, `vision` | no change |

Caveat added later the same day: on omarchy's omp 18.18.6 every `google-antigravity/*` hop is dead
(see `REVIEW-ROLE-EVALUATION.md`, setup incidents), which affects every Google-based suggestion above
until omarchy runs a working omp build.
