# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`git-hack` is a Zsh CLI utility that augments git workflows with AI assistance via the `llm` CLI and `git-town` for branch management. It automates branch creation, commit message generation, and GitHub PR creation.

`git-hack` is a **generated file** — the source of truth is `src/`. Do not edit `git-hack` directly.

## Build System

```bash
make              # rebuild git-hack from src/
make check        # zsh -n syntax-check every source file
make test         # run the test suite
make install-hooks  # one-time: activate the pre-commit hook (per clone)
```

The pre-commit hook (`.githooks/pre-commit`) fires automatically when `src/` files are staged. It runs `make check`, `make test`, and `make`, then stages the rebuilt `git-hack`.

## Running

```bash
git hack --help
git hack "my feature idea"   # defaults to idea subcommand
git-hack --help              # equivalent direct invocation
```

## Configuration

No hack-specific config needed. Branch tracking is handled by git-town:

```bash
git town config setup   # one-time per repo
```

LLM model selection is handled by the `llm` CLI:

```bash
llm models           # list available models
llm -m claude-3-5-sonnet-latest ...   # use a specific model
```

## Architecture

Source lives in `src/`, concatenated by the Makefile into the single-file `git-hack` distributable.

```
src/
  header.zsh          # shebang, constants
  utils.zsh           # die/info/ok, git basics, truncate_str, prompt_choice, sanitize_branch_name
  git-helpers.zsh     # fzf helpers, default_base_branch
  changelog.zsh       # changelog_excerpt, last_release_tag
  commands/
    idea.zsh          # cmd_idea — branch name from free-text idea (llm + git town hack)
    issue.zsh         # cmd_issue — branch name from GitHub issue (gh + llm + git town hack)
    snapshot.zsh      # cmd_snapshot — commit message from staged diff (llm + git commit)
    propose.zsh       # cmd_propose — create/update GitHub PR (llm + git town propose)
    port.zsh          # cmd_port — cherry-pick with fzf selection
    done.zsh          # cmd_done — git town sync
    prune.zsh         # cmd_prune — git town prune
    init.zsh          # cmd_init — install global git aliases
  main.zsh            # main() dispatcher + help text
```

## Commands

| Command | Description |
|---------|-------------|
| `git hack ["idea"]` | Create feature branch; defaults to interactive idea mode |
| `git hack idea ["idea"]` | Explicit idea subcommand |
| `git hack issue <n>` | Branch from GitHub issue |
| `git hack snapshot [-c]` | AI commit message from staged diff |
| `git hack propose` | Create/update PR via git-town |
| `git hack port [sha] [branch]` | Cherry-pick a commit |
| `git hack done` | `git town sync` |
| `git hack prune` | `git town prune` |
| `git hack init` | Install global git aliases (git snap, git propose, …) |

## Tests

```
tests/
  assert.zsh              # assert_eq, assert_contains, assert_max_len, summarize
  test_utils.zsh          # sanitize_branch_name, truncate_str
  test_git_helpers.zsh    # default_base_branch (uses temp git repos)
```

Tests cover pure/mockable functions. Interactive `cmd_*` functions are not unit-tested.

## Key Dependencies

Required: `git`, `llm`, `git-town`, `zsh`
Optional (improve UX): `fzf` (interactive selection), `gh` (for `hack issue`)

## Aliases (via `git hack init`)

`git hack init` installs shortcuts into `~/.gitconfig`:

| Alias | Expands to |
|-------|-----------|
| `git snap` | `git-hack snapshot` |
| `git propose` | `git-hack propose` |
| `git port` | `git-hack port` |
| `git done` | `git-hack done` |
| `git prune` | `git-hack prune` |
| `git issue` | `git-hack issue` |
