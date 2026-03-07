# git-hack

A git workflow helper that uses [`llm`](https://llm.datasette.io) for AI assistance and [`git-town`](https://www.git-town.com) for branch management. It automates the repetitive parts of your workflow: naming branches, writing commit messages, and drafting pull requests.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Indemnity83/hack/main/git-hack -o /usr/local/bin/git-hack && chmod +x /usr/local/bin/git-hack
```

Or if you prefer `~/.local/bin` (no `sudo` required):

```bash
mkdir -p ~/.local/bin && curl -fsSL https://raw.githubusercontent.com/Indemnity83/hack/main/git-hack -o ~/.local/bin/git-hack && chmod +x ~/.local/bin/git-hack
```

Make sure the target directory is on your `$PATH`. Once installed, both `git hack` and `git-hack` work.

## Setup

**Install dependencies:**

```bash
brew install llm git-town fzf
```

**Configure your LLM** (choose any provider `llm` supports):

```bash
llm install llm-claude-claude-sonnet-4-5   # Anthropic
# or: llm install llm-openai, llm install llm-gemini, etc.
llm keys set anthropic
```

**Configure git-town** once per repo:

```bash
git town config setup
```

**Install git aliases** (optional but recommended):

```bash
git hack init
```

This adds shortcuts like `git snap`, `git propose`, etc. to your `~/.gitconfig`.

## Dependencies

| Tool | Required | Used for |
|------|----------|----------|
| `git` | yes | everything |
| `llm` | yes | AI suggestions |
| `git-town` | yes | branch creation and PR workflow |
| `gh` | for `hack issue` | fetching GitHub issue data |
| `fzf` | no | improved selection UI |

## Commands

### `git hack ["description"]`

Creates a new feature branch. With no subcommand, defaults to `idea`. AI suggests a branch name; you confirm or edit before the branch is created. git-town tracks the parent branch automatically.

```bash
git hack                                    # interactive: prompts for description
git hack "add dark mode toggle"             # branch name suggested immediately
git hack idea "add dark mode toggle"        # explicit subcommand form
```

### `git hack issue <number>`

Same as `idea`, but fetches the title and body from a GitHub issue to generate the branch name.

```bash
git hack issue 42
```

### `git hack snapshot [-c|--conventional]`

Generates a commit message from your staged diff. If nothing is staged, offers to run `git add -p`. You can accept, edit, or cancel before the commit is made.

```bash
git add -p
git hack snapshot              # imperative subject line
git hack snapshot --conventional   # conventional commit prefix (feat:, fix:, …)
```

Also available as `git snap` after running `git hack init`.

### `git hack propose`

Creates or updates a GitHub PR for the current branch using `git town propose`. Generates a conventional-commit title and a release-notes-style body from your commits, diff, and `CHANGELOG.md` (if present). Parent branch is read from git-town's tracking config.

```bash
git hack propose
```

### `git hack port [sha] [branch]`

Cherry-picks a commit onto another branch. Without arguments, shows an interactive list of recent commits from the default branch (uses `fzf` if available). Returns to your original branch when done.

```bash
git hack port                        # interactive: pick commit
git hack port abc1234                # cherry-pick onto current branch
git hack port abc1234 release/v2     # cherry-pick onto a specific branch
git hack port --continue             # resume after resolving conflicts
```

### `git hack done`

Runs `git town sync`, which detects merged PRs, switches to the parent branch, and cleans up the local branch automatically.

```bash
git hack done
```

### `git hack prune`

Runs `git town prune` to delete orphaned local branches.

```bash
git hack prune
```

### `git hack init`

Installs optional git aliases into your global `~/.gitconfig`. Run once after installing `git-hack`.

```bash
git hack init
```

With `fzf`: TAB to multi-select aliases, ENTER to confirm. Without `fzf`: numbered list, enter numbers or `all`.

Aliases installed:

| Alias | Expands to |
|-------|-----------|
| `git snap` | `git hack snapshot` |
| `git propose` | `git hack propose` |
| `git port` | `git hack port` |
| `git done` | `git hack done` |
| `git prune` | `git hack prune` |
| `git issue` | `git hack issue` |
