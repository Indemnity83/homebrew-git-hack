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

is_perennial_branch() {
  local branch="$1"
  local perennials
  perennials="$(git config git-town.perennial-branches 2>/dev/null || true)"
  local b
  for b in ${(z)perennials}; do
    [[ "$b" == "$branch" ]] && return 0
  done
  local perennial_regex
  perennial_regex="$(git config git-town.perennial-regex 2>/dev/null || true)"
  if [[ -n "$perennial_regex" ]] && [[ "$branch" =~ $perennial_regex ]]; then
    return 0
  fi
  return 1
}

# resolve_hack_base: prints "hack" or "append"
# "hack"   → git town hack  (branches from main)
# "append" → git town append (branches from current branch)
resolve_hack_base() {
  local auto_yes="${1:-0}"
  local cur default
  cur="$(current_branch)"
  default="$(default_base_branch)"

  # Already on the default branch — no ambiguity
  [[ "$cur" == "$default" ]] && { print -r -- "hack"; return; }

  # On a perennial branch — silently use it as parent
  if is_perennial_branch "$cur"; then
    info "Branching from perennial '$cur'"
    print -r -- "append"
    return
  fi

  # Non-interactive: default to branching from main
  if [[ "$auto_yes" == "1" ]]; then
    print -r -- "hack"
    return
  fi

  # On a feature/other branch — ask the user
  info "Current branch '$cur' is not the default ('$default')."
  local ans
  ans="$(prompt_choice "Branch from: (1) $default  (2) $cur" "1")"
  if [[ "$ans" == "2" ]]; then
    print -r -- "append"
  else
    print -r -- "hack"
  fi
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
