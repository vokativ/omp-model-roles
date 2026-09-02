<#
.SYNOPSIS
    omp-wt: Git Worktree Manager for OMP (Oh My Pi) for Windows PowerShell.
.DESCRIPTION
    Creates and manages isolated Git worktrees for parallel OMP sessions.
    Supports interactive mode, human-readable listing, untracked config detection (.env, keystores),
    and cleanup.
#>

[CmdletBinding(DefaultParameterSetName = "Default")]
param(
    [Parameter(Position = 0, ParameterSetName = "Default")]
    [string]$Name,

    [Parameter(Position = 1, ParameterSetName = "Default")]
    [string]$BaseRef,

    [Parameter(ParameterSetName = "List")]
    [Alias("ls")]
    [switch]$List,

    [Parameter(ParameterSetName = "Remove")]
    [Alias("rm", "delete")]
    [string]$Remove,

    [Parameter(ParameterSetName = "Prune")]
    [switch]$Prune,

    [Parameter(ParameterSetName = "Guide")]
    [Alias("intro", "explain")]
    [switch]$Guide,

    [Parameter(ParameterSetName = "Help")]
    [switch]$Help,

    [switch]$CopyEnv,
    [switch]$NoCopyEnv,
    [switch]$Sibling,
    [switch]$Nested,
    [Alias("y")]
    [switch]$Yes
)

function Show-IntroGuide {
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "                Git Worktrees & OMP: The Beginner's Guide" -ForegroundColor Magenta
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host @"

1. WHAT IS A GIT WORKTREE?
   Normally, Git gives you ONE folder for your project. When you switch branches,
   Git changes the files inside that one folder. If you have uncommitted edits or
   running servers/tests, switching branches can be messy or cause conflicts.

   A Git Worktree allows you to have MULTIPLE folders for the same project open
   simultaneously on your disk, all connected to the same Git history:

      ┌────────────────────────────────────────────────────────┐
      │               Shared Git Database (.git)               │
      │         (all commits, branches, stashes, history)      │
      └───────────┬───────────────────┬───────────────────┬────┘
                  │                   │                   │
        ┌─────────┴─────────┐ ┌───────┴─────────┐ ┌───────┴─────────┐
        │   Main Directory  │ │ Worktree: exp-1 │ │ Worktree: exp-2 │
        │   (branch: main)  │ │ (branch: exp-1) │ │ (branch: exp-2) │
        └───────────────────┘ └─────────────────┘ └─────────────────┘

2. WHY USE IT WITH OMP?
   • Zero file conflicts: Let OMP rewrite files, run tests, or install packages
     in an isolated worktree while your main code remains 100% untouched.
   • Parallel investigations: Run multiple OMP agents in parallel on different
     ideas or bug investigations without switching back and forth.
   • Fast & lightweight: Creating a worktree takes 0.1 seconds because it uses
     the local Git database already on your computer (no re-cloning).

3. WORKFLOW: STARTING, RETURNING, & MERGING:
   • Start a new investigation:
     > omp-wt investigate-auth
     (Creates .worktrees\investigate-auth, sets up branch, copies configs, starts OMP)

   • Re-enter an EXISTING worktree with OMP (from project root):
     > omp-wt investigate-auth
     (If it already exists, omp-wt detects it and opens OMP right inside it!)
     (Or run 'omp-wt' with no arguments to see your worktree list and select it)

   • Just open a terminal in that worktree (without OMP):
     > cd .worktrees\investigate-auth

   • Merge completed work into your main branch:
     > git merge investigate-auth

   • Clean up when finished:
     > omp-wt -Remove investigate-auth
4. IMPORTANT THINGS TO KNOW:
   • One branch per worktree: Git will not let two worktrees checkout the same
     branch at the same time. This prevents conflicting changes.
   • Local files (.env, keystores): Files ignored by Git are not copied
     automatically. omp-wt will detect common local files and ask to copy them.
================================================================================
"@
}

