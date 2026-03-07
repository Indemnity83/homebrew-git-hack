# SUBCOMMAND: idea
cmd_idea() {
  need_cmd llm
  need_cmd git-town

  local idea="${1:-}"

  if [[ -z "$idea" ]]; then
    idea="$(prompt_choice "What are you planning to do? (short description)" "")"
    [[ -n "$idea" ]] || die "No idea provided."
  fi

  local branch
  branch="$(printf 'Idea: %s\nRepo: %s' "$idea" "$(basename "$(repo_root)")" \
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
