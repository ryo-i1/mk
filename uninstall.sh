#!/usr/bin/env bash
set -euo pipefail

# mk/uninstall.sh

##################################################
# Paths
##################################################

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}" && pwd)"

source "${repo_root}/lib/common.sh"

# source (repo)
src_env="${repo_root}/env.zsh"
src_tex_core="${repo_root}/tex/core.mk"

# destination
dst_env="${HOME}/.zsh/rc.d/mk.zsh"
dst_tex_core="${HOME}/local/share/mk/tex/core.mk"


##################################################
# Main
##################################################

main() {
    log "Start uninstall mk"

    uninstall_link "${src_env}" "${dst_env}"
    uninstall_link "${src_tex_core}" "${dst_tex_core}"

    log "Done"
}

main "$@"
