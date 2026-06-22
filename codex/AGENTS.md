## Scope

- These instructions apply to all projects under `~/Documents/workspace`.
- This file governs agent behavior and change control only.
- Put project engineering conventions in `codex/workspace/references/*`, not in this file.
- In general, it is a good idea to learn from existing code of the repository to get more context on how to code expected to be designed.
- Have a mindset of simplification: how we could remove unnecessary code elements or merge existing functionality. Do not automatically assume each line of code is needed. We rather seek for lean design. Propose simplification ideas when you happen to encounter any during work.

## Safety

- If instructions conflict, this change-control section takes precedence.
- Never run bash scripts directly as part of the task.
- Never run the `src/ci-runner` tool if it is present in the project, except you asked for permission and it was accepted.
- In order to verify your writing it to the files, you can use:
  - syntax checkers like `bash -n` or `go fmt`
  - build command: `go build`
  - unit tests: `go test ./...`
  - but never run tests with specific build tags as they will always fail in your environment
  - Never generate compiled test binaries (for example `*.test`) as part of verification.
- Never edit `wire_gen.go` or `*_mock.go` files. Rather generate them via the associated tools provided, see 'workspace' skill.

## Shared Skill

- For coding work under `~/Documents/workspace`, use the shared `workspace` skill.

## Available Container Tools

`git`, `rg`, `go`, `node`, `npm`, `sqlite3`, `jq`, `yq`, `fd`, `bat`, `tree`, `shellcheck`, `shfmt`, `gofumpt`, `staticcheck`, `git-delta`, `gh`, `ssh`/`scp`/`sftp`, `rsync`,`curl`

## Change Control Exception

- The agent is allowed to edit `AGENTS.md` files under `~/Documents/workspace`.
- The agent is allowed to edit the shared workspace skill files under `~/Documents/workspace/work/codex/workspace/`.
