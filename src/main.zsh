# MAIN
main() {
  need_cmd git

  local cmd="${1:-}"
  [[ $# -gt 0 ]] && shift

  case "$cmd" in
    init)     cmd_init "$@" ;;
    commit|record)
              [[ "$cmd" == "record" ]] && print -r -- "Warning: 'git hack record' is deprecated; use 'git hack commit' instead." >&2
              need_cmd llm; need_cmd git-town; in_git_repo || die "Run this inside a git repository."; cmd_commit "$@" ;;
    done)     need_cmd llm; need_cmd git-town; in_git_repo || die "Run this inside a git repository."; cmd_done "$@" ;;
    pick)     need_cmd git-town; in_git_repo || die "Run this inside a git repository."; cmd_pick "$@" ;;
    idea)     need_cmd llm; need_cmd git-town; in_git_repo || die "Run this inside a git repository."; cmd_idea "$@" ;;
    issue)    need_cmd llm; need_cmd git-town; in_git_repo || die "Run this inside a git repository."; cmd_issue "$@" ;;
    propose)  need_cmd llm; need_cmd git-town; in_git_repo || die "Run this inside a git repository."; cmd_propose "$@" ;;

    -h|--help)
      cat <<'HELP'
git-hack — git workflow helper powered by llm + git-town

Usage: git hack [idea-text]   (defaults to 'idea' when no subcommand given)

Commands:
  git hack [-y] [-m model] [idea]                        Create a feature branch
  git hack issue [-y] [-m model] <number>                Create a branch from a GitHub issue
  git hack commit [-y] [-a] [-A] [-c] [-p] [-m model]  AI commit message
  git hack propose [-y] [-d] [-m model]                  Create/update a GitHub PR via git-town
  git hack pick [sha] [branch]                          Cherry-pick a commit (defaults to current branch)
  git hack pick --continue     Continue after resolving conflicts
  git hack done                Delete merged branch and sync main
  git hack init                Install global git aliases (git c, git pr, …)

Dependencies:
  git, llm, git-town
  issue: gh (GitHub CLI)
  optional: fzf (improved selection UI)

Run 'git town config setup' once per repo to configure git-town.

HELP
      ;;

    "")
      # No subcommand — go interactive idea mode
      need_cmd llm; need_cmd git-town
      in_git_repo || die "Run this inside a git repository."
      cmd_idea
      ;;

    *)
      # Unknown token — treat as idea description
      need_cmd llm; need_cmd git-town
      in_git_repo || die "Run this inside a git repository."
      cmd_idea "$cmd" "$@"
      ;;
  esac
}

main "$@"
