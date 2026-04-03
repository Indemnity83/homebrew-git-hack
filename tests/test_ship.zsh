#!/usr/bin/env zsh
source "$(dirname "$0")/assert.zsh"

# Stubs for functions ship.zsh calls at parse time
need_cmd()       { true }
die()            { print -r -- "die: $*" >&2; exit 1 }
current_branch() { print -r -- "test-branch" }
info()           { true }
GIT_CALLS=()
git() { GIT_CALLS+=("$*") }

source "$(dirname "$0")/../src/commands/ship.zsh"

# Intercept cmd_commit / cmd_propose
commit_got=()
propose_got=()
cmd_commit()  { commit_got=("$@")  }
cmd_propose() { propose_got=("$@") }

print -r -- "cmd_ship argument forwarding"

# -y goes to both
commit_got=(); propose_got=()
cmd_ship -y
assert_eq "-y → commit"  "-y" "${commit_got[*]}"
assert_eq "-y → propose" "-y" "${propose_got[*]}"

# -a -c go to commit only
commit_got=(); propose_got=()
cmd_ship -a -c
assert_eq "-a -c → commit"       "-a -c" "${commit_got[*]}"
assert_eq "-a -c not → propose"  ""      "${propose_got[*]}"

# -d goes to propose only
commit_got=(); propose_got=()
cmd_ship -d
assert_eq "-d not → commit"  ""   "${commit_got[*]}"
assert_eq "-d → propose"     "-d" "${propose_got[*]}"

# -n goes to commit only
commit_got=(); propose_got=()
cmd_ship -n
assert_eq "-n → commit"      "-n" "${commit_got[*]}"
assert_eq "-n not → propose" ""   "${propose_got[*]}"

# -m goes to both
commit_got=(); propose_got=()
cmd_ship -m gpt4
assert_eq "-m → commit"  "-m gpt4" "${commit_got[*]}"
assert_eq "-m → propose" "-m gpt4" "${propose_got[*]}"

# combined: -a -c -y -d -n -m
commit_got=(); propose_got=()
cmd_ship -a -c -y -d -n -m mymodel
assert_eq "combined → commit"  "-a -c -n -y -m mymodel" "${commit_got[*]}"
assert_eq "combined → propose" "-d -y -m mymodel"       "${propose_got[*]}"

# --to goes to propose only
commit_got=(); propose_got=()
cmd_ship --to v2
assert_eq "--to not → commit"  ""           "${commit_got[*]}"
assert_eq "--to → propose"     "--to v2"    "${propose_got[*]}"

summarize
