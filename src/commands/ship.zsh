# SUBCOMMAND: ship — commit then propose in one step
cmd_ship() {
  need_cmd llm
  need_cmd git-town

  local stage_all=0 conventional=0 draft=0 auto_yes=0 model=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)          stage_all=1; shift ;;
      --conventional) conventional=1; shift ;;
      --draft)        draft=1; shift ;;
      --yes)          auto_yes=1; shift ;;
      --model)        model="$2"; shift 2 ;;
      -m)             model="$2"; shift 2 ;;
      --)             shift; break ;;
      -*)
        local flags="${1:1}"; shift
        for (( i=1; i<=${#flags}; i++ )); do
          case "${flags[i]}" in
            a) stage_all=1 ;;
            c) conventional=1 ;;
            d) draft=1 ;;
            y) auto_yes=1 ;;
            m) die "-m requires an argument; use -m <model> as a standalone flag" ;;
            *) die "Unknown option: -${flags[i]}" ;;
          esac
        done
        ;;
      *) die "Unknown option: $1" ;;
    esac
  done

  local commit_args=() propose_args=()
  [[ $stage_all -eq 1 ]]    && commit_args+=(-a)
  [[ $conventional -eq 1 ]] && commit_args+=(-c)
  [[ $auto_yes -eq 1 ]]     && commit_args+=(-y)
  [[ -n "$model" ]]         && commit_args+=(-m "$model")

  [[ $draft -eq 1 ]]    && propose_args+=(-d)
  [[ $auto_yes -eq 1 ]] && propose_args+=(-y)
  [[ -n "$model" ]]     && propose_args+=(-m "$model")

  cmd_commit "${commit_args[@]}"
  cmd_propose "${propose_args[@]}"
}
