# menu_multiselect <header> <value:::display> ...
# Present the given items for multi-selection and print the chosen values (the
# part before ':::'), one per line. Uses fzf when available, else a numbered
# checklist. Empty selection prints nothing.
menu_multiselect() {
  local header="$1"; shift
  local -a vals=() disps=()
  local pair
  for pair in "$@"; do
    vals+=("${pair%%:::*}")
    disps+=("${pair#*:::}")
  done

  local i
  if fzf_available; then
    local -a lines=()
    for (( i=1; i<=${#vals[@]}; i++ )); do
      lines+=("$(printf '%-16s %s' "${vals[$i]}" "${disps[$i]}")")
    done
    local chosen
    chosen="$(printf '%s\n' "${lines[@]}" \
      | fzf --multi --height=60% --reverse --border \
            --prompt="${header} > " --pointer="▶" --marker="✓" \
            --header="TAB=toggle  ENTER=confirm  (Esc = none)")" || true
    local -a sel=(${(f)chosen})
    print -rl -- "${sel[@]%% *}"
  else
    print -r -- "${header}:" >&2
    for (( i=1; i<=${#vals[@]}; i++ )); do
      printf '  %d) %-16s %s\n' "$i" "${vals[$i]}" "${disps[$i]}" >&2
    done
    local choice
    choice="$(prompt_choice "Numbers (space-separated, or 'all', blank to skip):" "")"
    [[ -n "$choice" ]] || return 0
    if [[ "$choice" == "all" ]]; then
      print -rl -- "${vals[@]}"
    else
      local num
      for num in ${(z)choice}; do
        [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#vals[@]} )) \
          && print -r -- "${vals[$num]}"
      done
    fi
  fi
}

# SUBCOMMAND: init — interactive setup: git aliases + prompt-override files.
# Writes to the current repo by default (.git/config, .git/hack); --global
# targets ~/.gitconfig and ~/.config/git-hack instead.
cmd_init() {
  local scope=local
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --global) scope=global; shift ;;
      --local)  scope=local;  shift ;;
      *) die "Unknown option: $1" ;;
    esac
  done

  # Local scope writes into the current repo, so it needs one.
  if [[ "$scope" == local ]]; then
    in_git_repo || die "Not in a git repository. Run inside a repo, or use --global."
  fi

  info "git-hack setup (${scope})"
  if [[ "$scope" == local ]]; then
    print -r -- "Writing to this repo (.git/config, .git/hack). Use --global for ~/.gitconfig + ~/.config." >&2
  else
    print -r -- "Writing globally (~/.gitconfig, ~/.config/git-hack)." >&2
  fi

  local -a gitcfg=(git config)
  [[ "$scope" == global ]] && gitcfg+=(--global) || gitcfg+=(--local)

  # ---- page 1: aliases ----
  print -r -- "" >&2
  local -a alias_names=(cp          pr             propose        pick)
  local -a alias_cmds=( checkpoint  propose        propose        pick)
  local -a alias_descs=(
    "git-hack checkpoint"
    "git-hack propose (short)"
    "git-hack propose"
    "git-hack pick"
  )
  local -a apairs=() i
  for (( i=1; i<=${#alias_names[@]}; i++ )); do
    local tag=""
    [[ -n "$("${gitcfg[@]}" --get "alias.${alias_names[$i]}" 2>/dev/null)" ]] && tag="  ✓"
    apairs+=("${alias_names[$i]}:::${alias_descs[$i]}${tag}")
  done
  local -a chosen_aliases=(${(f)"$(menu_multiselect 'Aliases' "${apairs[@]}")"})

  local name
  for name in "${chosen_aliases[@]}"; do
    [[ -n "$name" ]] || continue
    local cmd=""
    for (( i=1; i<=${#alias_names[@]}; i++ )); do
      [[ "${alias_names[$i]}" == "$name" ]] && { cmd="${alias_cmds[$i]}"; break; }
    done
    [[ -n "$cmd" ]] || continue
    local existing
    existing="$("${gitcfg[@]}" --get "alias.${name}" 2>/dev/null || true)"
    if [[ -n "$existing" && "$existing" != "!git-hack ${cmd}" ]]; then
      print -r -- "  ⚠ git ${name} is already '${existing}'" >&2
      confirm "  Overwrite with 'git-hack ${cmd}'?" "n" || { info "kept git ${name}"; continue; }
    fi
    "${gitcfg[@]}" "alias.${name}" "!git-hack ${cmd}"
    ok "git ${name}  →  git-hack ${cmd}"
  done
  [[ ${#chosen_aliases[@]} -gt 0 ]] || info "No aliases selected."

  # ---- page 2: prompt overrides ----
  print -r -- "" >&2
  local dir
  dir="$(prompt_dir "$scope")"
  local -a ppairs=() key
  for key in "${PROMPT_KEYS[@]}"; do
    local tag="editable override"
    [[ -s "$dir/${key}.md" ]] && tag="already present"
    ppairs+=("${key}:::${tag}")
  done
  local -a chosen_prompts=(${(f)"$(menu_multiselect 'Prompts' "${ppairs[@]}")"})

  if [[ ${#chosen_prompts[@]} -gt 0 ]]; then
    mkdir -p "$dir"
    for key in "${chosen_prompts[@]}"; do
      [[ -n "$key" ]] || continue
      if [[ -s "$dir/${key}.md" ]]; then
        info "exists, skipped: ${key}.md"
        continue
      fi
      # Write to a temp file first so a failed generation never leaves a
      # truncated/empty ${key}.md behind.
      local tmp
      tmp="$(mktemp "${dir}/.${key}.XXXXXX")"
      if default_prompt "$key" > "$tmp"; then
        mv "$tmp" "$dir/${key}.md"
        ok "wrote ${key}.md"
      else
        rm -f "$tmp"
        info "failed to generate ${key}.md"
      fi
    done
  else
    info "No prompts selected."
  fi

  print -r -- "" >&2
  ok "Setup complete (${scope})."
}
