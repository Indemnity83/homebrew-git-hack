# SUBCOMMAND: issue
cmd_issue() {
  need_cmd gh
  need_cmd llm
  need_cmd git-town
  gh auth status >/dev/null 2>&1 || die "GitHub CLI not authenticated. Run: gh auth login"

  local issue_number="${1:-}"
  [[ -n "$issue_number" ]] || die "Usage: hack issue <number>"

  local issue_title issue_body
  issue_title="$(gh issue view "$issue_number" --json title --jq '.title')" \
    || die "Failed to fetch issue #$issue_number"
  issue_body="$(gh issue view "$issue_number" --json body --jq '.body // ""')"

  [[ -n "$issue_title" ]] || die "Issue #$issue_number returned no title."
  info "Issue #$issue_number: $issue_title"

  local idea
  idea="$(printf '%s\n\n%s' "$issue_title" "$issue_body")"
  idea="$(truncate_str "$idea" 1500)"

  local branch
  branch="$(printf 'GitHub issue #%s: %s\n\n%s\n\nRepo: %s' \
    "$issue_number" "$issue_title" "$idea" "$(basename "$(repo_root)")" \
    | llm -s 'Propose ONE kebab-case git branch name, 60 chars max. Output only the name.')"
  branch="$(print -r -- "$branch" | head -n 1 | tr -d '\r')"
  branch="$(sanitize_branch_name "$branch")"
  [[ -n "$branch" ]] || die "Model returned an empty branch name."

  info "Proposed branch: $branch"
  if ! confirm "Create and switch to '$branch'?"; then
    local manual
    manual="$(prompt_choice "Enter the branch name you want to use:" "$branch")"
    branch="$(sanitize_branch_name "$manual")"
    [[ -n "$branch" ]] || die "Empty branch name."
  fi

  git town hack "$branch"
  ok "Now on branch: $(current_branch)"
}
