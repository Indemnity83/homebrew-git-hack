# git-hack

A git workflow helper that uses [`llm`](https://llm.datasette.io) for AI assistance and [`git-town`](https://www.git-town.com) for branch management. It automates the repetitive parts of your workflow: naming branches, writing commit messages, and drafting pull requests.

The result is a workflow that lets you move fast with LLM-assisted coding while still producing clear commits, clean PRs, and useful changelogs.

See [WORKFLOW.md](WORKFLOW.md) for a full walkthrough, including how this pairs with squash merges, protected branches, and release-please for automated changelogs.

---

## The Workflow

```text
idea → commit → propose → git town sync
```

| Step | Command | What it does |
|------|---------|-------------|
| Idea | `git hack "description"` | LLM names and creates the branch |
| Checkpoint | `git hack checkpoint` | LLM generates a commit message from your staged diff |
| Propose | `git hack propose` | LLM drafts a Conventional Commit PR title and body, then opens it via `git town propose` |
| Wrap up | `git town sync` | syncs, deletes the merged branch, and returns you to main |

---

## Install

### Homebrew (recommended)

```bash
brew tap indemnity83/git-hack
brew install git-hack
```

### Manual

**Install required dependencies:**

```bash
brew install llm git-town gh
```

**Install the script:**

<!-- RELEASE_INSTALL_BEGIN -->
```bash
curl -fsSL https://github.com/indemnity83/homebrew-git-hack/releases/download/v0.2.0/git-hack -o /tmp/git-hack
echo "826181abe4a350177b29f2a9af71da07be86a2234541e8d1ed33e28f8acadb85  /tmp/git-hack" | shasum -a 256 -c
install -m 755 /tmp/git-hack /usr/local/bin/git-hack
```
<!-- RELEASE_INSTALL_END -->

Or install to `~/.local/bin` (no `sudo` required) — replace `/usr/local/bin` above with `~/.local/bin` and ensure it is on your `$PATH`.

Once installed, both `git hack` and `git-hack` work.

**Configure your LLM** (choose any provider `llm` supports):

```bash
llm install llm-anthropic   # Anthropic (use with: llm -m claude-sonnet-4-5)
# or: llm install llm-openai, llm install llm-gemini, etc.
llm keys set anthropic
```

**Configure git-town** once per repo:

```bash
git town config setup
```

**Optional setup** — pick git aliases and scaffold editable prompt files:

```bash
git hack init            # this repo (.git/config, .git/hack)
git hack init --global   # your account (~/.gitconfig, ~/.config/git-hack)
```

`init` is a short interactive setup: page 1 lets you choose git alias shortcuts
(e.g. `git cp` → `git hack checkpoint`), page 2 lets you scaffold prompt-override
files to customize. It writes to the current repo by default; `--global` targets
your home config.

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
git hack                             # interactive: prompts for description
git hack "add dark mode toggle"      # branch name suggested immediately
git hack idea "add dark mode toggle" # explicit subcommand form
```

### `git hack issue <number>`

Same as `idea`, but fetches the title and body from a GitHub issue to generate the branch name.

```bash
git hack issue 42
```

### `git hack checkpoint [-y] [-a] [-A] [-p] [-n] [-m model] ["hint"]`

Generates a commit message from your staged diff. If nothing is staged, prompts for `p` (`git add -p`, interactive patch), `a` (`git add -A`, all changes), or `n` (skip). You can accept, edit, or cancel before the commit is made.

| Flag | Description |
|------|-------------|
| `-a` | Stage all changes first (`git add -A`) |
| `-A` | Amend the last commit instead of creating a new one (uses `--force-with-lease` when pushing) |
| `-p` | Push after committing |
| `-n` | Skip pre-commit and pre-push hooks (`--no-verify`) |
| `-y` | Auto-accept the generated message without prompting |
| `-m model` | LLM model to use (passed to `llm -m`) |

```bash
git hack checkpoint              # commit staged changes with AI-generated message
git hack checkpoint -a           # stage all changes first (git add -A)
git hack checkpoint -p           # push after committing
git hack checkpoint -a -p        # stage all, commit, and push
git hack checkpoint -n           # skip pre-commit hooks
git hack checkpoint -y           # accept message without prompting
git hack checkpoint -A           # amend the last commit
git hack checkpoint -A -p        # amend and force-push
git hack checkpoint -m claude-3-5-sonnet-latest  # use a specific model
```

Also available as `git cp` after running `git hack init`.

### `git hack propose`

Generates a conventional-commit PR title and a release-notes-style body for the current branch from your commits, diff, and `CHANGELOG.md` (if present), then hands them to `git town propose`. git-town syncs the branch and opens your forge's proposal page prefilled with the generated title and body for you to finalize.

```bash
git hack propose
git hack propose "focus on the caching change"   # optional hint
```

Also available as `git pr` and `git propose` after running `git hack init`.

### `git hack pick [sha] [branch]`

Cherry-picks a commit onto another branch. Without arguments, shows an interactive list of recent commits from the default branch (uses `fzf` if available). Returns to your original branch when done.

```bash
git hack pick                        # interactive: pick commit
git hack pick abc1234                # cherry-pick onto current branch
git hack pick abc1234 release/v2     # cherry-pick onto a specific branch
git hack pick --continue             # resume after resolving conflicts
```

### Wrapping up a branch

There is no dedicated command for this — once your PR is merged, `git town sync` already syncs main, prunes the merged branch, and returns you to the parent. Run it from anywhere with `git town sync --all`.

### `git hack init [--global]`

Interactive, two-page setup — nothing is installed without your say-so. Writes to
the current repo by default (`.git/config`, `.git/hack/`); `--global` targets
`~/.gitconfig` and `~/.config/git-hack/`.

```bash
git hack init            # this repo
git hack init --global   # your account
```

- **Page 1 — aliases:** choose git alias shortcuts to install.
- **Page 2 — prompts:** choose which prompt-override files to scaffold.

With `fzf`: TAB to multi-select, ENTER to confirm (Esc selects none). Without `fzf`:
numbered list, enter numbers or `all`.

Alias choices:

| Alias | Expands to |
|-------|-----------|
| `git cp` | `git hack checkpoint` |
| `git pr` | `git hack propose` |
| `git propose` | `git hack propose` |
| `git pick` | `git hack pick` |