function Show-HelpMessage {
    Write-Host @"
omp-wt - Launch OMP in an isolated Git Worktree

USAGE:
    omp-wt                      Interactive wizard (prompts for name & base)
    omp-wt <name>               Create/open worktree <name> and launch OMP
    omp-wt <name> <base-ref>    Create worktree <name> starting from <base-ref>

COMMANDS:
    omp-wt -List, ls            List all active worktrees with status & age
    omp-wt -Remove <name>, rm   Delete a worktree and clean up git references
    omp-wt -Prune               Clean up stale worktree metadata
    omp-wt -Guide, intro        Show beginner visual guide to worktrees
    omp-wt -Help                Show this help screen

OPTIONS:
    -CopyEnv                    Automatically copy detected local config (.env, keystores)
    -NoCopyEnv                  Skip copying local configuration files
    -Sibling                    Create worktree as a sibling directory (..\<repo>-<name>)
    -Nested                     Create worktree inside project (.worktrees\<name>) [Default]

EXAMPLES:
    omp-wt                      # Interactive mode
    omp-wt fix-login            # Quick create & launch
    omp-wt spike-db main        # Branch from main
    omp-wt -List                # See all active worktrees
    omp-wt -Remove fix-login    # Clean up when done
    omp-wt -Guide               # Read the beginner's guide
"@
}

# Handle Help and Guide early
if ($Help -or $Name -eq "-h" -or $Name -eq "--help" -or $Name -eq "help") {
    Show-HelpMessage
    return
}
if ($Guide -or $Name -eq "guide" -or $Name -eq "intro" -or $Name -eq "explain") {
    Show-IntroGuide
    return
}

# Verify Git repository
$isGit = git rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Not inside a Git repository."
    return
}

$commonGitDir = (git rev-parse --git-common-dir 2>$null).Trim()
if (-not $commonGitDir) {
    $commonGitDir = (git rev-parse --git-dir 2>$null).Trim()
}
if ($commonGitDir -and -not [System.IO.Path]::IsPathRooted($commonGitDir)) {
    $commonGitDir = [System.IO.Path]::GetFullPath($commonGitDir)
}

if ($commonGitDir -and (Split-Path -Leaf $commonGitDir) -eq ".git") {
    $mainRepoRoot = Split-Path -Parent $commonGitDir
} else {
    $mainRepoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
}

$repoName = Split-Path -Leaf $mainRepoRoot

function Get-CommandTypo ($inputStr) {
    if (-not $inputStr) { return $null }
    $clean = $inputStr.TrimStart('-', '/').ToLower()
    switch ($clean) {
        { $_ -in 'intor','itnro','inrto','intr','introo','introd','into','inro' } { return 'intro' }
        { $_ -in 'gudie','gide','guied','gude','giude','guid','giud','guie' } { return 'guide' }
        { $_ -in 'explian','explan','expln','exlpain','xplain' } { return 'explain' }
        { $_ -in 'lsit','listt','lis','lists','lit','lst','sl' } { return 'list' }
        { $_ -in 'purne','prun','pruen','pune','prunne','pruner' } { return 'prune' }
        { $_ -in 'remov','remvoe','rmv','del','delet','dlete','delt','remoev' } { return 'remove' }
        { $_ -in 'hepl','hlp','hlep','halp','hellp','hep','hel' } { return 'help' }
        { $_ -in 'pth','paht','ptah' } { return 'path' }
        default { return $null }
    }
}
function Get-DefaultBranch {
    $remoteHead = (git symbolic-ref refs/remotes/origin/HEAD 2>$null)
    if ($remoteHead) { return ($remoteHead -split '/')[-1].Trim() }
    foreach ($b in @('main', 'master', 'trunk', 'development', 'dev')) {
        git show-ref --verify --quiet "refs/heads/$b"
        if ($LASTEXITCODE -eq 0) { return $b }
    }
    $curr = (git branch --show-current 2>$null).Trim()
    if ($curr) { return $curr }
    return "HEAD"
}


