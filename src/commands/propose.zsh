# SUBCOMMAND: propose
cmd_propose() {
  need_cmd llm
  need_cmd git-town

  local auto_yes=0 model="" hint=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)       auto_yes=1; shift ;;
      --model)     model="$2"; shift 2 ;;
      -m)          model="$2"; shift 2 ;;
      --)          shift; [[ $# -gt 0 ]] && hint="$*"; break ;;
      -*)
        local flags="${1:1}"; shift
        for (( i=1; i<=${#flags}; i++ )); do
          case "${flags[i]}" in
            y) auto_yes=1 ;;
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

  # Parent branch, used only to build the diff context for the model. git-town
  # tracks it; fall back to the repo's main branch.
  local base
  base="$(git config "git-town-branch.${branch}.parent" 2>/dev/null \
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
  [[ -n "$hint" ]] && context="${context}"$'\n\nUser focus: '"${hint}"

  info "Generating PR title..."
  local title
  title="$(first_line_trimmed "$(gen_text propose-title "$context" "$model")")"
  [[ -n "$title" ]] || die "Model returned empty title."

  info "Generating PR body..."
  local body
  body="$(gen_text propose-body "$context" "$model" | tr -d '\r')"
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

  # Hand the generated values to git-town, which syncs the branch and opens the
  # forge's proposal page prefilled with this title/body for you to finalize.
  local bodyfile rc=0
  bodyfile="$(mktemp)"
  print -r -- "$body" > "$bodyfile"
  git town propose --title "$title" --body-file "$bodyfile" || rc=$?
  rm -f "$bodyfile"
  [[ $rc -eq 0 ]] || die "git town propose failed."
}
