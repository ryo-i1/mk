#!/usr/bin/env bash

# lib/common.sh
# Common helper functions for install/uninstall scripts.

##################################################
# Logging
##################################################

log() {
    printf '[INFO] %s\n' "$@"
}

warn() {
    printf '[WARN] %s\n' "$@" >&2
}

error() {
    printf '[ERROR] %s\n' "$@" >&2
    exit 1
}


##################################################
# Checks
##################################################

require_file() {
    local path="$1"
    if [[ ! -f "${path}" ]]; then
        error "file not found: ${path}"
    fi
}

require_dir() {
    local path="$1"
    if [[ ! -d "${path}" ]]; then
        error "directory not found: ${path}"
    fi
}


##################################################
# Directory utilities
##################################################

ensure_dir() {
    local path="$1"
    mkdir -p "${path}"
    log "ensure dir: ${path}"
}


##################################################
# Symlink utilities
##################################################

safe_ln_sfn() {
    local src="$1"
    local dst="$2"

    if [[ ! -e "${src}" && ! -L "${src}" ]]; then
        error "source not found: ${src}"
    fi

    if [[ -L "${dst}" ]]; then
        local current
        current="$(readlink "${dst}")"
        if [[ "${current}" == "${src}" ]]; then
            log "skip: already linked: ${dst} -> ${src}"
            return
        fi
    elif [[ -e "${dst}" ]]; then
        error "destination already exists and is not a symlink: ${dst}"
    fi

    ln -sfn "${src}" "${dst}"
    log "linked: ${dst} -> ${src}"
}

remove_if_same_link() {
    local src="$1"
    local dst="$2"

    if [[ -L "${dst}" ]]; then
        local current
        current="$(readlink "${dst}")"
        if [[ "${current}" == "${src}" ]]; then
            rm "${dst}"
            log "removed: ${dst}"
            return
        fi
        warn "skip: symlink target differs: ${dst} -> ${current}"
        return
    fi

    if [[ -e "${dst}" ]]; then
        warn "skip: not a symlink: ${dst}"
        return
    fi

    log "skip: not found: ${dst}"
}


##################################################
# Install helpers
##################################################

install_link() {
    local src="$1"
    local dst="$2"

    local dst_dir
    dst_dir="$(dirname "${dst}")"

    ensure_dir "${dst}_dir"
    safe_ln_sfn "${src}" "${dst}"
}

uninstall_link() {
    local src="$1"
    local dst="$2"

    remove_if_same_link "${src}" "${dst}"
}
