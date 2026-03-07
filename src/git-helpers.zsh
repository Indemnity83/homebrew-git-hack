fzf_available() {
  command -v fzf >/dev/null 2>&1
}

select_with_fzf() {
  # usage: select_with_fzf "prompt" [--preview "preview command with {}"]
  local prompt="$1"
  shift

  local preview_cmd=""
  if [[ "${1:-}" == "--preview" ]]; then
    preview_cmd="$2"
    shift 2
  fi

  local fzf_opts=(
    --height=40%
    --reverse
    --border
    --prompt="$prompt > "
    --pointer="▶"
    --marker="✓"
  )

  if [[ -n "$preview_cmd" ]]; then
    fzf_opts+=(--preview "$preview_cmd" --preview-window=right:60%:wrap)
  fi

  fzf "${fzf_opts[@]}"
}

default_base_branch() {
  local base

  # git-town.main-branch config takes priority
  base="$(git config git-town.main-branch 2>/dev/null || true)"
  if [[ -n "$base" ]]; then
    print -r -- "$base"
    return
  fi

  # Check origin/HEAD symref
  local ref
  ref="$(git symbolic-ref -q refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [[ -n "$ref" ]]; then
    print -r -- "${ref#refs/remotes/origin/}"
    return
  fi

  # Check for existing branches
  if git show-ref --verify --quiet refs/heads/main; then print -r -- "main"; return; fi
  if git show-ref --verify --quiet refs/heads/master; then print -r -- "master"; return; fi
  print -r -- "main"
}
