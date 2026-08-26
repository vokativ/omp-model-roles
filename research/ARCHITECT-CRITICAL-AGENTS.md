# Wiring `architect`/`critical` into real subagent dispatch — 2026-08-26

## The gap

`model-roles.yml` has defined `architect` and `critical` as `modelRoles`/`retry.fallbackChains`
entries since the Strategy C rollout (v8), alongside `review`, `security`, `fast_worker`, and
`good_worker`. Only four of those six were ever actually *reachable* as subagents:

`task.agentModelOverrides` binds a role onto an **existing bundled agent name** — it cannot create
a new one:

```yaml
task:
  agentModelOverrides:
    security-reviewer: "@security"
    reviewer: "@review"
    sonic: "@fast_worker"
    task: "@good_worker"
```

`reviewer`, `security-reviewer`, `sonic`, and `task` are bundled agent names that already exist
(`docs/task-agent-discovery.md`'s bundled list: `scout`, `designer`, `reviewer`,
`security-reviewer`, `librarian`, `task`, `sonic`). No bundled agent is named `architect` or
`critical`, so there was nothing for those two role names to bind onto. They were real settings
with no dispatch path — reachable only by manually switching the whole session (`/model
@architect`, or Ctrl+P cycling, since both are listed in `cycleOrder`), never via `task(agent=
"architect", ...)`.

## The fix

OMP documents a "role-backed custom agent" pattern for exactly this
(`docs/task-agent-discovery.md`, "Role-backed custom agents"): a markdown file with `name`,
`description`, and `model: "@rolename"` frontmatter, placed under `~/.omp/agent/agents/*.md`
(every project) or `<project>/.omp/agents/*.md` (one project), becomes a real dispatchable agent
type — `task(agent: "architect", ...)` starts resolving instead of erroring "Unknown agent".

Reviewed the two options (wire them up vs. leave them session-only) with the `slow` role model
(`openai-codex/gpt-5.6-sol`) before committing to a direction. Verbatim recommendation: wire both
up as dispatchable, because the *analysis* both roles do is delegatable even though the *final
call* isn't — `architect` can independently produce an RFC/decomposition for the main session to
accept or reject; `critical`'s whole value is an isolated, disconfirming-evidence review before a
high-risk action, which is architecturally a subagent's job, not something that has to run inline.
Session-only access and subagent dispatch are complementary, not either/or — both stay available.

## What shipped

`agents/architect.md` and `agents/critical.md` at the repo root, installed to
`~/.omp/agent/agents/`. Both declare `spawns: []` and omit `write`/`edit`/`task`.

- **`architect`**: `model: "@architect"`, `thinking: high`, `tools: [read, grep, glob]`. Produces
  RFC-style design recommendations — constraints, invariants, interfaces, trade-offs,
  migration/rollback notes. Does not implement.
- **`critical`**: `model: "@critical"`, `thinking: high`, `tools: [read, grep, glob, bash]`, plus an
  `output:` JSON-schema contract (`verdict` enum GO / NO-GO / GO-WITH-CONDITIONS, `findings[]` with
  P0-P3 severity + evidence, `conditions[]`, `unverified[]`). System prompt scopes `bash` to
  non-destructive inspection and forbids the gated action itself.

`thinking: high` deliberately, not `xhigh`: `high` is the deepest level supported by every model in
both roles' chains (`claude-opus-5` and `gpt-5.6-sol` go to `max`, but
`nvidia/deepseek-ai/deepseek-v4-flash` only offers `low,high,max` and `xai-oauth/grok-4.6` exposes
no ladder at all). `xhigh` would have been unsatisfiable on failover.

Two corrections made to the `slow` model's own suggestions before applying:
- it proposed `tools: [read, grep, find, ls]` — `find`/`ls` are Claude Code tool names, not OMP's;
  this harness's read-only surface is `read`, `grep`, `glob`.
- `ast_grep` was considered for `architect` (read-only structural queries would genuinely help
  decomposition analysis) and rejected: `astGrep.enabled` is `false` on this machine, so declaring
  it would advertise a capability that does not exist.

## Verified by live dispatch — 2026-08-26

Five real dispatches, not inference:

| Dispatch | Agent | Result |
|---|---|---|
| `ArchSmoke` | architect | resolved `anthropic/claude-opus-5` (not a fallback), read tools worked |
| `CritSmoke` | critical | resolved `anthropic/claude-opus-5`, `bash` executed `git log` successfully |
| `ArchVerify` | architect | confirmed `thinking: high` in effect; produced a real structural critique |
| `CritVerify` | critical | returned a schema-conformant `verdict`/`findings`/`conditions`/`unverified` object |
| `CriticalIndependence` | critical | same-model Opus producer/reviewer correctly returned `SAME-MODEL` + `GO-WITH-CONDITIONS` |

Frontmatter parsing is confirmed sound by inference from `CritSmoke`: `bash` worked, so
`tools: [read, grep, glob, bash]` parsed as a real YAML **array**. Had the YAML parser failed and
`parseFrontmatter` fallen back to its naive `key: value` line parser, CSV-splitting that literal
string would yield `["[read", "grep", "glob", "bash]"]` — `bash` would not have been available.
The folded `description: >-` scalar therefore parsed correctly too. The nested `output:` schema
likewise parses (a malformed definition is *skipped entirely*, which would have produced
`Unknown agent`; `CritVerify` dispatched and honoured the schema).

## Containment: the `tools:` allowlist is NOT a security boundary

