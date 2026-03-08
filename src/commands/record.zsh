# SUBCOMMAND: record
cmd_record() {
  need_cmd llm

  local conventional=0 stage_all=0 push=0 auto_yes=0 amend=0 model=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)          stage_all=1; shift ;;
      --conventional) conventional=1; shift ;;
      --push)         push=1; shift ;;
      --yes)          auto_yes=1; shift ;;
      --amend)        amend=1; shift ;;
      --model)        model="$2"; shift 2 ;;
      -m)             model="$2"; shift 2 ;;
      --)             shift; break ;;
      -*)
        local flags="${1:1}"; shift
        for (( i=1; i<=${#flags}; i++ )); do
          case "${flags[i]}" in
            a) stage_all=1 ;;
            A) amend=1 ;;
            c) conventional=1 ;;
            p) push=1 ;;
            y) auto_yes=1 ;;
            m) die "-m requires an argument; use -m <model> as a standalone flag" ;;
            *) die "Unknown option: -${flags[i]}" ;;
          esac
        done
        ;;
      *) die "Unknown option: $1" ;;
    esac
  done

  [[ $stage_all -eq 1 ]] && git add -A

  has_staged_changes || {
    info "No staged changes."
    if confirm "Run 'git add -p' now?"; then
      git add -p
    fi
  }

  has_staged_changes || die "Still no staged changes. Stage changes and try again."

  local diff_trunc
  diff_trunc="$(truncate_str "$(git diff --cached)" "$MAX_CHARS_DIFF_COMMIT")"

  local system_prompt
  if [[ $conventional -eq 1 ]]; then
    system_prompt=$'You are a meticulous Git commit assistant.

Task:
Generate ONE single-line Conventional Commit subject for the staged changes.

Rules:
- Output ONLY the subject line
- No explanation
- No quotes
- No backticks
- No markdown
- Format: type: description
- Use imperative mood
- Keep it specific and concise
- Target length: 72 characters or less
- Choose the most appropriate type based on the diff

Allowed types:
- feat
- fix
- refactor
- docs
- test
- chore
- ci
- build
- perf

Guidance:
- Do NOT use scopes
- Describe the change, not the intent or process
- Prefer strong verbs like Add, Fix, Update, Remove, Refactor, Simplify
- Avoid vague subjects like "Update code" or "Fix issues"

Good examples:
- feat: add print button to report view
- fix: handle missing oauth profile claim
- refactor: simplify heat buffer logic
- docs: clarify release workflow

Return ONLY the subject line.'
  else
    system_prompt=$'You are a meticulous Git commit assistant.

Task:
Generate ONE single-line commit subject for the staged changes.

Rules:
- Output ONLY the subject line
- No explanation
- No quotes
- No backticks
- No markdown
- No conventional commit prefix
- No scope
- No body
- Use imperative mood
- Keep it specific and concise
- Target length: 72 characters or less

Guidance:
- Describe what changed in the staged diff
- Prefer strong verbs like Add, Fix, Update, Remove, Refactor, Simplify
- Avoid vague subjects like "Update code" or "Fix issues"
- Focus on the most important user-visible or developer-visible change

Good examples:
- Add print button to report view
- Fix oauth profile claim handling
- Simplify heat buffer logic
- Update release workflow documentation

Return ONLY the subject line.'
  fi

  local llm_args=()
  [[ -n "$model" ]] && llm_args=(-m "$model")

  local msg
  msg="$(printf 'Repo: %s\nBranch: %s\n\nSTAGED DIFF:\n%s' \
    "$(basename "$(repo_root)")" "$(current_branch)" "$diff_trunc" \
    | llm "${llm_args[@]}" -s "$system_prompt")"
  msg="$(print -r -- "$msg" | head -n 1 | tr -d '\r' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
  [[ -n "$msg" ]] || die "Empty commit message from model."

  info "Proposed commit message:"
  print -r -- "  $msg" >&2
  print -r -- "" >&2

  local amend_flag=() push_flag=()
  [[ $amend -eq 1 ]] && amend_flag=(--amend)
  [[ $amend -eq 1 ]] && push_flag=(--force-with-lease)

  _do_commit() {
    local subject="$1"
    git commit "${amend_flag[@]}" -m "$subject"
    [[ $amend -eq 1 ]] && ok "Amended." || ok "Committed."
    if [[ $push -eq 1 ]]; then
      if git push "${push_flag[@]}"; then ok "Pushed."; else info "Push failed. You can push manually later."; fi
    fi
  }

  if [[ $auto_yes -eq 1 ]]; then
    _do_commit "$msg"
  else
    print -r -- "Options: (y) commit, (e) edit, (n) cancel" >&2
    local choice
    choice="$(prompt_choice "Choose y/e/n:" "y")"

    case "$choice" in
      y|Y) _do_commit "$msg" ;;
      e|E)
        local manual
        manual="$(prompt_choice "Enter commit subject:" "$msg")"
        manual="$(print -r -- "$manual" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
        [[ -n "$manual" ]] || die "Empty message."
        _do_commit "$manual"
        ;;
      n|N) die "Cancelled." ;;
      *) die "Invalid choice." ;;
    esac
  fi

  unfunction _do_commit
}