# Subcommand aliases
if ($Name -eq "list" -or $Name -eq "ls") { $List = $true; $Name = $null }
if ($Name -eq "prune") { $Prune = $true; $Name = $null }
if ($Name -eq "rm" -or $Name -eq "remove" -or $Name -eq "delete") {
    $Remove = $BaseRef
    $Name = $null
}
if ($Name -eq "new" -or $Name -eq "create" -or $Name -eq "add") {
    $Name = $BaseRef
    $BaseRef = $null
}

# Check for mistyped commands
if ($Name) {
    $typo = Get-CommandTypo $Name
    if ($typo) {
        Write-Host "Error: Unknown command '$Name'. Did you mean 'omp-wt $typo'?" -ForegroundColor Red
        Write-Host "Run 'omp-wt -Help' for usage, or 'omp-wt -Guide' for an introduction." -ForegroundColor DarkGray
        return
    }
}
# List worktrees
if ($List) {
    Write-Host "`nGit Worktrees for " -NoNewline -ForegroundColor Cyan
    Write-Host $repoName -ForegroundColor Green
    Write-Host ""

    $porcelain = git worktree list --porcelain
    $currentWt = $null
    $currentHead = $null
    $currentBranch = $null

    function Print-WorktreeItem ($path, $branch, $head, $root) {
        if (-not $path) { return }
        $isMain = ($path -eq $root)
        $displayName = if ($isMain) { "main" } else { Split-Path -Leaf $path }
        $badge = if ($isMain) { "[main root]" } else { "[worktree]" }
        $badgeColor = if ($isMain) { "Magenta" } else { "Blue" }

        $lastLog = git -C $path log -1 --format="%cr|%s (%h)" 2>$null
        if ($lastLog) {
            $parts = $lastLog -split '\|', 2
            $timeAgo = $parts[0]
            $commitMsg = $parts[1]
        } else {
            $timeAgo = "unknown"
            $commitMsg = "no commits"
        }

        $dirtyFiles = @(git -C $path status --porcelain 2>$null)
        $dirtyCount = $dirtyFiles.Count

        Write-Host "  • $displayName " -NoNewline -ForegroundColor White
        Write-Host $badge -NoNewline -ForegroundColor $badgeColor
        Write-Host " (branch: $($branch ?? 'HEAD'))" -ForegroundColor Cyan
        
        if ($dirtyCount -eq 0) {
            Write-Host "    Status: " -NoNewline
            Write-Host "✓ clean" -ForegroundColor Green
        } else {
            Write-Host "    Status: " -NoNewline
            Write-Host "● $dirtyCount uncommitted file(s)" -ForegroundColor Yellow
        }
        Write-Host "    Latest: $commitMsg ($timeAgo)" -ForegroundColor DarkGray
        Write-Host "    Path:   $path`n" -ForegroundColor DarkGray
    }

    foreach ($line in $porcelain) {
        if ($line -match '^worktree\s+(.*)') {
            Print-WorktreeItem $currentWt $currentBranch $currentHead $mainRepoRoot
            $currentWt = $matches[1]
            $currentHead = $null
            $currentBranch = $null
        } elseif ($line -match '^HEAD\s+(.*)') {
            $currentHead = $matches[1].Substring(0, [Math]::Min(7, $matches[1].Length))
        } elseif ($line -match '^branch\s+refs/heads/(.*)') {
            $currentBranch = $matches[1]
        } elseif ($line -eq 'detached') {
            $currentBranch = '(detached HEAD)'
        }
    }
    Print-WorktreeItem $currentWt $currentBranch $currentHead $mainRepoRoot

    Write-Host "Next Actions:" -ForegroundColor White
    Write-Host "  omp-wt <name>          " -NoNewline -ForegroundColor Cyan
    Write-Host "Launch OMP in that worktree"
    Write-Host "  omp-wt -Remove <name>  " -NoNewline -ForegroundColor Yellow
    Write-Host "Delete worktree and its branch"
    Write-Host "  git merge <branch>     " -NoNewline -ForegroundColor Green
    Write-Host "Merge changes into your current branch`n"
    return
}

