# SUBCOMMAND: done
cmd_done() {
  need_cmd git-town

  local current_branch main_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  main_branch=$(default_base_branch)

  [[ "$current_branch" == "$main_branch" ]] \
    && die "Already on '${main_branch}'. Run from a feature branch."

  # Sync first so git-town learns the remote state (the PR branch may already
  # be deleted on remote after merge; git town delete fails without this).
  info "Syncing '${current_branch}'..."
  git town sync --gone 2>/dev/null || git town sync || true

  # Refresh remote state and verify the branch is merged
  git fetch --quiet origin "$main_branch" 2>/dev/null || true
  if ! git merge-base --is-ancestor HEAD "origin/${main_branch}" 2>/dev/null; then
    die "Branch '${current_branch}' is not merged into ${main_branch}. Merge the PR first."
  fi

  # git town sync may have already switched us to main after detecting the
  # remote branch is gone; only delete explicitly if still on the feature branch.
  if [[ "$(git rev-parse --abbrev-ref HEAD)" == "$current_branch" ]]; then
    git town delete
  fi

  # Ensure we land on main and pull the latest.
  git checkout --quiet "$main_branch" 2>/dev/null || true
  info "Syncing ${main_branch}..."
  git town sync
}
