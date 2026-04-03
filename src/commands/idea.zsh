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

  local llm_args=()
  [[ -n "$model" ]] && llm_args=(-m "$model")

  local branch
  branch="$(printf 'Idea: %s\nRepo: %s' "$idea" "$(basename "$(repo_root)")" \
    | llm "${llm_args[@]}" -s $'You are a Git workflow assistant.

Task:
Generate ONE git branch name for the user\'s idea.

Branch naming rules:
- Output ONLY the branch name (no explanation or punctuation)
- Lowercase only
- Use kebab-case
- Words separated by "-"
- Optional category prefix followed by "/"

Preferred prefixes:
- feat/  (new feature)
- fix/   (bug fix)
- chore/ (maintenance or tooling)
- refactor/
- docs/
- test/

Additional constraints:
- No spaces
- No quotes
- No backticks
- Max length: 60 characters
- Descriptive but concise
- Avoid filler words like "the", "a", "stuff", "things"

Good examples:
- feat/add-meter-billing-ui
- fix/authentik-oauth-profile-claim
- chore/update-docker-compose
- refactor/simplify-energy-buffer-logic

Return ONLY the branch name.')"
  branch="$(print -r -- "$branch" | head -n 1 | tr -d '\r')"
  branch="$(sanitize_branch_name "$branch")"
  [[ -n "$branch" ]] || die "Model returned an empty branch name."

  info "Proposed branch: $branch"
  if [[ $auto_yes -eq 0 ]] && ! confirm "Create and switch to '$branch'?"; then
    local manual
    manual="$(prompt_choice "Enter the branch name you want to use:" "$branch")"
    branch="$(sanitize_branch_name "$manual")"
    [[ -n "$branch" ]] || die "Empty branch name."
  fi

  local town_cmd
  town_cmd="$(resolve_hack_base)"
  git town "$town_cmd" "$branch"
  ok "Now on branch: $(current_branch)"
}
