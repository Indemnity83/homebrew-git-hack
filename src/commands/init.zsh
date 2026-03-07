# SUBCOMMAND: init — install global git aliases for git-hack commands
cmd_init() {
  # Parallel arrays: alias name, git-hack subcommand, description
  local -a alias_names=(record  rap               pr        propose   pick          done                 )
  local -a alias_cmds=( record  "record -a -p"    propose   propose   pick          done                 )
  local -a alias_descs=(
    "AI-generated commit message"
    "Stage all, AI-commit, and push"
    "Create or update a GitHub PR"
    "Create or update a GitHub PR"
    "Cherry-pick a commit"
    "Delete merged branch and sync main"
  )

  info "git-hack alias installer"
  print -r -- "Installs shortcuts in your global ~/.gitconfig" >&2
  print -r -- "e.g. 'git snap'  instead of  'git hack snapshot'" >&2
  print -r -- "" >&2

  local -a selected_names=()

  if fzf_available; then
    # Build display lines: "snap        AI-generated commit message  [installed]"
    local -a menu_lines=()
    local i
    for (( i=1; i<=${#alias_names[@]}; i++ )); do
      local existing
      existing="$(git config --global "alias.${alias_names[$i]}" 2>/dev/null || true)"
      local tag=""
      [[ -n "$existing" ]] && tag="  ✓ installed"
      menu_lines+=("$(printf '%-10s  %s%s' "${alias_names[$i]}" "${alias_descs[$i]}" "$tag")")
    done

    local chosen
    chosen="$(printf '%s\n' "${menu_lines[@]}" \
      | fzf --multi --height=60% --reverse --border \
            --prompt="Aliases > " --pointer="▶" --marker="✓" \
            --header="TAB=toggle  ENTER=confirm")" || true

    # Extract alias name (first word) from each selected line
    selected_names=(${(f)chosen})
    selected_names=("${selected_names[@]%% *}")
  else
    # Numbered checklist
    local i
    for (( i=1; i<=${#alias_names[@]}; i++ )); do
      local existing
      existing="$(git config --global "alias.${alias_names[$i]}" 2>/dev/null || true)"
      local tag=""
      [[ -n "$existing" ]] && tag="  [installed]"
      printf '  %d) git %-10s %s%s\n' "$i" "${alias_names[$i]}" "${alias_descs[$i]}" "$tag" >&2
    done
    print -r -- "" >&2

    local choice
    choice="$(prompt_choice "Numbers to install (space-separated, or 'all'):" "all")"
    [[ -n "$choice" ]] || { info "No aliases selected."; return; }

    if [[ "$choice" == "all" ]]; then
      selected_names=("${alias_names[@]}")
    else
      local num
      for num in ${(z)choice}; do
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#alias_names[@]} )); then
          selected_names+=("${alias_names[$num]}")
        fi
      done
    fi
  fi

  [[ ${#selected_names[@]} -gt 0 ]] || { info "No aliases selected."; return; }

  print -r -- "" >&2
  local name i
  for name in "${selected_names[@]}"; do
    [[ -n "$name" ]] || continue
    local cmd=""
    for (( i=1; i<=${#alias_names[@]}; i++ )); do
      if [[ "${alias_names[$i]}" == "$name" ]]; then
        cmd="${alias_cmds[$i]}"
        break
      fi
    done
    [[ -n "$cmd" ]] || continue
    git config --global "alias.${name}" "!git-hack ${cmd}"
    ok "git ${name}  →  git-hack ${cmd}"
  done

  print -r -- "" >&2
  ok "Done! Run 'git config --global --list | grep ^alias' to review."
}
