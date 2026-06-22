## Acceptance testing

The following guidance is only relevant if the current project includes acceptance tests.

- Use a layered structure:
  - Scenario layer: test cases should read like user behavior in the browser (for example login, click navigation, assert page content).
  - Technical layer: keep Rod-specific details (selectors, waits, page wiring, browser setup) in helper/page objects.
- For page navigation in tests, prefer helper methods such as `GoToInstalledAppsPage()` that encapsulate HTML element ids/selectors internally.
- In scenario tests, do not pass frontend paths into navigation helpers. Paths should only be referenced when explicitly asserting that navigation reached the expected destination.
- Keep acceptance scope focused on frontend behavior (navigation, page load/render, JavaScript interactions, redirects, visibility/messages).
- Component tests already verify feature/business correctness, so acceptance tests should prioritize: page loads, navigation flow, and frontend-triggered backend requests reflected in UI state (for example invite user, then verify user appears in rendered user list).
- For acceptance tests that mutate state, reset test data per test via the project reset/wipe endpoint. This should be done in `defer cleanup(t)` right after setup.
- Feel free to adapt files in `frontend` web resources folder to improve testability, including adding stable HTML ids/classes or similar selector hooks.
- Prefer stable selector hooks over positional parsing:
  - add explicit ids/classes or `data-*` attributes in frontend templates when needed for tests.
  - prefer row/element selectors like `.user-row[data-username="..."]` over table cell index access like `cells[3]`.
  - avoid brittle selector strategies when a stable hook can be introduced.
- Be strict about expected selectors:
  - if a selector/attribute lookup is expected to exist, assert lookup errors with `assert.Nil` instead of silently skipping.
  - use tolerant parsing only for truly optional UI states.
* Acceptance tests should interact through the real GUI only: click, input, submit, and other user-facing controls.
* Do not use DOM parsing/introspection as the primary navigation or interaction strategy. It is allowed when reading/asserting rendered values (for example extracting data from table rows/cells).
* Navigation assertions should follow real user flow: click dedicated navigation UI elements (especially sidebar links/buttons) instead of directly visiting URLs, and cover all available sidebar destinations, including optional ones when visible for the current role/feature state.
* Assume sidebar navigation is available on every page; navigation helpers should be reusable across pages.
* Do not assert low-level UI copy/label text just to verify selectors. Prefer asserting behavior and meaningful data presence (for example redirect target, created entity appears in table, expected action outcome is visible).
* To run acceptance tests in this workspace, use the CI runner from `src/ci-runner` with:
  `go build && ./ci-runner test acceptance -k`
- Acceptance tests should focus on specific page behavior and user-visible outcomes.
- Move non-UI concerns, such as setup and data assertions, at least partially to HTTP requests through the network client whenever possible.
- Prefer covering expensive flows once through the GUI and reusing faster network-client setup in other tests.
- Example: if app installation is slow in the GUI, cover that path in one dedicated acceptance test, then install via HTTP in other tests that only need the installed state.
