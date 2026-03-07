# MAIN
main() {
  need_cmd git
  need_cmd llm
  need_cmd git-town

  local cmd="${1:-}"
  [[ $# -gt 0 ]] && shift

  case "$cmd" in
    init)     cmd_init "$@" ;;
    record)   in_git_repo || die "Run this inside a git repository."; cmd_record "$@" ;;
    done)     in_git_repo || die "Run this inside a git repository."; cmd_done "$@" ;;
    pick)     in_git_repo || die "Run this inside a git repository."; cmd_pick "$@" ;;
    idea)     in_git_repo || die "Run this inside a git repository."; cmd_idea "$@" ;;
    issue)    in_git_repo || die "Run this inside a git repository."; cmd_issue "$@" ;;
    propose)  in_git_repo || die "Run this inside a git repository."; cmd_propose "$@" ;;

    -h|--help)
      cat <<'HELP'
git-hack — git workflow helper powered by llm + git-town

Usage: git hack [idea-text]   (defaults to 'idea' when no subcommand given)

Commands:
  git hack [idea]              Create a feature branch (llm names it, git-town tracks it)
  git hack issue <number>      Create a branch from a GitHub issue
  git hack record [-c]         Generate and commit with an AI-written message
  git hack propose             Create/update a GitHub PR via git-town
  git hack pick [sha] [branch] Cherry-pick a commit (defaults to current branch)
  git hack pick --continue     Continue after resolving conflicts
  git hack done                Delete merged branch and sync main
  git hack init                Install global git aliases (git snap, git propose, …)

Dependencies:
  git, llm, git-town
  issue: gh (GitHub CLI)
  optional: fzf (improved selection UI)

Run 'git town config setup' once per repo to configure git-town.

HELP
      ;;

    "")
      # No subcommand — go interactive idea mode
      in_git_repo || die "Run this inside a git repository."
      cmd_idea
      ;;

    *)
      # Unknown token — treat as idea description
      in_git_repo || die "Run this inside a git repository."
      cmd_idea "$cmd" "$@"
      ;;
  esac
}

main "$@"
