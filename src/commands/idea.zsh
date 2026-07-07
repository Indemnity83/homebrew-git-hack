# SUBCOMMAND: idea
cmd_idea() {
  need_cmd llm
  need_cmd git-town

  local auto_yes=0 model=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)   auto_yes=1; shift ;;
      --model) model="$2"; shift 2 ;;
      -m)      model="$2"; shift 2 ;;
      --) shift; break ;;
      -*)
        local flags="${1:1}"; shift
        for (( i=1; i<=${#flags}; i++ )); do
          case "${flags[i]}" in
            y) auto_yes=1 ;;
            m) die "-m requires an argument; use -m <model> as a standalone flag" ;;
            *) die "Unknown option: -${flags[i]}" ;;
          esac
        done
        ;;
      *) break ;;
    esac
  done

  local idea="${1:-}"

  if [[ -z "$idea" ]]; then
    idea="$(prompt_choice "What are you planning to do? (short description)" "")"
    [[ -n "$idea" ]] || die "No idea provided."
  fi

  local context
  context="$(printf 'Idea: %s\nRepo: %s' "$idea" "$(basename "$(repo_root)")")"
  local raw
  raw="$(gen_text branch "$context" "$model")" \
    || die "llm invocation failed. Check 'llm models' and your API key/config."
  local branch
  branch="$(sanitize_branch_name "$(first_line_trimmed "$raw")")"
  [[ -n "$branch" ]] || die "Model returned an empty branch name."

  info "Proposed branch: $branch"
  if [[ $auto_yes -eq 0 ]] && ! confirm "Create and switch to '$branch'?"; then
    local manual
    manual="$(prompt_choice "Enter the branch name you want to use:" "$branch")"
    branch="$(sanitize_branch_name "$manual")"
    [[ -n "$branch" ]] || die "Empty branch name."
  fi

  local town_cmd
  town_cmd="$(resolve_hack_base "$auto_yes")"
  git town "$town_cmd" "$branch"
  ok "Now on branch: $(current_branch)"
}
