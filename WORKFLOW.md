

# Ideal Development Workflow with `git hack` and Release Please

This document describes an opinionated workflow for developing software using **AI-assisted coding tools**, while maintaining **excellent Git hygiene**, **clean pull requests**, and **automated changelogs**.

The workflow combines:

- `git hack` — a CLI tool that uses LLMs to assist with branch naming, commits, and PR generation
- GitHub pull request workflows
- a protected `main` branch
- **Google's `release-please`** for automated release management and changelog generation

The goal is to enable **fast iteration with AI tools** without sacrificing the long-term maintainability of your repository.

---

# Core Philosophy

Modern development increasingly involves coding with AI assistants such as:

- Claude
- Codex / GPT
- Cursor
- Continue
- Copilot

These tools can generate large amounts of code quickly. However, they can also encourage poor git practices such as:

- giant commits
- messy commit messages
- unclear pull requests
- noisy commit history

This workflow solves that problem by separating development into two layers:

**Branch history**
- records development progress
- contains multiple small commits
- optimized for iteration

**Main branch history**
- contains clean squash commits
- uses conventional commit messages
- optimized for releases and changelogs

---

# Repository Setup

The workflow assumes the following repository configuration.

## Protected Main Branch

The `main` branch should be protected so that:

- direct pushes are disabled
- pull requests are required
- CI must pass before merging

Example GitHub protection rules:

- Require pull request before merging
- Require status checks
- Require up-to-date branch
- Restrict direct pushes

This ensures that all changes flow through PRs.

---

## Release Please

`release-please` is used to automate versioning and changelogs.

It works by scanning commit history on `main` for **Conventional Commit messages**, such as:

```text
feat(ui): add print button to reports
fix(api): handle missing auth token
chore: update dependencies
```

When changes accumulate, release-please:

1. opens a release PR
2. generates a changelog
3. updates version numbers
4. creates GitHub releases after merging

Because of this, **PR titles become extremely important**, since squash merging uses them as the final commit message.

`git hack` helps generate those titles automatically.

---

# The Development Loop

The complete development cycle looks like this:

```text
idea → hack → record → propose → merge → done
```

Each stage is supported by a `git hack` command.

---

# 1. Start an Idea

Begin by describing the change you want to make.

```bash
git hack idea "add a new button to the main UI to allow the user to print a report"
```

The tool sends the description to an LLM and proposes a branch name such as:

```text
feat/add-print-report-button
```

If accepted:

- the branch is created
- it is checked out automatically

You are now working on an isolated feature branch.

---

# 2. Hack on the Feature

At this point you open your coding assistant (Claude, Codex, etc.) and begin implementing the change.

Example prompt:

```text
Add a print button to the report view that sends the report to the browser print dialog.
```

You may iterate several times while refining the implementation.

The goal is to move quickly during this phase.

---

# 3. Record Development Progress

When you reach a meaningful checkpoint, record a commit.

```bash
git add .
git hack record
```

If nothing is staged, `git hack record` automatically launches:

```bash
git add -p
```

This allows you to interactively stage only the changes you want.

The staged diff is sent to an LLM which generates a short **imperative commit message** such as:

```text
Add print button to report UI
```

These messages are intentionally simple and **not conventional commits**. They exist only to document the branch development process.

You may repeat this step as often as needed.

Example:

```bash
git hack record
git hack record
git hack record
```

This creates a clear narrative of how the feature evolved.

---

# 4. Propose the Pull Request

When the feature is complete, generate a pull request.

```bash
git hack propose
```

This command compares your branch to `main` and sends the full diff to an LLM.

The model generates:

- a **Conventional Commit PR title**
- a **summary-style PR body**

Example output:

```text
feat(ui): add print button for reports
```

PR body:

```text
Adds a print button to the report view so users can quickly print reports.

Changes include:
- new UI button
- report print handler
- layout adjustments
```

If accepted, the tool:

1. creates the pull request
2. opens it in your browser

---

# 5. CI and Review

Once the PR exists:

- CI workflows run
- tests validate the changes
- reviewers can inspect the PR

Because the branch may contain several commits, reviewers can see how the implementation evolved.

---

# 6. Squash Merge

After CI passes, the PR is **squash merged**.

This is important.

Squash merging ensures that:

- the PR title becomes the final commit message
- the main branch history remains clean
- release-please receives properly formatted conventional commits

Example final commit on `main`:

```text
feat(ui): add print button for reports
```

---

# 7. Clean Up

After merging, return to your terminal and run:

```bash
git hack done
```

This command:

- verifies the branch was merged
- deletes the remote branch
- deletes the local branch
- switches back to `main`
- updates `main` from the remote

Your repository is now ready for the next feature.

---

# Resulting Git History

This workflow produces two useful histories.

## Feature Branch History

```text
Add print button to report UI
Adjust report layout
Fix print handler bug
```

These commits document development progress.

## Main Branch History

```text
feat(ui): add print button for reports
fix(auth): handle expired tokens
feat(api): add export endpoint
```

These commits are clean, structured, and perfect for changelog generation.

---

# Why This Workflow Works

This system balances **speed** and **discipline**.

Benefits include:

- fast AI-assisted development
- structured git history
- clean pull requests
- automated changelogs
- predictable releases

It allows developers to move quickly without sacrificing repository quality.

---

# Example End-to-End Session

```bash
git hack idea "add CSV export to reports"

# implement feature with AI

git add .
git hack record

git add .
git hack record

git hack propose

# PR created and opened

# after CI passes, squash merge in GitHub

git hack done
```

You are now ready to start the next idea.

---

# Summary

`git hack` turns AI-assisted development into a disciplined git workflow.

By combining:

- fast iteration
- structured pull requests
- squash merges
- release-please automation

you get the best of both worlds:

**rapid development and clean project history.**
