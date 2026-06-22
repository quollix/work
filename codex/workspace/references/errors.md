# Errors

## Error creation

- Do not create ad-hoc errors for internal application logic as the project convention is `u.Logger.NewError(...)` using the `u github.com/quollix/common/utils` library.
- For new internal errors use:
  - `u.Logger.NewError("static error")`
  - `u.Logger.NewError("static error", "key", value)`
- Wrap errors from external modules before passing them up:
  - `return u.Logger.NewError(err.Error())`

## Logging

- Errors and logging should follow the `deepstack` library conventions.
