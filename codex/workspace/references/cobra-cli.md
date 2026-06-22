# Cobra CLI

- Keep Cobra command files focused on CLI concerns: flag parsing, user interaction, passing args to service layer, and CLI-level error handling.
- Cobra-related parsing/flag errors are critical and should make cobra fail hard immediately.
- Put actual workflows in Cobra-independent functions (service layer) so they can be reused and tested without Cobra.
- Command tree wiring belongs in `main` or in a dedicated builder function called by `main`.
