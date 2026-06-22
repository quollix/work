# Architecture

## Project organization

- Organize packages by feature, not by technical layer.
- A package should contain all layers that belong to that feature, for example handler, service, and repository.
- Immutable constants and pure helper functions are allowed as globals. All other behavior should live in objects.

## Interfaces and implementations

- Prefer an interface for each unit that has behavior and external dependencies.
- Name the interface after the role, for example `DockerClient`.
- Name the concrete implementation with the `Impl` suffix, for example `DockerClientImpl`.
- Prefer injecting implementations as pointers.
- Prefer constructor-based dependency injection.
- Inject dependencies through interfaces, not concrete implementations.
- Use pointer receivers for implementation structs when the type has dependencies or mutable state.

## Composition

- We want OOP styled composition for construction and dependency injection.
- Prefer explicit constructors with interface-typed fields and parameters.

### Global Varriables and Constants

* Place `const` and `var` blocks directly below the import block and above type, interface, or other object definitions.
* Avoid mutable global vars, as we seek to achieve OOP style composition. Once initialized, global `var` values should be read only.
* If applicable, use `const` over `var`.

## Layer responsibilities

- Handlers should stay lean: parse requests, perform basic validation, and delegate to services.
- Repositories should stay lean: persist and retrieve data without business logic.
- Clients should contain integration code for external systems.
- Services should contain business logic and orchestrate between handlers, repositories, and clients.

## Persistence

- If a project has a database:
  - persistent data belongs in the database.
  - schema changes must go through versioned migrations.

## Frontend

- Minimize JavaScript and only add it where it is clearly necessary.
- For frontend, we use server-side rendering with Go HTML templates instead of JavaScript frontend frameworks.
- Conversion of integers in JavaScript can be unreliable, so we use strings in DTOs instead of integers.
