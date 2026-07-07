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

out="$(gen_text commit "the context" gpt-x)"
assert_contains "passes -m <model> when model is set" "-m gpt-x" "$out"
assert_contains "passes resolved system prompt via -s" "-s PROMPT:commit" "$out"
assert_contains "pipes the context to llm on stdin" "the context" "$out"

out_nomodel="$(gen_text propose-title "ctx")"
assert_eq "omits -m when no model given" \
  "0" \
  "$([[ "$out_nomodel" == *"-m "* ]] && print 1 || print 0)"
assert_contains "still resolves prompt for the key" "-s PROMPT:propose-title" "$out_nomodel"

summarize
