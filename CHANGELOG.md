# Changelog

## [0.1.3](https://github.com/Indemnity83/homebrew-git-hack/compare/v0.1.2...v0.1.3) (2026-03-23)


### Features

* add --no-verify flag to commit command ([#22](https://github.com/Indemnity83/homebrew-git-hack/issues/22)) ([bdaaee7](https://github.com/Indemnity83/homebrew-git-hack/commit/bdaaee75db6ce51888eea4d56cab07121728dea1))

## [0.1.2](https://github.com/Indemnity83/homebrew-git-hack/compare/v0.1.1...v0.1.2) (2026-03-16)


### Features

* add ship command for combined commit and propose functionality ([#21](https://github.com/Indemnity83/homebrew-git-hack/issues/21)) ([84f13e8](https://github.com/Indemnity83/homebrew-git-hack/commit/84f13e84b7a753e285623fbfc16ba860adeba8c8))


### Refactoring

* rename record command to commit and adjust aliases ([#19](https://github.com/Indemnity83/homebrew-git-hack/issues/19)) ([b89467a](https://github.com/Indemnity83/homebrew-git-hack/commit/b89467a55d7597a272f2d59c10f72317dae4944a))

## [0.1.1](https://github.com/Indemnity83/homebrew-git-hack/compare/v0.1.0...v0.1.1) (2026-03-08)


### Bug Fixes

* change llm dependency to use native version ([#17](https://github.com/Indemnity83/homebrew-git-hack/issues/17)) ([54b66a3](https://github.com/Indemnity83/homebrew-git-hack/commit/54b66a3717158db9174b3e46e284c13bb86aa932))

## 0.1.0 (2026-03-08)


### Features

* add changelog sections to release-please configuration ([#10](https://github.com/Indemnity83/homebrew-git-hack/issues/10)) ([449c4a3](https://github.com/Indemnity83/homebrew-git-hack/commit/449c4a3895da2239298a745b165d9e2f20ee8057))
* add support for multiple command flags and auto confirmation ([#11](https://github.com/Indemnity83/homebrew-git-hack/issues/11)) ([93cfc4e](https://github.com/Indemnity83/homebrew-git-hack/commit/93cfc4ef4f80cbcaaceb6655a798d035fca2b47d))
* enhance LLM prompts for better branch and commit generation ([#8](https://github.com/Indemnity83/homebrew-git-hack/issues/8)) ([b44ed49](https://github.com/Indemnity83/homebrew-git-hack/commit/b44ed4999972fd9b783650b7321b9171f35d0099))
* rename hack to git-hack and add git-hack script for Git workflows ([#1](https://github.com/Indemnity83/homebrew-git-hack/issues/1)) ([9b406a9](https://github.com/Indemnity83/homebrew-git-hack/commit/9b406a9dc2d28a9a444b48c17229127747bd60d1))
* rename snapshot and port commands to record and pick ([#6](https://github.com/Indemnity83/homebrew-git-hack/issues/6)) ([6ad5f74](https://github.com/Indemnity83/homebrew-git-hack/commit/6ad5f74babe441165c64d5d85444902878e2b2eb))


### Bug Fixes

* correct help text alignment for cherry-pick command ([#14](https://github.com/Indemnity83/homebrew-git-hack/issues/14)) ([c21ed9b](https://github.com/Indemnity83/homebrew-git-hack/commit/c21ed9bfe203ab6e2c2dddaa7fd4d1f0f0501b91))
* remove stray test comments from git-hack and utils.zsh ([#13](https://github.com/Indemnity83/homebrew-git-hack/issues/13)) ([9f123d6](https://github.com/Indemnity83/homebrew-git-hack/commit/9f123d6cee01a4581479447219ba22755f33d7fb))
* require llm and git-town for main git-hack commands ([#15](https://github.com/Indemnity83/homebrew-git-hack/issues/15)) ([eb0414f](https://github.com/Indemnity83/homebrew-git-hack/commit/eb0414f1fed54aaef06f69438117db974d35197a))
* sync process in done command for merged PR branches ([#7](https://github.com/Indemnity83/homebrew-git-hack/issues/7)) ([2e9db5a](https://github.com/Indemnity83/homebrew-git-hack/commit/2e9db5aca3c40c1b6c1069051dc99e692d539111))
* update command prefixes and descriptions in git-hack script ([4423843](https://github.com/Indemnity83/homebrew-git-hack/commit/4423843374e21f84f5a8806f4dd88fa1286351fc))
* update formula and README in release PR workflow ([#5](https://github.com/Indemnity83/homebrew-git-hack/issues/5)) ([1fe242f](https://github.com/Indemnity83/homebrew-git-hack/commit/1fe242fe71e27a4289bca32bc1a280bc9fcca6bc))


### Refactoring

* improve GitHub issue branch name generation logic ([#16](https://github.com/Indemnity83/homebrew-git-hack/issues/16)) ([611dcc6](https://github.com/Indemnity83/homebrew-git-hack/commit/611dcc644fc70e71f0544b2dff80c1f6cfcbc5fa))
* simplify branch deletion logic in cmd_done function ([29ddb28](https://github.com/Indemnity83/homebrew-git-hack/commit/29ddb28ce1c0a8c889e52b2948b0901956cbff3d))
* update cmd_done to use fetch with --prune option ([#9](https://github.com/Indemnity83/homebrew-git-hack/issues/9)) ([1853afa](https://github.com/Indemnity83/homebrew-git-hack/commit/1853afafd54c50f7f756b6de4583eaa5459c4fa9))
* update README and CLAUDE.md to reflect repo name change to git-hack ([#2](https://github.com/Indemnity83/homebrew-git-hack/issues/2)) ([6ee622b](https://github.com/Indemnity83/homebrew-git-hack/commit/6ee622b0f0db95e954653a03f49e850e8f20baf7))


### Chore

* rename snapshot command to record and update documentation ([#12](https://github.com/Indemnity83/homebrew-git-hack/issues/12)) ([8228451](https://github.com/Indemnity83/homebrew-git-hack/commit/82284518e9f1d644436638e7075e73915b023c1c))
* setup Homebrew installation and GitHub Actions for the hack repo ([#3](https://github.com/Indemnity83/homebrew-git-hack/issues/3)) ([9c9b3ed](https://github.com/Indemnity83/homebrew-git-hack/commit/9c9b3ed15dfc036d84aa10bf93a4b4c679dfce01))
