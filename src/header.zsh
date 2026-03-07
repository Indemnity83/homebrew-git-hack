#!/usr/bin/env zsh
set -euo pipefail

# hack — git workflow helper powered by llm + git-town
#
# Subcommands:
#   hack idea ["my idea"]
#   hack issue <number>
#   hack commit [-c|--conventional]
#   hack propose
#   hack port [commit-sha] [target-branch]
#   hack port --continue
#   hack done
#   hack prune
#
# Dependencies:
#   git, llm, git-town
#   issue: gh (GitHub CLI)
#   optional: fzf (better UI for selections)

# Hard safety limits to avoid shipping massive diffs:
MAX_CHARS_DIFF_COMMIT=20000
MAX_CHARS_DIFF_PROPOSE=50000
