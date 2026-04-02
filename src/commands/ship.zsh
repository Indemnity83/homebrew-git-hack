# SUBCOMMAND: ship — commit then propose in one step
cmd_ship() {
  need_cmd llm
  need_cmd git-town

  local stage_all=0 conventional=0 draft=0 auto_yes=0 no_verify=0 model="" to="" hint=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)          stage_all=1; shift ;;
      --conventional) conventional=1; shift ;;
      --draft)        draft=1; shift ;;
      --yes)          auto_yes=1; shift ;;
      --no-verify)    no_verify=1; shift ;;
      --to)           [[ $# -ge 2 ]] || die "--to requires an argument"
                      to="$2"; shift 2 ;;
      --model)        [[ $# -ge 2 ]] || die "--model requires an argument"
                      model="$2"; shift 2 ;;
      -m)             [[ $# -ge 2 ]] || die "-m requires an argument; use -m <model> as a standalone flag"
                      model="$2"; shift 2 ;;
      --)             shift; [[ $# -gt 0 ]] && hint="$1"; break ;;
      -*)
        local flags="${1:1}"; shift
        for (( i=1; i<=${#flags}; i++ )); do
          case "${flags[i]}" in
            a) stage_all=1 ;;
            c) conventional=1 ;;
            d) draft=1 ;;
            n) no_verify=1 ;;
            y) auto_yes=1 ;;
            m) die "-m requires an argument; use -m <model> as a standalone flag" ;;
            *) die "Unknown option: -${flags[i]}" ;;
          esac
        done
        ;;
      *)
        [[ -z "$hint" ]] || die "Unexpected argument: $1"
        hint="$1"; shift ;;
    esac
  done

  local commit_args=() propose_args=()
  [[ $stage_all -eq 1 ]]    && commit_args+=(-a)
  [[ $conventional -eq 1 ]] && commit_args+=(-c)
  [[ $no_verify -eq 1 ]]    && commit_args+=(-n)
  [[ $auto_yes -eq 1 ]]     && commit_args+=(-y)
  [[ -n "$model" ]]         && commit_args+=(-m "$model")

  [[ $draft -eq 1 ]]    && propose_args+=(-d)
  [[ $auto_yes -eq 1 ]] && propose_args+=(-y)
  [[ -n "$model" ]]     && propose_args+=(-m "$model")
  [[ -n "$to" ]]        && propose_args+=(--to "$to")
  [[ -n "$hint" ]]      && commit_args+=(-- "$hint")
  [[ -n "$hint" ]]      && propose_args+=(-- "$hint")

  cmd_commit "${commit_args[@]}"

  local branch
  branch="$(current_branch)"
  [[ -n "$branch" ]] || die "Detached HEAD; check out a branch first."

  # git-town has no publish/push subcommand, so we push directly.
  local remote
  remote="$(git config "branch.${branch}.remote" 2>/dev/null || true)"
  [[ -n "$remote" ]] || remote="origin"

  info "Pushing $branch to $remote..."
  git push --set-upstream "$remote" "$branch" || die "Failed to push branch to remote."

  cmd_propose "${propose_args[@]}"
}
