# SUBCOMMAND: propose
cmd_propose() {
  need_cmd llm
  need_cmd git-town

  local branch
  branch="$(current_branch)"
  [[ -n "$branch" ]] || die "Detached HEAD; check out a branch first."

  # Get parent branch from git-town's tracking, fall back to default
  local base
  base="$(git config "git-town-branch.${branch}.parent" 2>/dev/null \
    || git config git-town.main-branch 2>/dev/null \
    || default_base_branch)"

  info "Proposing $branch → $base"
  git fetch origin "$base" --quiet 2>/dev/null || true

  local commits
  commits="$(git log --no-decorate --oneline "origin/${base}..HEAD" 2>/dev/null || true)"
  [[ -n "$commits" ]] || die "No commits ahead of 'origin/$base'. Nothing to propose."

  local diffstat diff_trunc
  diffstat="$(git diff --stat "origin/${base}...HEAD" || true)"
  diff_trunc="$(truncate_str "$(git diff "origin/${base}...HEAD")" "$MAX_CHARS_DIFF_PROPOSE")"

  local cl last_tag
  cl="$(changelog_excerpt || true)"
  last_tag="$(last_release_tag)"

  local context
  context="$(printf 'Repo: %s\nBranch: %s\nBase: origin/%s\nLast release tag: %s\n\nCOMMITS:\n%s\n\nDIFFSTAT:\n%s\n\nCHANGELOG:\n%s\n\nDIFF (may be truncated):\n%s' \
    "$(basename "$(repo_root)")" "$branch" "$base" "${last_tag:-<none>}" \
    "$commits" "$diffstat" "${cl:-<none>}" "$diff_trunc")"

  info "Generating PR title..."
  local title
  title="$(print -r -- "$context" \
    | llm -s 'Write a conventional commit PR title (type: description). One line only. Output only the title.')"
  title="$(print -r -- "$title" | head -n 1 | tr -d '\r' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
  [[ -n "$title" ]] || die "Model returned empty title."

  info "Generating PR body..."
  local body
  body="$(print -r -- "$context" \
    | llm -s 'Write a release-notes style PR body. Use headings (Summary, Changes). Bullet points. Do not invent changes not in the diff.')"
  body="$(print -r -- "$body" | tr -d '\r')"
  [[ -n "$body" ]] || die "Model returned empty body."

  info "Proposed PR title:"
  print -r -- "  $title" >&2
  print -r -- "" >&2
  info "Proposed PR body (preview):"
  print -r -- "$body" | head -n 20 >&2
  [[ "$(print -r -- "$body" | wc -l | tr -d ' ')" -gt 20 ]] \
    && print -r -- "  ... (truncated preview) ..." >&2

  if ! confirm "Use this title/body for the PR?"; then
    die "Cancelled."
  fi

  git town propose --title "$title" --body "$body"
}
