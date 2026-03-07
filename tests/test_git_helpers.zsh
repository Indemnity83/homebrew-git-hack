#!/usr/bin/env zsh
SRCDIR="${0:h}/../src"
source "${0:h}/assert.zsh"
source "$SRCDIR/utils.zsh"
source "$SRCDIR/git-helpers.zsh"

# Helper: create an isolated temp git repo, run a command inside it, return output.
run_in_tmp_repo() {
  local tmp
  tmp="$(mktemp -d)"
  git init "$tmp" --quiet
  local setup_args=()
  while [[ "${1:-}" != "--" && $# -gt 0 ]]; do
    setup_args+=("$1")
    shift
  done
  shift  # consume '--'
  local cmd="$1"

  for arg in "${setup_args[@]}"; do
    eval "git -C '$tmp' $arg" >/dev/null 2>&1 || true
  done

  ( cd "$tmp" && eval "$cmd" )
  local exit_code=$?
  rm -rf "$tmp"
  return $exit_code
}

# ---- default_base_branch ----
print "default_base_branch"

# git-town.main-branch config takes priority
result="$(run_in_tmp_repo \
  "config git-town.main-branch develop" \
  -- "default_base_branch")"
assert_eq "git-town.main-branch config" "develop" "$result"

# origin/HEAD symref is used when no config
result="$(run_in_tmp_repo \
  "symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/staging" \
  -- "default_base_branch")"
assert_eq "origin/HEAD symref" "staging" "$result"

# refs/heads/main exists → "main"
result="$(run_in_tmp_repo \
  "commit --allow-empty -m init --quiet --author='T <t@t>' -c user.name=T -c user.email=t@t" \
  -- "default_base_branch")"
[[ "$result" == "main" || "$result" == "master" ]]
assert_eq "fallback is main or master" "0" "$?"

summarize
