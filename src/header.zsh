#!/usr/bin/env zsh
set -euo pipefail

# git-hack — git workflow helper powered by llm + git-town
#
# Subcommands:
#   git hack ["idea"]
#   git hack issue <number>
#   git hack snapshot [-c|--conventional]
#   git hack propose
#   git hack port [commit-sha] [target-branch]
#   git hack port --continue
#   git hack done
#   git hack prune
#   git hack init
#
# Dependencies:
#   git, llm, git-town
#   issue: gh (GitHub CLI)
#   optional: fzf (better UI for selections)

# Hard safety limits to avoid shipping massive diffs:
MAX_CHARS_DIFF_COMMIT=20000
MAX_CHARS_DIFF_PROPOSE=50000