# Prune worktrees
if ($Prune) {
    Write-Host "Pruning stale worktrees..." -ForegroundColor Cyan
    git worktree prune -v
    return
}

# Remove worktree
if ($Remove) {
    $targetPath = Join-Path $mainRepoRoot ".worktrees\$Remove"
    if (-not (Test-Path $targetPath)) {
        # Check active list
        $porcelain = git worktree list --porcelain
        foreach ($line in $porcelain) {
            if ($line -match '^worktree\s+(.*)' -and ($matches[1] -like "*\$Remove" -or $matches[1] -like "*/$Remove")) {
                $targetPath = $matches[1]
                break
            }
        }
    }

    if (-not (Test-Path $targetPath)) {
        Write-Error "Worktree '$Remove' not found."
        return
    }

    Write-Host "Removing worktree: $targetPath" -ForegroundColor Yellow
    git worktree remove $targetPath 2>$null
    if ($LASTEXITCODE -ne 0) {
        $confirm = Read-Host "Standard remove failed. Force remove? [y/N]"
        if ($confirm -match "^[yY]$") {
            git worktree remove --force $targetPath
            Write-Host "✓ Worktree force-removed." -ForegroundColor Green
        } else {
            Write-Host "Aborted."
            return
        }
    } else {
        Write-Host "✓ Worktree removed." -ForegroundColor Green
    }

    $branchCheck = git show-ref --verify --quiet "refs/heads/$Remove"
    if ($LASTEXITCODE -eq 0) {
        $delBranch = Read-Host "Delete branch '$Remove' too? [y/N]"
        if ($delBranch -match "^[yY]$") {
            git branch -D $Remove
            Write-Host "✓ Branch '$Remove' deleted." -ForegroundColor Green
        }
    }
    return
}

