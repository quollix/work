# Taskrunner

- Use `Tr.Cmd().Run(...)` for command execution.
- Chain `Dir(...)`, `Env(...)`, `AllowFail()`, and `AsDaemon(...)` directly on `Tr.Cmd()` when needed.
- `Run(...)` supports format arguments, for example `Tr.Cmd().Run("docker pull %s", image)`.
- Use `Tr.File` for file operations, for example `Tr.File.Copy("%s", src).To("%s", dst)` and `Tr.File.Remove("%s", path)`.
- Prefer direct `Tr.Cmd()` and `Tr.File` usage in code for clarity.
