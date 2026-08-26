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

`agents/architect.md` and `agents/critical.md` at the repo root. Both are leaf agents
(`spawns: []`): no `write`, `edit`, or `task` tool, so they can't modify anything or recurse.

- **`architect`**: `tools: [read, grep, glob]`. Produces RFC-style design recommendations —
  constraints, invariants, interfaces, trade-offs, migration/rollback notes. Does not implement.
- **`critical`**: `tools: [read, grep, glob, bash]`. Independent pre-commit/pre-cutover gate.
  System prompt scopes `bash` to non-destructive inspection (`git status`/`diff`/`show`, logs) and
  explicitly forbids the gated action itself (commit/push/deploy/migrate/reset/clean). Returns
  GO / NO-GO / GO-WITH-CONDITIONS — advisory, never self-authorizing.

One correction made to the `slow` model's own suggestion before applying: it first proposed
`tools: [read, grep, find, ls]`, which are Claude Code tool names, not OMP's — this harness's
actual read-only surface is `read`, `grep`, `glob`. Fixed before writing the files.

## Known limitations (from the same review, not yet independently re-verified)

- **Dispatchability ≠ automatic invocation.** Installing these files does not make anything call
  `architect` before a design decision or `critical` before a commit — that trigger, if wanted,
  has to be a separate rule/hook/habit. A "gate" that's never actually dispatched isn't a gate.
- **Cross-provider independence depends on how `critical` fails over.** `critical`'s value as an
  *independent* check assumes `@critical` resolves to a provider genuinely different from whatever
  produced the change under review. Check `retry.fallbackChains.critical` doesn't quietly route
  back to the same provider on a bad day.
- **`bash` is a coarse capability.** A system-prompt instruction not to use destructive commands is
  not an enforcement boundary — if this environment doesn't gate `bash` behind approval/sandboxing,
  a determined or confused model could still run something destructive. Drop `bash` from
  `critical`'s tool list and have the caller supply diff/log evidence directly in the task if that
  risk matters more than the convenience.
- **`task.disabledAgents` / allowlists** would silently make either name unusable even with a
  correct file — not currently set on the source machine, but worth checking on import.
- Not verified end-to-end with an actual `task(agent: "architect", ...)` dispatch in this session
  (would have spent a real turn on both providers to confirm) — file schema matches
  `docs/task-agent-discovery.md`'s documented example exactly, and tool names were checked against
  the real tool list, but live dispatch is unverified.