# Interactive mode if name not provided
if (-not $Name) {
    $currBranch = (git branch --show-current 2>$null).Trim()
    if (-not $currBranch) { $currBranch = "HEAD" }

    Write-Host "=== OMP Git Worktree Launcher ===" -ForegroundColor Cyan
    Write-Host "Repository:     $mainRepoRoot ($repoName)" -ForegroundColor DarkGray
    Write-Host "Current branch: $currBranch" -ForegroundColor Yellow
    Write-Host "(Type 'omp-wt -Guide' anytime for a guide to worktrees)`n" -ForegroundColor DarkGray

    $activeCount = @(git worktree list).Count
    if ($activeCount -gt 1) {
        Write-Host "Active worktrees:" -ForegroundColor White
        git worktree list
        Write-Host ""
    }

    while (-not $Name) {
        $Name = Read-Host "Enter worktree/branch name (e.g. fix-auth, test-speed)"
        if ($Name) { $Name = $Name.Trim() }
    }

    if (-not $BaseRef) { $BaseRef = Get-DefaultBranch }

# Resolve Worktree Path
$isSibling = $Sibling -or ($env:OMP_WT_MODE -eq "sibling")
if ($isSibling) {
    $parentDir = Split-Path -Parent $mainRepoRoot
    $wtPath = Join-Path $parentDir "$repoName-$Name"
} else {
    $wtPath = Join-Path $mainRepoRoot ".worktrees\$Name"
}

# Auto-exclude .worktrees if nested
if (-not $isSibling) {
    $excludeFile = Join-Path $commonGitDir "info\exclude"
    $excludeDir = Split-Path -Parent $excludeFile
    if (-not (Test-Path $excludeDir)) { New-Item -ItemType Directory -Path $excludeDir -Force | Out-Null }
    if (Test-Path $excludeFile) {
        $content = Get-Content $excludeFile -Raw 2>$null
        if ($content -notmatch "\.worktrees") { Add-Content $excludeFile ".worktrees/" }
    } else {
        Set-Content $excludeFile ".worktrees/"
    }
}

# Create worktree if not exists
if (Test-Path $wtPath) {
    Write-Host "→ Opening existing worktree: $wtPath" -ForegroundColor Cyan
} else {
    Write-Host "→ Creating worktree: $Name" -ForegroundColor Cyan
    Write-Host "  Location: $wtPath" -ForegroundColor DarkGray

    $parentTarget = Split-Path -Parent $wtPath
    if (-not (Test-Path $parentTarget)) { New-Item -ItemType Directory -Path $parentTarget -Force | Out-Null }

    git show-ref --verify --quiet "refs/heads/$Name"
    $branchExists = ($LASTEXITCODE -eq 0)

    if ($branchExists) {
        Write-Host "  Branch '$Name' already exists, checking it out..." -ForegroundColor DarkGray
        git worktree add $wtPath $Name
    } else {
        if (-not $BaseRef) { $BaseRef = "HEAD" }
        if (-not $Yes) {
            $confirm = Read-Host "Create new worktree and branch '$Name' from $BaseRef? [Y/n]"
            if ($confirm -and $confirm -notmatch "^[yY]$") {
                Write-Host "Aborted." -ForegroundColor DarkGray
                return
            }
        }
        Write-Host "  Creating new branch '$Name' from $BaseRef..." -ForegroundColor DarkGray
        git worktree add -b $Name $wtPath $BaseRef
    }
    Write-Host "✓ Worktree ready!`n" -ForegroundColor Green

    # Untracked config detection (Android, iOS, Web, Python)
    $patterns = @(
        ".env", ".env.local", ".env.development", ".env.development.local",
        ".env.production", ".env.production.local", ".env.test",
        ".npmrc", ".yarnrc", ".yarnrc.yml",
        "local.properties", "android\local.properties",
        "*.keystore", "*.jks", "android\*.keystore", "android\*.jks",
        "android\app\*.keystore", "android\app\*.jks",
        "google-services.json", "android\app\google-services.json",
        "android\secrets.properties", "secrets.properties",
        "GoogleService-Info.plist", "ios\GoogleService-Info.plist", "ios\Runner\GoogleService-Info.plist",
        "secrets.yaml", "secrets.json", "config.local.json", "local_settings.py"
    )

    $foundConfigs = [System.Collections.Generic.List[string]]::new()
    foreach ($pat in $patterns) {
        $items = Get-ChildItem -Path (Join-Path $mainRepoRoot $pat) -File -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            $rel = $item.FullName.Substring($mainRepoRoot.Length).TrimStart('\', '/')
            $destFile = Join-Path $wtPath $rel
            if (-not (Test-Path $destFile) -and -not $foundConfigs.Contains($rel)) {
                $foundConfigs.Add($rel)
            }
        }
    }

    if ($foundConfigs.Count -gt 0) {
        Write-Host "Notice: Local configuration files detected in main repository:" -ForegroundColor Yellow
        foreach ($cf in $foundConfigs) {
            Write-Host "  • $cf" -ForegroundColor DarkGray
        }
        Write-Host "(These files are ignored by Git and not automatically in the worktree)" -ForegroundColor DarkGray

        $doCopy = $false
        if ($CopyEnv) {
            $doCopy = $true
        } elseif (-not $NoCopyEnv) {
            $reply = Read-Host "Copy these files to the new worktree? [Y/n]"
            if (-not $reply -or $reply -match "^[yY]$") {
                $doCopy = $true
            }
        }

        if ($doCopy) {
            foreach ($cf in $foundConfigs) {
                $src = Join-Path $mainRepoRoot $cf
                $dst = Join-Path $wtPath $cf
                $dstDir = Split-Path -Parent $dst
                if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
                Copy-Item -Path $src -Destination $dst -Force
            }
            Write-Host "✓ Copied $($foundConfigs.Count) config file(s) to worktree.`n" -ForegroundColor Green
        }
    }
}

# Launch OMP
Write-Host "Launching OMP in: $wtPath`n" -ForegroundColor Green
Push-Location $wtPath
try {
    omp
} finally {
    Pop-Location
}
