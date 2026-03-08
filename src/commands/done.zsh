# SUBCOMMAND: done
cmd_done() {
  need_cmd git-town

  local current_branch main_branch
  current_branch=$(current_branch)
  main_branch=$(default_base_branch)

  [[ "$current_branch" == "$main_branch" ]] \
    && die "Already on '${main_branch}'. Run from a feature branch."

  # Sync fetches with --prune (removes stale remote tracking refs for deleted
  # branches) and updates main. git town delete then acts as the merge guard —
  # it fails if the branch has not been merged, which aborts the script via
  # set -e. No second sync needed; git town sync already updated main.
  git town sync
  git town delete
  git checkout --quiet "$main_branch"
}
