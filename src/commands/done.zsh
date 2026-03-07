# SUBCOMMAND: done
cmd_done() {
  need_cmd git-town
  info "Syncing with remote and cleaning up merged branches..."
  git town sync
}
