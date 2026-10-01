#!/usr/bin/env bash
# Apply the standard settings to a GitHub repository. Idempotent: safe to re-run,
# works on existing repositories too.
#
#   scripts/setup-repo.sh [owner/repo]       (default: the repo of the current directory)
#   CHECK='name' scripts/setup-repo.sh ...   required status check (default: ci / ci-ok)
#
# Needs: gh (logged in, admin rights on the repo). Steps a plan doesn't support
# (e.g. branch protection on private repos of a free account) are reported as skipped.
set -uo pipefail

CHECK=${CHECK:-ci / ci-ok}
repo=${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}
branch=$(gh repo view "$repo" --json defaultBranchRef -q .defaultBranchRef.name)
echo "==> $repo (default branch: $branch)"

step() { # step "<title>" <command...>
  local title=$1; shift
  if "$@" >/dev/null 2>&1; then echo "  ok       $title"; else echo "  skipped  $title"; fi
}

step "merge: squash only, auto-merge, delete branch on merge" \
  gh repo edit "$repo" --enable-squash-merge --enable-merge-commit=false \
    --enable-rebase-merge=false --enable-auto-merge --delete-branch-on-merge
step "Dependabot alerts" gh api -X PUT "repos/$repo/vulnerability-alerts"
step "Dependabot security updates" gh api -X PUT "repos/$repo/automated-security-fixes"
step "secret scanning + push protection" gh api -X PATCH "repos/$repo" \
  -f 'security_and_analysis[secret_scanning][status]=enabled' \
  -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'
step "Actions: read-only default GITHUB_TOKEN" gh api -X PUT "repos/$repo/actions/permissions/workflow" \
  -f default_workflow_permissions=read -F can_approve_pull_request_reviews=false

protect() {
  gh api -X PUT "repos/$repo/branches/$branch/protection" --input - <<JSON
{
  "required_status_checks": { "strict": false, "contexts": ["$CHECK"] },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
}
step "branch protection on $branch: required check '$CHECK', linear history" protect
