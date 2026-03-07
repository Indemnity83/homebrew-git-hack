# git-hack

A git workflow helper that uses [`llm`](https://llm.datasette.io) for AI assistance and [`git-town`](https://www.git-town.com) for branch management. It automates the repetitive parts of your workflow: naming branches, writing commit messages, and drafting pull requests.

The result is a workflow that lets you move fast with LLM-assisted coding while still producing clear commits, clean PRs, and useful changelogs.

---

## The Workflow

```
idea → record → propose → done
```

**1. Start an idea** — describe a change in plain English; an LLM names and creates the branch.

**2. Hack on the code** — use your preferred coding assistant to implement the change.

**3. Record progress** — stage your diff and let the LLM generate a concise, imperative commit message. Repeat as needed.

**4. Propose** — when the feature is complete, `git hack propose` generates a Conventional Commit PR title and a summary body from the full diff. The PR is created and opened in your browser.

**5. Merge** — squash merge on GitHub. The PR title becomes the commit message on main, keeping history clean and changelog-friendly.

**6. Clean up** — `git hack done` verifies the branch was merged, deletes it locally and remotely, and updates main.

### Example session

```bash
git hack "add export CSV feature"

# implement with LLM assistance

git hack record          # or: git rap (stage all + commit + push in one step)
git hack record

git hack propose         # PR created and opened

# merge PR on GitHub

git hack done
```

This pairs well with repositories that use protected main branches, CI via pull requests, and changelog tools like [release-please](https://github.com/googleapis/release-please) or [semantic-release](https://semantic-release.gitbook.io).

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
curl -fsSL https://github.com/indemnity83/homebrew-git-hack/releases/download/v0.0.0/git-hack -o /tmp/git-hack
echo "PLACEHOLDER  /tmp/git-hack" | shasum -a 256 -c
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

**Install git aliases** (optional but recommended):

```bash
git hack init
```

This adds shortcuts like `git record`, `git pr`, etc. to your `~/.gitconfig`.

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

### `git hack record [-a] [-c] [-p]`

Generates a commit message from your staged diff. If nothing is staged, offers to run `git add -p`. You can accept, edit, or cancel before the commit is made.

```bash
git hack record              # commit staged changes with AI-generated message
git hack record -a           # stage all changes first (git add -A)
git hack record -p           # push after committing
git hack record -a -p        # stage all, commit, and push
git hack record -c           # conventional commit prefix (feat:, fix:, …)
```

Also available as `git record` and `git rap` (stage all + commit + push) after running `git hack init`.

### `git hack propose`

Creates or updates a GitHub PR for the current branch using `git town propose`. Generates a conventional-commit title and a release-notes-style body from your commits, diff, and `CHANGELOG.md` (if present). Parent branch is read from git-town's tracking config.

```bash
git hack propose
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

### `git hack done`

Verifies the current branch has been merged into main, then deletes it locally and remotely, switches to main, and pulls the latest.

```bash
git hack done
```

Also available as `git done` after running `git hack init`.

### `git hack init`

Installs optional git aliases into your global `~/.gitconfig`. Run once after installing `git-hack`.

```bash
git hack init
```

With `fzf`: TAB to multi-select aliases, ENTER to confirm. Without `fzf`: numbered list, enter numbers or `all`.

Aliases installed:

| Alias | Expands to |
|-------|-----------|
| `git record` | `git hack record` |
| `git rap` | `git hack record -a -p` |
| `git pr` | `git hack propose` |
| `git propose` | `git hack propose` |
| `git pick` | `git hack pick` |
| `git done` | `git hack done` |
