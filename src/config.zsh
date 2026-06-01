# ---- PROMPT RESOLUTION ----
#
# Each AI command's system prompt can be overridden by a plain file, falling
# back to the built-in (default_prompt, see prompts.zsh). Lookup order:
#   1. $(git rev-parse --git-dir)/hack/<key>.md   (per-repo, local git metadata)
#   2. ${XDG_CONFIG_HOME:-$HOME/.config}/git-hack/<key>.md   (global default)
#   3. default_prompt <key>   (built-in fallback)
# A non-empty file fully replaces the built-in prompt.

# resolve_prompt <key> — print the effective system prompt for KEY.
resolve_prompt() {
  local key="$1"
  local gitdir
  gitdir="$(git rev-parse --git-dir 2>/dev/null || true)"
  if [[ -n "$gitdir" && -s "$gitdir/hack/${key}.md" ]]; then
    cat "$gitdir/hack/${key}.md"
    return
  fi
  local global="${XDG_CONFIG_HOME:-$HOME/.config}/git-hack/${key}.md"
  if [[ -s "$global" ]]; then
    cat "$global"
    return
  fi
  default_prompt "$key"
}

# prompt_dir <scope> — print the override directory for SCOPE.
#   "local" => the repo's git metadata dir (.git/hack)
#   anything else => the global config dir
prompt_dir() {
  if [[ "$1" == local ]]; then
    local gitdir
    gitdir="$(git rev-parse --git-dir 2>/dev/null)" \
      || die "Not inside a git repository (needed for --local)."
    print -r -- "$gitdir/hack"
  else
    print -r -- "${XDG_CONFIG_HOME:-$HOME/.config}/git-hack"
  fi
}
