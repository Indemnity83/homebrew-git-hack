#!/usr/bin/env zsh
source "$(dirname "$0")/assert.zsh"

# ---------------------------------------------------------------------------
# Unit tests for the push logic inside cmd_propose:
#   - new branch (no upstream): git push --set-upstream <remote> <branch>
#   - existing upstream:        git push <remote> <branch>
# ---------------------------------------------------------------------------

# We only need to exercise the push block, so we stub everything else that
# propose.zsh touches before/after that block.

typeset -g BRANCH="feat-new"
typeset -g HAS_MERGE_CONFIG=0   # controls whether "upstream already set"
typeset -g GIT_CALLS=()

need_cmd()       { true }
die()            { print -r -- "die: $*" >&2; exit 1 }
info()           { true }
ok()             { true }
confirm()        { return 0 }   # auto-yes
current_branch() { print -r -- "$BRANCH" }
repo_root()      { print -r -- "/tmp/fake" }
default_base_branch() { print -r -- "main" }
truncate_str()   { print -r -- "$1" }
changelog_excerpt() { true }
last_release_tag()  { true }

git() {
  local subcmd="$1"
  case "$subcmd" in
    config)
      # branch.<name>.remote → return "origin"
      # branch.<name>.merge  → succeed only when HAS_MERGE_CONFIG=1
      if [[ "$2" == "branch.${BRANCH}.remote" ]]; then
        print -r -- "origin"; return 0
      fi
      if [[ "$2" == "branch.${BRANCH}.merge" ]]; then
        return $(( 1 - HAS_MERGE_CONFIG ))
      fi
      return 1
      ;;
    push)
      GIT_CALLS+=("$*"); return 0 ;;
    fetch)
      return 0 ;;
    log)
      # must return at least one commit so propose doesn't die
      print -r -- "abc1234 stub commit"; return 0 ;;
    diff)
      return 0 ;;
    *)
      return 0 ;;
  esac
}

llm() {
  # Return a minimal non-empty title or body depending on context
  print -r -- "feat: stub output"
}

gh() {
  # Pretend pr create succeeds and returns a URL
  if [[ "$1 $2" == "pr create" ]]; then
    print -r -- "https://github.com/owner/repo/pull/1"
    return 0
  fi
  return 0
}

source "$(dirname "$0")/../src/commands/propose.zsh"

print -r -- "cmd_propose push behaviour"

# --- new branch: no upstream configured → --set-upstream expected ---
HAS_MERGE_CONFIG=0
GIT_CALLS=()
cmd_propose -y
assert_contains "new branch: --set-upstream used" \
  "push --set-upstream origin feat-new" "${GIT_CALLS[*]}"

# --- existing upstream: upstream already configured → no --set-upstream ---
HAS_MERGE_CONFIG=1
GIT_CALLS=()
cmd_propose -y
local push_call="${GIT_CALLS[*]}"
assert_contains   "existing upstream: push fires"         "push origin feat-new" "$push_call"
# ensure --set-upstream is absent
[[ "$push_call" != *"--set-upstream"* ]]
assert_eq "existing upstream: no --set-upstream" "0" "$?"

summarize
