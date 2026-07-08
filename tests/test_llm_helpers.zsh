#!/usr/bin/env zsh
SRCDIR="${0:h}/../src"
source "${0:h}/assert.zsh"
source "$SRCDIR/utils.zsh"
source "$SRCDIR/llm-helpers.zsh"

# ---- first_line_trimmed ----
print "first_line_trimmed"

assert_eq "keeps only the first line" \
  "hello" \
  "$(first_line_trimmed $'hello\nworld')"

assert_eq "trims surrounding whitespace" \
  "hello world" \
  "$(first_line_trimmed '   hello world   ')"

assert_eq "strips carriage returns" \
  "subject" \
  "$(first_line_trimmed $'subject\r\nbody')"

assert_eq "single clean line is unchanged" \
  "fix: add thing" \
  "$(first_line_trimmed 'fix: add thing')"

# ---- gen_text ----
print ""
print "gen_text"

# Stub the external `llm` CLI and prompt resolution so gen_text is exercised
# without a network call. The stub echoes its args, then its stdin.
llm() { print -r -- "ARGS:$*"; cat; }
resolve_prompt() { print -r -- "PROMPT:$1"; }

out="$(gen_text checkpoint "the context" gpt-x)"
assert_contains "passes -m <model> when model is set" "-m gpt-x" "$out"
assert_contains "passes resolved system prompt via -s" "-s PROMPT:checkpoint" "$out"
assert_contains "pipes the context to llm on stdin" "the context" "$out"

out_nomodel="$(gen_text propose-title "ctx")"
assert_not_contains "omits -m when no model given" "-m " "$out_nomodel"
assert_contains "still resolves prompt for the key" "-s PROMPT:propose-title" "$out_nomodel"

# A failing llm call must surface as a nonzero exit, not a silent empty string.
llm() { return 3; }
gen_text checkpoint "ctx" >/dev/null 2>&1
assert_exit_nonzero "surfaces llm failure as nonzero exit" $?

summarize
