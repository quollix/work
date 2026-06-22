#!/usr/bin/env bash
set -euo pipefail

work_ensure_session() {
    local projectName="$1"
    local scriptDirectory="$2"
    local workspaceDirectory="$HOME/Documents/workspace"
    local projectDirectory="$workspaceDirectory/$projectName"
    local sessionTarget="=$projectName"
    local helixWindowName="helix"
    local shellWindowName="shell"
    local codexWindowName="codex"

    if [ ! -d "$projectDirectory" ]; then
        echo "repo does not exist in $workspaceDirectory: $projectName"
        return 1
    fi

    if tmux has-session -t "$sessionTarget" 2>/dev/null; then
        return 0
    fi

    tmux new-session -d -s "$projectName" -n "$shellWindowName" -c "$projectDirectory"
    tmux new-window -t "$sessionTarget" -n "$helixWindowName" -c "$projectDirectory"
    tmux send-keys -t "$sessionTarget":"$helixWindowName" "hx ." C-m
    tmux new-window -t "$sessionTarget" -n "$codexWindowName" -c "$projectDirectory" "$scriptDirectory/run-codex-container \"$projectName\""
    tmux select-window -t "$sessionTarget":"$shellWindowName"
}

work_enter_session() {
    local projectName="$1"
    local sessionTarget="=$projectName"

    # Inside tmux we switch client; outside tmux we attach from this terminal.
    if [ -n "${TMUX:-}" ]; then
        exec tmux switch-client -t "$sessionTarget"
    else
        exec tmux attach -t "$sessionTarget"
    fi
}
