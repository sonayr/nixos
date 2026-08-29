## Destination

A fully specified design and architecture for an extensible local script library triggered via `wofi`, featuring a Monkeytype stats retrieval engine, an AI-powered typing review, and a personalized training plan generator, integrated into NixOS Home Manager.

## Notes

- Domain: NixOS, Home Manager, shell scripting, Python, Monkeytype API, Wofi, Opencode / LLM integration.
- Skills every session should consult: `grilling`, `domain-modeling`, `research`.
- Standing preferences: Declarative NixOS configuration, modular script library under `scripts/`, terminal output using Ghostty/terminal window.

## Decisions so far

- [Language and Runtime Selection](tickets/01-language-runtime.md): Python selected for robust HTTP/JSON handling and LLM ecosystem integration.
- [Execution Interface](tickets/02-execution-interface.md): Terminal window (Ghostty/terminal) chosen to display rich text output and interactive TUI.
- [Integration Method](tickets/03-home-manager-integration.md): Dedicated Home Manager module exposing `wofi --dmenu` bound to scripts in the script library directory.
- [Monkeytype API Design](tickets/04-monkeytype-api-design.md): Monkeytype API v1 endpoints (`/users/personalBests`, `/results`, `/users/stats`) selected with `Authorization: Bearer <api_token>` authentication.
- [AI Review Prompt Design](tickets/05-ai-review-prompt-design.md): System/User prompt architecture established using structured JSON telemetry from Monkeytype passed to opencode/LLM to generate typing reviews and actionable training plans.
- [Wofi Script Library Runner](tickets/06-wofi-script-library-runner.md): Architecture finalized with a scripts directory (`nixos/scripts/`), a `wofi --dmenu` launcher script, and a dedicated Home Manager module executing selections in Ghostty.

## Not yet specified

- None (all initial frontier decisions resolved; route to destination is clear).

## Out of scope

- Web-based graphical user interface (GUI) or dashboard.
- Automatic background polling of Monkeytype stats without manual invocation.
