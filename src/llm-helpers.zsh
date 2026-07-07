# ---- LLM HELPERS ----
#
# Shared plumbing for the AI-driven commands (commit, propose, idea, issue).
# gen_text runs the `llm` CLI with the resolved system prompt for a key;
# first_line_trimmed cleans a model response down to a single trimmed line.

# gen_text <prompt-key> <context> [model]
# Pipe CONTEXT into `llm` using the system prompt resolved for PROMPT-KEY.
# When MODEL is empty, `llm` uses its own configured default model.
gen_text() {
  local key="$1" context="$2" model="${3:-}"
  local llm_args=()
  [[ -n "$model" ]] && llm_args=(-m "$model")
  print -r -- "$context" | llm "${llm_args[@]}" -s "$(resolve_prompt "$key")"
}

# first_line_trimmed <text>
# Print the first line of TEXT with CRs stripped and surrounding whitespace
# trimmed. Used to reduce a model response to a single clean subject/branch line.
first_line_trimmed() {
  print -r -- "$1" | head -n 1 | tr -d '\r' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}
