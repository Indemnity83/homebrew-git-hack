# ---- LLM HELPERS ----
#
# Shared plumbing for the AI-driven commands (commit, propose, idea, issue).
# gen_text runs the `llm` CLI with the resolved system prompt for a key;
# first_line_trimmed cleans a model response down to a single trimmed line.

# gen_text <prompt-key> <context> [model]
# Pipe CONTEXT into `llm` using the system prompt resolved for PROMPT-KEY and
# print the model's response. When MODEL is empty, `llm` uses its own default.
#
# The exit status is llm's (the pipeline's, via pipefail), so a failed model
# call is surfaced rather than looking like an empty response. Capture the
# output into a variable and check the status — e.g.
#     out="$(gen_text ...)" || die "..."
# do NOT nest gen_text directly inside another substitution
# (first_line_trimmed "$(gen_text ...)"), or that status is lost.
gen_text() {
  local key="$1" context="$2" model="${3:-}"
  local prompt
  prompt="$(resolve_prompt "$key")"
  local llm_args=()
  [[ -n "$model" ]] && llm_args=(-m "$model")
  print -r -- "$context" | llm "${llm_args[@]}" -s "$prompt"
}

# first_line_trimmed <text>
# Print the first line of TEXT with CRs stripped and surrounding whitespace
# trimmed. Used to reduce a model response to a single clean subject/branch line.
first_line_trimmed() {
  print -r -- "$1" | head -n 1 | tr -d '\r' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}
