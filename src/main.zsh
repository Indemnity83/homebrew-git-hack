# MAIN
main() {
  need_cmd git

  local cmd="${1:-}"
  [[ $# -gt 0 ]] && shift

  case "$cmd" in
    init)     cmd_init "$@" ;;
    checkpoint) need_cmd llm; need_cmd git-town; in_git_repo || die "Run this inside a git repository."; cmd_checkpoint "$@" ;;
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
  git hack checkpoint [-y] [-a] [-A] [-p] [-n] [-m model] ["hint"]  AI checkpoint commit
  git hack propose [-y] [-m model] ["hint"]             Generate PR title/body and open via git town propose
  git hack pick [sha] [branch]                          Cherry-pick a commit (defaults to current branch)
  git hack pick --continue     Continue after resolving conflicts
  git hack pick --abort        Abort and clean up
  git hack init                Install global git aliases (git c, git pr, …)
  git hack init --prompts [--local]   Write editable default prompt files

Dependencies:
  git, llm, git-town
  issue: gh (GitHub CLI)
  optional: fzf (improved selection UI)

Run 'git town config setup' once per repo to configure git-town.

Custom prompts:
  Override any command's AI prompt with a plain file. Lookup order:
    .git/hack/<key>.md            (per-repo, not committed)
    ~/.config/git-hack/<key>.md   (global default)
    built-in                      (fallback)
  Keys: checkpoint, propose-title, propose-body, branch
  Run 'git hack init --prompts' (global) or '--prompts --local' (this repo)
  to write the built-in prompts as starting points, then edit them.

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
