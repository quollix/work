# Component testing

## Client and helper boundaries

- Put single-endpoint calls and simple state queries on the component test client types.
- Keep client methods close to the backend surface. They should mainly wrap one HTTP request plus request/response decoding.
- When a helper composes multiple atomic client calls, switches actors, or applies logic to fetched state, keep it outside the clients as a package-level helper.
- Scenario-style helpers are fine as package-level functions when there are only a few of them. Prefer clear names that describe the workflow they perform.
- Do not keep thin package-level wrappers that duplicate existing client methods. If a lookup or operation already fits a client method, use or add the client method instead.

## Rule of thumb

- Client method: "call one backend action" or "read one backend view".
- Global helper: "prepare a reusable test scenario", "coordinate multiple clients", or "assert a test matrix".

## Examples

- `client.Users.Invite(...)` belongs on the client.
- `client.Users.GetByName(...)` belongs on the client.
- `InviteUserAndSetPassword(...)` can stay a package-level helper because it coordinates invitation, token lookup, and a second client that sets the password.
- `RunAccessPoliciesTest(...)` should stay outside the clients because it is test orchestration, not transport logic.
