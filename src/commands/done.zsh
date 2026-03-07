# SUBCOMMAND: done
cmd_done() {
  need_cmd git-town

  local current_branch main_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  main_branch=$(default_base_branch)

  [[ "$current_branch" == "$main_branch" ]] \
    && die "Already on '${main_branch}'. Run from a feature branch."

  # Fetch with --prune so stale remote tracking refs (e.g. the deleted PR
  # branch) are removed. This lets git town delete know the remote is gone
  # and prevents it from trying to delete a branch that no longer exists.
  git fetch --prune --quiet origin 2>/dev/null || true
  if ! git merge-base --is-ancestor HEAD "origin/${main_branch}" 2>/dev/null; then
    die "Branch '${current_branch}' is not merged into ${main_branch}. Merge the PR first."
  fi

  info "Deleting '${current_branch}' and syncing ${main_branch}..."
  git town delete
  git checkout --quiet "$main_branch"
  git town sync
}
