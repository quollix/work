#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORK_NVM_VERSION="v0.40.4"
readonly NODE_VERSION="v22.22.1"
readonly GOPLS_VERSION="v0.20.0"
readonly GOIMPORTS_VERSION="v0.42.0"
readonly TYPESCRIPT_VERSION="5.8.3"
readonly TYPESCRIPT_LANGUAGE_SERVER_VERSION="4.4.0"
readonly VSCODE_LANGSERVERS_EXTRACTED_VERSION="4.10.0"
readonly CODEX_IMAGE_TAG="work-codex:local"
readonly NVM_DIR="$HOME/.nvm"
readonly BASHRC_TARGET="$HOME/.bashrc"
readonly SKIP_EXTERNAL_ACCESS="${1:-}"

log() {
    echo "[work-setup] $1"
}

run_with_optional_sudo() {
    local target_path="$1"
    shift

    if [ -e "$target_path" ] || [ -L "$target_path" ] || [ -w "$(dirname "$target_path")" ]; then
        "$@"
    else
        sudo "$@"
    fi
}

readlink_with_optional_sudo() {
    local target_path="$1"

    if [ -L "$target_path" ] || [ -w "$(dirname "$target_path")" ]; then
        readlink "$target_path"
    else
        sudo readlink "$target_path"
    fi
}

ensure_link() {
    local source_path="$1"
    local target_path="$2"

    run_with_optional_sudo "$target_path" mkdir -p "$(dirname "$target_path")"

    if [ -L "$target_path" ]; then
        if [ "$(readlink_with_optional_sudo "$target_path")" = "$source_path" ]; then
            log "unchanged symlink: $target_path"
            return
        fi
        log "refusing to overwrite foreign symlink: $target_path"
        exit 1
    fi

    if [ -e "$target_path" ]; then
        log "refusing to overwrite existing path: $target_path"
        exit 1
    fi

    run_with_optional_sudo "$target_path" ln -s "$source_path" "$target_path"
    log "linked: $target_path -> $source_path"
}

ensure_bashrc_source_line() {
    local source_path="$1"
    local source_line

    touch "$BASHRC_TARGET"
    source_line="[ -f \"$source_path\" ] && . \"$source_path\""

    if grep -Fqx "$source_line" "$BASHRC_TARGET"; then
        log "unchanged: $BASHRC_TARGET"
        return
    fi

    printf '\n%s\n' "$source_line" >> "$BASHRC_TARGET"
    log "updated: $BASHRC_TARGET"
}

apt_cache_is_stale() {
    if [ ! -d /var/lib/apt/lists ]; then
        return 0
    fi

    find /var/lib/apt/lists -maxdepth 1 -name "*_InRelease" -mtime +1 | grep -q .
}

install_apt_packages() {
    if apt_cache_is_stale; then
        log "updating apt package index"
        sudo apt update
    else
        log "apt package index is fresh enough"
    fi

    log "ensuring apt packages are installed"
    sudo apt install -y wl-clipboard tmux ripgrep fd-find
}

get_installed_helix_version() {
    if ! command -v hx >/dev/null 2>&1; then
        return 1
    fi

    hx --version | awk 'NR == 1 { print $2 }'
}

get_latest_helix_version() {
    curl -fsSL "https://api.github.com/repos/helix-editor/helix/releases/latest" \
        | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
        | head -n 1
}

install_helix_release() {
    local version="$1"
    local archive_name="helix-${version}-x86_64-linux.tar.xz"
    local download_url="https://github.com/helix-editor/helix/releases/download/${version}/${archive_name}"
    local temp_dir

    temp_dir="$(mktemp -d)"
    trap 'rm -rf "$temp_dir"' RETURN

    log "installing helix ${version}"
    curl -fsSL "$download_url" -o "${temp_dir}/${archive_name}"
    tar -xJf "${temp_dir}/${archive_name}" -C "$temp_dir"

    sudo install -m755 "${temp_dir}/helix-${version}-x86_64-linux/hx" /usr/local/bin/hx

    rm -rf "$HOME/.config/helix/runtime"
    mkdir -p "$HOME/.config/helix"
    cp -R "${temp_dir}/helix-${version}-x86_64-linux/runtime" "$HOME/.config/helix/runtime"
}

