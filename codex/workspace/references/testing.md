# Testing and mocking

## Test expectations

- Cover both happy paths and unhappy paths.
- Tests should cover all meaningful logic and code paths.
- It is not needed to write a unit test when, for example, a component test already covers this case. This way, we keep the test suite deduplicated and lean.
- Skip cases where the production code merely passes through an error with `return err`. Don't test this branch.
- Test dependency setup (see exampled.md): In unit tests, create a setup method that constructs all mocks, injects them into the object under test, and returns a test dependency object. That object should expose the system under test as well as each injected mock as fields. Each test can then call setup, define mock behavior directly, and execute the test.
- Tests that use the same values, should  share then as global constants or variables, for example:  `var leaseExpiresAt = time.Date(2026, 4, 1, 10, 0, 0, 0, time.UTC)`
- Naming convention: The test function name should include the name of the object under test, but the function name, for example: func TestValidate_EmptyInputReturnsError(t *testing.T) {...}
- Never use t.Helper(). Remove it, when you see it.

## Assertion policy

- Use `github.com/quollix/common/assert` for assertions.
- Do not use `github.com/stretchr/testify/assert` or `github.com/stretchr/testify/require` in tests.
- The desired way to assert deepstack errors is: `assert.Equal(t, expectedErrorMessageString, u.ExtractError(err))`
- In tests, avoid `.Once()` on mocks; prefer the existing setup helper plus deferred `AssertExpectationsOfMocks` style, which run the `AssertExpextions` method of each mock.

## Mock generation

- Never hand-write mocks for unit tests. Always use use generated `mockery` mocks by running `go tool mockery`.
- Before generating mocks, you might want to adpat `.mockery.yml` in these common locations:
  - `<project-root>/.mockery.yml`
  - `<project-root>/src/<sub-component>/.mockery.yml`
- All generated mock files must have the name suffix `_mock.go`.
- Function chains, specifically when defining mock behavior, should be in a single line and have no line breaks.

## Test types

- Unit tests verify a backend unit in isolation, usually with mocks for dependencies.
- Integration tests verify interaction with external systems such as file systems, databases, or external servers.
- Component tests run the full, dockerized application and verify exposed behavior through public HTTP or API requests.
- Acceptance tests also run a full setup like component tests, but verify user-facing frontend behavior with `Rod`. See `references/acceptance-testing.md` for strategy details.
- For AI agents: Do not make environment-dependent tests "pass" by adding skip logic for missing runtime dependencies such as Docker. Simply don't run these tests.

## Error assertions

- Use `references/errors.md` for error creation and logging conventions.
- For deepstack-style errors, use the project’s existing helpers such as `deepstack.AssertDeepStackError` or `u.ExtractError` where available.
