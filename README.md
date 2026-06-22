# Work

This repository consists of:

1. **Coding conventions**: the Quollix project development conventions documented under `codex/`, also used by our AI tools as guidelines. Contributors should read them, but can ignore all other files in this repository.
2. **Work setup**: my personal, opinionated programming workspace setup centered on tmux, Helix and codex, along with shell tooling for starting project sessions quickly. This is only of interest to you if you want the same workflow and tooling or an inspiration for your own workspace setup.

## Work Setup

### Installation

Run the installation script once:

```bash
bash work-setup.sh
```

Clone repositories to `~/Documents/workspace`, such as `~/Documents/workspace/myproject`.

Open a work session:

```bash
work myproject
```

Terminate the current work session from the tmux session shell:

```bash
tx
```

Switch to another work session and terminate the current one:

```bash
tx store
```

### Work Setup Design Goals

This setup assumes a standard Ubuntu Desktop installation, which is a common baseline for developer machines.

* A single setup script installs the required tools and applies sensible default configuration.
* The setup script is idempotent and fast to rerun. It skips steps that were already completed, which makes it easier to maintain.
* The setup script keeps the development environment consistent across devices.
* A work session for a project can be opened with the 'work' command. This starts a tmux session with three windows: helix, shell, and codex.
* The `codex` tmux window runs inside an Ubuntu Docker container. This keeps Codex more isolated from the host while still giving it access to the workspace it needs. Go and Codex updates are persisted and be shared across project sessions. When the `codex` process exits, the container stays open in an interactive shell so you can continue working inside it.
* Shell completion makes it quick to discover projects or open available sessions.
* Bash aliases and shell functions reduce friction for common commands and recurring workflows.
* Helix is configured to automatically write buffered file edits so that the other tmux windows see the latest on-disk file contents.

### Tools

* `wl-clipboard` integrates the editor with the system clipboard, for example through `Space + y` and `Space + p`.
* `ripgrep` (`rg`) provides fast full-text search across projects through `Space + /`.

## Contributing

Please read the [Community](https://quollix.org/docs/community/) articles for more information on how to contribute to the project.

## License

This project is licensed under the [MIT License](https://opensource.org/license/mit). See the [LICENSE](LICENSE) file for details.
