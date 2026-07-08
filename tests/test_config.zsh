#!/usr/bin/env zsh
SRCDIR="${0:h}/../src"
source "${0:h}/assert.zsh"
source "$SRCDIR/utils.zsh"
source "$SRCDIR/prompts.zsh"
source "$SRCDIR/config.zsh"

# Run a command inside an isolated temp git repo with an isolated (empty)
# global config dir. The body sees $XDG_CONFIG_HOME pointing at that dir, so
# it can stage per-repo (.git/hack) and global override files without touching
# the real environment. Output of the body is returned on stdout.
with_env() {
  local cmd="$1" repo cfg
  repo="$(mktemp -d)"
  cfg="$(mktemp -d)"
  git init "$repo" --quiet
  ( cd "$repo" && export XDG_CONFIG_HOME="$cfg" && eval "$cmd" )
  local rc=$?
  rm -rf "$repo" "$cfg"
  return $rc
}

# ---- resolve_prompt ----
print "resolve_prompt"

# No override files anywhere → built-in default.
result="$(with_env 'resolve_prompt checkpoint')"
assert_eq "falls back to default_prompt" "$(default_prompt checkpoint)" "$result"

# Per-repo file fully overrides the built-in.
result="$(with_env 'mkdir -p .git/hack; print -r -- "REPO OVERRIDE" > .git/hack/checkpoint.md; resolve_prompt checkpoint')"
assert_eq "per-repo file wins" "REPO OVERRIDE" "$result"

# Multi-line content round-trips intact (e.g. a conventional-commit override).
result="$(with_env 'mkdir -p .git/hack
cat > .git/hack/checkpoint.md <<EOF
Use a scope.
Allowed scopes: api, ui, db.
Format: type(scope): description.
EOF
resolve_prompt checkpoint')"
assert_contains "multi-line override preserved (line 1)" "Use a scope." "$result"
assert_contains "multi-line override preserved (line 2)" "Allowed scopes: api, ui, db." "$result"
assert_contains "multi-line override preserved (line 3)" "Format: type(scope): description." "$result"

# An empty file is skipped (-s) and falls through to the default.
result="$(with_env 'mkdir -p .git/hack; : > .git/hack/checkpoint.md; resolve_prompt checkpoint')"
assert_eq "empty per-repo file falls through" "$(default_prompt checkpoint)" "$result"

# Global file is used when no per-repo file exists.
result="$(with_env 'mkdir -p "$XDG_CONFIG_HOME/git-hack"; print -r -- "GLOBAL BRANCH" > "$XDG_CONFIG_HOME/git-hack/branch.md"; resolve_prompt branch')"
assert_eq "global fallback used" "GLOBAL BRANCH" "$result"

# Per-repo beats global when both exist.
result="$(with_env 'mkdir -p .git/hack "$XDG_CONFIG_HOME/git-hack"
print -r -- "REPO WINS" > .git/hack/branch.md
print -r -- "GLOBAL LOSES" > "$XDG_CONFIG_HOME/git-hack/branch.md"
resolve_prompt branch')"
assert_eq "per-repo precedes global" "REPO WINS" "$result"

# ---- default_prompt ----
print "default_prompt"

for key in "${PROMPT_KEYS[@]}"; do
  out="$(default_prompt "$key")"
  [[ -n "$out" ]] && assert_eq "default_prompt $key is non-empty" "0" "0" \
    || assert_eq "default_prompt $key is non-empty" "non-empty" "empty"
done

# Unknown key exits nonzero (die).
( default_prompt bogus-key ) >/dev/null 2>&1
assert_ne "unknown key exits nonzero" "0" "$?"

# ---- prompt_dir ----
print "prompt_dir"

result="$(with_env 'prompt_dir global')"
assert_contains "global dir under config home" "/git-hack" "$result"

result="$(with_env 'prompt_dir local')"
assert_contains "local dir under git metadata" "/hack" "$result"

summarize
