# `omp-wt`: Git Worktree Helper for OMP (Oh My Pi)

A fast, beginner-friendly tool to run multiple parallel investigations or tasks on the same codebase using **Git Worktrees** and **OMP**.

Supports **Linux**, **macOS**, **Meta Quest (Termux)**, and **Windows (PowerShell & Git Bash)**.

---

## What is a Git Worktree? (The Mental Model)

Normally, Git gives you **one folder** for your project. When you switch branches, Git swaps files in that single folder. If you have uncommitted code, a running dev server, or ongoing build tasks, switching branches can cause confusion, compile errors, or lost changes.

A **Git Worktree** gives you **multiple working directories simultaneously**, all sharing the exact same `.git` repository database:

```
                  ┌────────────────────────────────────────┐
                  │       Shared Git Database (.git)       │
                  │  (commits, history, branches, stashes) │
                  └────┬──────────────┬───────────────┬────┘
                       │              │               │
      ┌────────────────┴┐     ┌───────┴────────┐     ┌┴───────────────┐
      │  Main Directory │     │ Worktree Alpha │     │ Worktree Beta  │
      │  (branch: main) │     │ (branch: feat) │     │ (branch: exp1) │
      └─────────────────┘     └────────────────┘     └────────────────┘
```

### Why Worktrees are Ideal for AI Coding Harnesses (OMP)
1. **Zero file conflicts:** OMP can rewrite files, run tests, and experiment in an isolated worktree while your primary working directory remains untouched.
2. **Parallel investigations:** You can run multiple terminal windows with different OMP agents solving different problems simultaneously on the same repository.
3. **Instant creation:** Making a worktree takes a fraction of a second and uses zero extra download bandwidth because it uses your local Git objects.
4. **Shared history:** Commits made by OMP in a worktree are immediately accessible everywhere in your repo.

---

## Installation

### Linux, macOS, and Meta Quest (Termux)
Run the included installer:
```bash
./scripts/omp-wt/install.sh
```
*Or copy manually:*
```bash
cp scripts/omp-wt/omp-wt.sh ~/.local/bin/omp-wt
chmod +x ~/.local/bin/omp-wt
```

### Windows (PowerShell)
In a PowerShell window:
```powershell
.\scripts\omp-wt\install.ps1
```

---

## Daily Usage & Workflow

### 1. Interactive Mode
Inside your project directory, simply run:
```bash
omp-wt
```
- It shows your current branch and active worktrees.
- Prompts you for a worktree/branch name (e.g. `fix-login-flow`).
- Prompts for a starting branch (defaults to your current branch).
- Checks for local uncommitted config files (`.env`, `keystores`) and offers to copy them.
- Creates `.worktrees/fix-login-flow` and immediately launches OMP inside it.

### 2. Fast Command Line Invocation
```bash
# Create worktree and start OMP immediately
omp-wt auth-spike

# Create worktree branching off a specific base (e.g. main)
omp-wt perf-fix main

# Pass custom flags directly to OMP
omp-wt bug-check -- --model smol
```

### 3. See Active Worktrees & Status
```bash
omp-wt list
```
**Example Output:**
```
Git Worktrees for my-mobile-app:

  • main [main root] (branch: main)
    Status: ✓ clean
    Latest: feat: initial commit (313612d) (2 hours ago)
    Path:   /home/nemanja/Projects/my-mobile-app

  • auth-spike [worktree] (branch: auth-spike)
    Status: ● 2 uncommitted file(s)
    Latest: fix: token refresh loop (4fa91b0) (10 minutes ago)
    Path:   /home/nemanja/Projects/my-mobile-app/.worktrees/auth-spike

Next Actions:
  omp-wt <name>          Launch OMP in that worktree
  omp-wt rm <name>       Delete worktree and its branch
  git merge <branch>     Merge changes into your current branch
```

### 4. What to Do When OMP Finishes

#### Option A: Keep the changes (Merge)
From your main repository folder:
```bash
git merge auth-spike
```

#### Option B: Discard / Clean up the worktree
When you are done with an experiment or have finished merging:
```bash
omp-wt rm auth-spike
```
*(This safely removes the `.worktrees/auth-spike` folder and asks if you also want to delete the branch.)*

---

## Local Config & Stack-Specific Guidance

When Git creates a worktree, files that are ignored by `.gitignore` are **not** present in the new worktree.

`omp-wt` automatically detects common untracked configuration files in your main repo and offers to copy them into the new worktree:

| Stack | Common Local Files Detected & Copied |
|---|---|
| **Android Apps** | `local.properties`, `*.keystore`, `*.jks`, `google-services.json`, `secrets.properties` |
| **iOS Apps** | `GoogleService-Info.plist`, local `.xcconfig` files |
| **Web / TypeScript** | `.env`, `.env.local`, `.env.development`, `.npmrc`, `.yarnrc.yml` |
| **Python / Backend** | `.env`, `secrets.yaml`, `config.local.json`, `local_settings.py` |

### Package Managers & Dependencies
- **Node.js (pnpm / bun):** Near-instantaneous installs inside worktrees because package caches are shared globally.
- **Node.js (npm / yarn classic):** Run `npm install` inside the worktree if your build or test scripts require node_modules.
- **Android / Gradle:** Gradle daemon and caches (`~/.gradle`) are shared globally, so builds in new worktrees reuse cached dependencies automatically.
- **Rust (cargo):** `cargo` shares `~/.cargo` crates cache.
- **Python:** If using `uv` or `venv`, create or activate a virtualenv in the worktree.

---

## Built-in Help & Beginner Guide

At any time, run:
```bash
# Read the visual beginner's guide
omp-wt guide

# View command reference
omp-wt --help
```
