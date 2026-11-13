# Agent notes for this repo

Config snapshot plus evidence for OMP model roles. Methodology and the full update procedure:
[research/RESEARCH-PLAYBOOK.md](research/RESEARCH-PLAYBOOK.md) (step 9 for shipping).

When a change bumps the snapshot version, finish every item:

1. `model-roles.yml` header: `Generated` date and `Snapshot version`.
2. `README.md` snapshot line, plus any role row whose chain changed.
3. `CHANGELOG.md`: a new `## vN` section on top.
4. `OWNER-NOTES.md`: a dated note for machine-specific evidence; a new `research/` file is registered
   in the playbook's file list.
5. Apply to the live config and confirm with `scripts/check-live.sh` (all `OK`).
6. Commit and push.
7. Update the GitHub repository description to the new version, so it matches the README:
   `gh repo edit --description "..."`. Verify with `gh repo view --json description`. A push does
   not update it.

Research-only work (previews, evaluations not applied) bumps nothing; see the playbook's
planning-only exemption.
