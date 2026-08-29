## Question

How should typing statistics (WPM, raw WPM, accuracy, consistency, miss keys) be formatted and sent to the LLM via opencode to generate a precise typing review and a structured, actionable training plan?

## Resolution

- **Prompt Architecture**: A system prompt defining the persona of an expert typing coach combined with a JSON payload of user metrics (personal bests, recent tests, accuracy, miss keys).
- **Execution**: The Python script formats the JSON telemetry and invokes `opencode` (or LLM API) with the structured prompt, streaming/rendering the markdown output directly to the terminal view.