**An earlier draft of this document claimed these agents "can't modify anything or recurse"
because they lack `write`/`edit`/`task`. That claim was false and has been removed.** The
`CritVerify` dispatch disproved it by execution: running as `critical`, with a declared allowlist
of `[read, grep, glob, bash]`, it successfully executed arbitrary JavaScript and reported
`{"jsExecutionWorks":42,"cwd":"...omp-model-roles","fsWriteFileSyncReachable":"function","fsRmSyncReachable":"function"}`.
Nothing was written or deleted, but both `fs.writeFileSync` and `fs.rmSync` were reachable.

What actually happens to a subagent's tool set (`docs/task-agent-discovery.md`, `runSubprocess`):

- `tools:` frontmatter bounds **built-in** tools only.
- `hub` is **auto-added** to explicit tool lists by design — and `hub` includes `op: "start"`,
  a process-launch and side-effect channel that `spawns: []` does not close.
- **MCP proxy tools are injected orthogonally to `tools:`.** With an MCP server configured (here:
  `node_repl`), the child receives `mcp__node_repl_js` — arbitrary Node execution — regardless of
  its allowlist.

There is **no per-agent mechanism** to strip MCP tools from a subagent. The only levers are
session-global: `disabledServers` in MCP config (denylist by server name) or
`mcp.enableProjectConfig: false`. Both would remove the server from the parent session too.

Practical consequence: treat `architect`/`critical` as **advisory, non-privileged-by-convention**,
not sandboxed. The system-prompt prohibitions and the `tools:` list express *intent*, and reduce
the chance of an accident, but they do not enforce anything. If real containment is required it has
to come from the harness — MCP server gating, `task.isolation.mode` (currently `none`), or approval
prompts — not from frontmatter or prompt wording.

## Critical's intended use and independence guard — resolved in instructions

Evidence from current wiring and history:

- **No automatic trigger exists.** `critical` runs only when a caller explicitly dispatches
  `task(agent: "critical", ...)` or manually selects `/model @critical`. Retry/usage-aware fallback
  changes the model only *after* invocation; it never causes an invocation. Current `cycleOrder`
  includes `architect`, not `critical` — an earlier README claim that both were present was stale.
- Real, non-test usage found in `parent-help-android`: two adversarial Tier-1 **implementation**
  reviews (`CriticalReviewer.md`, `CriticalReviewer2.md`). The omp-model-roles history is test-only
  (`CritSmoke`, `CritVerify`, and the provenance guard below).
- Therefore `critical` is primarily a final implementation/operational gate for work produced by
  `default` (Gemini), `task` (Terra), `slow`/`plan`/`review`/`security` (Sol), or `designer`
  (Grok) — not an automatic peer reviewer for `architect`.

This supports keeping `modelRoles.critical: anthropic/claude-opus-5`: it provides a different
provider/model from all likely producers above. Moving it to Sol would improve only the architect
pairing while losing independence against four Sol-backed roles. The exception remains real:
`modelRoles.critical` and `modelRoles.architect` are the same Opus 5 model, and critical's Sol
fallback is not independent from Sol-produced work.

v15 hardens `agents/critical.md` instead of reallocating the role:

- output schema now requires `provenance`:
  `producerRole`, `producerModel`, `reviewerModel`, and `independence`;
- caller must supply producer role/model; missing data becomes literal `unknown` +
  `independence: UNKNOWN`;
- matching concrete producer/reviewer models becomes `SAME-MODEL`;
- `SAME-MODEL` or `UNKNOWN` may never return unconditional `GO`;
- when reviewing architect/Opus output, get a different-model architecture critique (normally the
  Sol-backed bundled `reviewer`) before treating the gate as independent;
- if critical falls back to Sol while reviewing `slow`, `plan`, `review`, or `security`, the same
  guard applies.

Live test `CriticalIndependence` supplied producer `architect` /
`anthropic/claude-opus-5`; the critical agent itself resolved to Opus 5 and correctly returned:

```json
{
  "verdict": "GO-WITH-CONDITIONS",
  "provenance": {
    "producerRole": "architect",
    "producerModel": "anthropic/claude-opus-5",
    "reviewerModel": "anthropic/claude-opus-5",
    "independence": "SAME-MODEL"
  },
  "conditions": ["Obtain review from a different concrete model before treating the gate as independent."]
}
```

The broader depth-tier concentration found by `ArchVerify` remains a separate, unapplied proposal:
six roles (`slow`, `plan`, `review`, `security`, `architect`, `critical`) resolve across primary +
first-fallback to `{gpt-5.6-sol, claude-opus-5}`, then all six drop to
`xai-oauth/grok-4.6`. Its cost-neutral resilience proposal is to insert
`google-antigravity/claude-sonnet-4-6` ahead of Grok. This is not required for critical's intended
implementation-gate use and would alter A/B-backed fallback ordering, so v15 does not apply it.

## Remaining unverified

- The project-scoped install path `<repo>/.omp/agents/*.md` is documented but never exercised;
  only the global `~/.omp/agent/agents/` path is confirmed working.
- `critical`'s `output` schema is confirmed honoured on `claude-opus-5` only. Whether
  `gpt-5.6-sol`, `grok-4.6`, or `deepseek-v4-flash` satisfy it on failover is untested — and
  failover off the scarce Anthropic pool is the expected path, not an edge case.
- Whether OMP enforces the `tools:` allowlist for built-in tools at all; only the MCP bypass was
  demonstrated.
- **Dispatchability is not automatic invocation.** Nothing calls `architect` before a design
  decision or `critical` before a commit. That trigger, if wanted, is a separate rule/hook/habit —
  a gate that is never dispatched is not a gate.
- `task.disabledAgents` is empty and `task.maxRecursionDepth` is 2 on this machine (both checked);
  either could silently break dispatch on another import target.
