<#
push-all.ps1

Usage:
  .\push-all.ps1
  .\push-all.ps1 -RepoPath "C:\Users\aaron\Desktop\CardCollectables" -RemoteUrl "https://github.com/USER/REPO.git" -CommitMessage "Update site" -Force

Notes:
  - This script will stage all changes, create a commit (if there are changes), ensure branch is named `main`,
    optionally set/override the remote, then push (optionally forced).
  - It does NOT embed tokens. For HTTPS pushes provide a PAT when prompted or configure Git Credential Manager.
#>

param(
  [string]$RepoPath = "C:\Users\aaron\Desktop\CardCollectables",
  [string]$RemoteUrl = "",
  [string]$CommitMessage = "Update site",
  [switch]$Force
)

Set-StrictMode -Version Latest

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "git is not installed or not in PATH."
  exit 1
}

if (-not (Test-Path $RepoPath)) {
  Write-Error "Repo path '$RepoPath' not found."
  exit 1
}

Push-Location $RepoPath
try {
  Write-Host "Working in: $RepoPath"

  # Show current branch (if any)
  $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
  if (-not $currentBranch) { $currentBranch = "main" }

  # Stage and commit changes (if any)
  $status = git status --porcelain
  if ($status) {
    Write-Host "Staging all changes..."
    git add -A

    if (-not $CommitMessage) {
      $CommitMessage = Read-Host "Enter commit message (leave empty to skip commit)"
    }

    if ($CommitMessage) {
      Write-Host "Committing: $CommitMessage"
      git commit -m $CommitMessage
    } else {
      Write-Host "No commit message provided; skipping commit."
    }
  } else {
    Write-Host "No changes to commit."
  }

  # Ensure branch is main
  Write-Host "Ensuring branch named 'main'..."
  git branch -M main

  # Configure remote if provided
  if ($RemoteUrl) {
    $remotes = git remote
    if ($remotes -contains "origin") {
      Write-Host "Setting origin URL to: $RemoteUrl"
      git remote set-url origin $RemoteUrl
    } else {
      Write-Host "Adding origin remote: $RemoteUrl"
      git remote add origin $RemoteUrl
    }
  } else {
    Write-Host "Using existing 'origin' remote (if present)."
  }

  # Push
  Write-Host "Pushing to remote (this may prompt for credentials)..."
  if ($Force.IsPresent) {
    git push origin main:main --force -u
  } else {
    git push origin main:main -u
  }

  # Fetch and list files on origin/main
  Write-Host "Fetching origin/main and listing files..."
  git fetch origin main
  git ls-tree -r origin/main --name-only

  # Show latest commit on origin/main
  Write-Host "Latest commit on origin/main:"
  git log origin/main -1 --pretty=oneline
}
catch {
  Write-Error "An error occurred: $_"
  exit 1
}
finally {
  Pop-Location
}
