# SUBCOMMAND: propose
cmd_propose() {
  need_cmd llm
  need_cmd git-town
  need_cmd gh

  local auto_yes=0 draft=0 model="" to="" hint=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)       auto_yes=1; shift ;;
      --draft)     draft=1; shift ;;
      --to)        [[ $# -ge 2 ]] || die "--to requires an argument"
                   to="$2"; shift 2 ;;
      --model)     model="$2"; shift 2 ;;
      -m)          model="$2"; shift 2 ;;
      --)          shift; [[ $# -gt 0 ]] && hint="$*"; break ;;
      -*)
        local flags="${1:1}"; shift
        for (( i=1; i<=${#flags}; i++ )); do
          case "${flags[i]}" in
            y) auto_yes=1 ;;
            d) draft=1 ;;
            m) die "-m requires an argument; use -m <model> as a standalone flag" ;;
            *) die "Unknown option: -${flags[i]}" ;;
          esac
        done
        ;;
      *)
        [[ -z "$hint" ]] || die "Unexpected argument: $1"
        hint="$1"; shift ;;
    esac
  done

  local branch
  branch="$(current_branch)"
  [[ -n "$branch" ]] || die "Detached HEAD; check out a branch first."

  # Get parent branch: explicit --to flag, git-town's tracking, or default
  local base
  if [[ -n "$to" ]]; then
    base="$to"
  else
    base="$(git config "git-town-branch.${branch}.parent" 2>/dev/null \
      || default_base_branch)"
  fi

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
  [[ -n "$hint" ]] && context="${context}"$'\n\nUser focus: '"${hint}"

  local llm_args=()
  [[ -n "$model" ]] && llm_args=(-m "$model")

  info "Generating PR title..."
  local title
  title="$(print -r -- "$context" \
    | llm "${llm_args[@]}" -s 'You are a senior engineer preparing a GitHub Pull Request title.

Task:
Generate ONE Conventional Commit title describing the overall change in this branch.

Rules:
- Output ONLY the title
- One line only
- Format: type: description
- NO scopes (no parentheses)
- Use imperative mood
- Be concise but specific
- Target ≤ 65 characters

Allowed types:
feat, fix, refactor, perf, test, docs, build, ci, chore, revert

Guidance:
- Focus on the primary user-facing or developer-facing change
- Do not mention "PR" or "branch"
- Do not include trailing punctuation

Examples:
feat: add print button to report view
fix: handle missing oauth profile claim
refactor: simplify heat buffer logic

Return ONLY the title.')"
  title="$(print -r -- "$title" | head -n 1 | tr -d '\r' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
  [[ -n "$title" ]] || die "Model returned empty title."

  info "Generating PR body..."
  local body
  body="$(print -r -- "$context" \
    | llm "${llm_args[@]}" -s 'You are a senior engineer preparing a GitHub Pull Request description.

Write the PR body like release notes for users and maintainers.

Body style:
- Focus on WHAT changed and WHY it matters
- Avoid low-level implementation details unless they affect behavior
- Keep the content concise and scannable

Structure:

Summary
Short paragraph describing the purpose of the change.

Changes
Bullet points listing the major changes.
Group related items where appropriate.

Notes (optional)
Only include if there are compatibility notes, migrations, or
important contributor information.

Rules:
- Use markdown headings
- Use bullet points under Changes
- Do NOT invent changes not present in the commits, diff, or changelog
- Avoid mentioning "this PR" or "this branch"

Return ONLY the body text.')"
  body="$(print -r -- "$body" | tr -d '\r')"
  [[ -n "$body" ]] || die "Model returned empty body."

  info "Proposed PR title:"
  print -r -- "  $title" >&2
  print -r -- "" >&2
  info "Proposed PR body (preview):"
  print -r -- "$body" | head -n 20 >&2
  [[ "$(print -r -- "$body" | wc -l | tr -d ' ')" -gt 20 ]] \
    && print -r -- "  ... (truncated preview) ..." >&2

  if [[ $auto_yes -eq 0 ]] && ! confirm "Use this title/body for the PR?"; then
    die "Cancelled."
  fi

  local remote
  remote="$(git config "branch.${branch}.remote" 2>/dev/null || true)"
  [[ -n "$remote" ]] || remote="origin"
  info "Pushing $branch to $remote..."
  local push_args=("$remote" "$branch")
  git config "branch.${branch}.merge" &>/dev/null || push_args=(--set-upstream "${push_args[@]}")
  git push "${push_args[@]}" || die "Failed to push branch to remote."

  local gh_args=(--base "$base" --title "$title" --body "$body")
  [[ $draft -eq 1 ]] && gh_args+=(--draft)

  local pr_url gh_rc=0
  pr_url="$(gh pr create "${gh_args[@]}")" || gh_rc=$?
  if [[ $gh_rc -eq 0 ]]; then
    ok "Created: $pr_url"
  else
    local existing_url
    existing_url="$(gh pr view --json url -q .url 2>/dev/null || true)"
    if [[ -n "$existing_url" ]]; then
      info "PR already exists, updating..."
      gh pr edit --base "$base" --title "$title" --body "$body"
      ok "Updated: $existing_url"
    else
      die "Failed to create PR."
    fi
  fi

  gh pr view --web
}
