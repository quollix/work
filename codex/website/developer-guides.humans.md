# Developer Guides For Humans

This draft is for the website article and keeps contributor-oriented guidance separate from agent-control documentation.

## CI expectations

- All code must pass the CI pipeline before merge.
- CI may enforce formatting, style, and static-analysis checks.

## Dependency policy

- Be conservative when introducing external libraries.
- If an external library is added, it should be popular, actively maintained, and published under a permissive open source license.

## Tooling choices

- Keep the technology stack lean and only introduce new technologies when there is a clear and compelling need.
- If a project contains the `ci-runner` tool, prefer implementing DevOps-related automation there instead of adding Bash scripts.