ensure_helix() {
    local installed_version=""
    local latest_version=""

    latest_version="$(get_latest_helix_version)"

    if [ -z "$latest_version" ]; then
        log "failed to determine latest helix version"
        return 1
    fi

    if installed_version="$(get_installed_helix_version)" && [ "$installed_version" = "$latest_version" ]; then
        log "helix ${latest_version} already installed"
        return
    fi

    install_helix_release "$latest_version"
}

load_nvm() {
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

install_nvm_if_missing() {
    local installer_path

    if [ -s "$NVM_DIR/nvm.sh" ]; then
        log "nvm already installed"
        return
    fi

    log "installing nvm $WORK_NVM_VERSION"
    installer_path="$(mktemp)"
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${WORK_NVM_VERSION}/install.sh" -o "$installer_path"
    PROFILE=/dev/null bash "$installer_path"
    rm -f "$installer_path"
}

ensure_node_version() {
    load_nvm

    if [ "$(nvm version "$NODE_VERSION")" = "N/A" ]; then
        log "installing node $NODE_VERSION"
        nvm install "$NODE_VERSION"
    else
        log "node $NODE_VERSION already installed"
    fi

    nvm alias default "$NODE_VERSION" >/dev/null
    nvm use --silent "$NODE_VERSION" >/dev/null
}

remove_old_node_versions() {
    local version
    local resolved_target_version

    load_nvm
    resolved_target_version="$(nvm version "$NODE_VERSION")"

    while IFS= read -r version; do
        case "$version" in
            ""|"N/A"|"system")
                continue
                ;;
        esac

        if [ "$version" = "$resolved_target_version" ]; then
            continue
        fi

        log "removing node $version"
        nvm uninstall "$version"
    done < <(nvm ls --no-colors | sed -n 's/^[[:space:]]*->\{0,1\}[[:space:]]*\(v[0-9][^[:space:]]*\).*/\1/p' | sort -u)
}

ensure_go_tool() {
    local binary_name="$1"
    local package_path="$2"
    local version="$3"

    if command -v "$binary_name" >/dev/null 2>&1; then
        if go version -m "$(command -v "$binary_name")" 2>/dev/null | grep -Fq "$version"; then
            log "$binary_name $version already installed"
            return
        fi
    fi

    log "installing $binary_name $version"
    go install "${package_path}@${version}"
}

ensure_npm_global_package() {
    local package_name="$1"
    local version="$2"
    local package_json
    local installed_version

    package_json="$(npm root -g)/${package_name}/package.json"

    if [ -f "$package_json" ]; then
        installed_version="$(node -p "require(process.argv[1]).version" "$package_json")"
        if [ "$version" = "latest" ] || [ "$installed_version" = "$version" ]; then
            log "$package_name $version already installed"
            return
        fi
    fi

    log "installing $package_name $version"
    npm install -g "${package_name}@${version}"
}

ensure_codex_container_image() {
    local docker_context_directory

    docker_context_directory="$SCRIPT_DIR/resources/docker/codex-ubuntu"

    log "building docker image $CODEX_IMAGE_TAG"
    docker build -t "$CODEX_IMAGE_TAG" "$docker_context_directory"
}

if [ "$SKIP_EXTERNAL_ACCESS" = "-s" ]; then
    log "skipping network-dependent installs because -s was used"
else
    install_apt_packages
    ensure_helix
    install_nvm_if_missing
    ensure_node_version
    remove_old_node_versions

    ensure_go_tool "gopls" "golang.org/x/tools/gopls" "$GOPLS_VERSION"
    ensure_go_tool "goimports" "golang.org/x/tools/cmd/goimports" "$GOIMPORTS_VERSION"

    ensure_npm_global_package "typescript" "$TYPESCRIPT_VERSION"
    ensure_npm_global_package "typescript-language-server" "$TYPESCRIPT_LANGUAGE_SERVER_VERSION"
    ensure_npm_global_package "vscode-langservers-extracted" "$VSCODE_LANGSERVERS_EXTRACTED_VERSION"
fi

ensure_codex_container_image

ensure_link "$SCRIPT_DIR/resources/work" "/usr/local/bin/work"
ensure_link "$SCRIPT_DIR/resources/config.toml" "$HOME/.config/helix/config.toml"
ensure_link "$SCRIPT_DIR/resources/languages.toml" "$HOME/.config/helix/languages.toml"
ensure_link "$SCRIPT_DIR/resources/tmux.conf" "$HOME/.tmux.conf"
ensure_bashrc_source_line "$SCRIPT_DIR/resources/bashrc.work"

. ~/.bashrc
