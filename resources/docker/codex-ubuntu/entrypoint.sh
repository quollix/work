#!/usr/bin/env bash
set -euo pipefail

homeDirectory="${HOME:-/home/work}"
sharedToolsRoot="${SHARED_TOOLS_ROOT:-/opt/work-tools}"
sharedToolsBinDirectory="$sharedToolsRoot/bin"
npmPrefixDirectory="${NPM_CONFIG_PREFIX:-$sharedToolsRoot/npm-global}"
npmCacheDirectory="${NPM_CONFIG_CACHE:-$sharedToolsRoot/npm-cache}"
goPathDirectory="${GOPATH:-$sharedToolsRoot/go-path}"
goModCacheDirectory="${GOMODCACHE:-$goPathDirectory/pkg/mod}"
goBuildCacheDirectory="${GOCACHE:-$sharedToolsRoot/go-build-cache}"
imageNpmPrefixDirectory="/opt/image-tools/npm-global"
runtimeUid="${WORK_UID:-1000}"
runtimeGid="${WORK_GID:-1000}"

ensure_owned_directory() {
    local path="$1"

    mkdir -p "$path"
    chown "$runtimeUid:$runtimeGid" "$path"
}

ensure_owned_tree() {
    local path="$1"
    local currentOwnership

    mkdir -p "$path"
    currentOwnership="$(stat -c '%u:%g' "$path")"
    if [ "$currentOwnership" != "$runtimeUid:$runtimeGid" ]; then
        chown -R "$runtimeUid:$runtimeGid" "$path"
    fi
}

ensure_owned_file() {
    local path="$1"
    local currentOwnership

    if [ ! -e "$path" ]; then
        return
    fi

    currentOwnership="$(stat -c '%u:%g' "$path")"
    if [ "$currentOwnership" != "$runtimeUid:$runtimeGid" ]; then
        chown "$runtimeUid:$runtimeGid" "$path"
    fi
}

mkdir -p \
    "$sharedToolsBinDirectory" \
    "$npmCacheDirectory" \
    "$goPathDirectory/bin" \
    "$goModCacheDirectory" \
    "$goBuildCacheDirectory"

directory_is_empty() {
    local path="$1"

    [ -z "$(find "$path" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]
}

seed_shared_directory() {
    local targetPath="$1"
    local sourcePath="$2"

    if [ ! -e "$sourcePath" ]; then
        return
    fi

    if [ ! -e "$targetPath" ]; then
        cp -a "$sourcePath" "$targetPath"
        return
    fi

    # Docker creates volume mount points as empty directories, so seed bundled tools when the target exists but has not been populated yet.
    if [ -d "$targetPath" ] && [ -d "$sourcePath" ] && directory_is_empty "$targetPath"; then
        cp -a "$sourcePath"/. "$targetPath"/
    fi
}

# /opt/work-tools is a writable volume, so copy the image-bundled tool installs into it on first run and expose stable bin symlinks from the shared bin dir.
seed_shared_directory "$npmPrefixDirectory" "$imageNpmPrefixDirectory"

ensure_owned_directory "$homeDirectory"
ensure_owned_directory "$homeDirectory/.codex"
ensure_owned_tree "$homeDirectory/.cache"
ensure_owned_tree "$homeDirectory/.local"
ensure_owned_tree "$sharedToolsRoot"

ln -sfn ../npm-global/bin/codex "$sharedToolsBinDirectory/codex"

export PATH="$sharedToolsBinDirectory:$npmPrefixDirectory/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export GOPATH="$goPathDirectory"
export GOBIN="$sharedToolsBinDirectory"
export GOCACHE="$goBuildCacheDirectory"
export GOTOOLCHAIN="${GOTOOLCHAIN:-auto}"
export NPM_CONFIG_UPDATE_NOTIFIER=false
unset GOROOT
unset GOTOOLDIR

# Keep npm global installs in the writable shared tools volume so Codex auto-update works without root.
export NPM_CONFIG_PREFIX="$npmPrefixDirectory"
export NPM_CONFIG_CACHE="$npmCacheDirectory"

set +e
setpriv --reuid "$runtimeUid" --regid "$runtimeGid" --clear-groups codex "$@"
codexExitCode="$?"
set -e

printf '\nCodex exited with status %s. Starting interactive shell.\n' "$codexExitCode"
exec setpriv --reuid "$runtimeUid" --regid "$runtimeGid" --clear-groups bash -l
