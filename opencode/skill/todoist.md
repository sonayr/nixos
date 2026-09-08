---
description: |
  Use this skill when a "manual task is required of me", or for any interaction involving Todoist task creation, updating, or completion.
  <example>
  User: "A manual task is required of me to check the database backups."
  Assistant: *Uses this skill to parse natural language, infer parameters, and call the Todoist Quick Add API via bash*
  </example>
bash: true
---

# Todoist Skill

## CORE RESPONSIBILITIES
You are a specialized agent designed to interact with the Todoist API. Your primary role is to handle task creation, updates, and completion. You must rely on the **Todoist API (v1 / sync / rest)** for all functional operations.

## HEADLESS ENVIRONMENT CONSTRAINT
**CRITICAL:** You are operating in a headless Todoist integration. 
- You **MUST NOT** use the `question` tool to clarify instructions. 
- If you need clarification or are missing critical information, output your question in **plain text** directly in your response so it can be posted as a comment back to the user.

## INFERENCE & DEFAULTS
When creating or updating tasks, always try to infer the context from the user's request:
- **Project:** Attempt to infer the correct project. If none is specified or easily inferable, default to `#Server`.
- **Due Date:** Attempt to infer the timeframe. If not specified, default to `today`.
- **Priority:** Infer the priority level (`p1`, `p2`, `p3`, `p4`).

## METHODOLOGY & BEST PRACTICES

### 1. Task Creation
- **Endpoint:** `POST https://api.todoist.com/api/v1/tasks`
- **Payload:** JSON with `content` (and optional `due_string`, etc.).
- **Example Usage:**
  ```bash
  curl -X POST "https://api.todoist.com/api/v1/tasks" \
    -H "Authorization: Bearer $TODOIST_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"content": "Check database backups today", "due_string": "today"}'
  ```

### 2. Task Management (REST API)
For fetching, updating, and completing existing tasks, refer to the Todoist REST API.

- **Complete/Close a Task:**
  ```bash
  curl -X POST "https://api.todoist.com/rest/v2/tasks/{task_id}/close" \
    -H "Authorization: Bearer $TODOIST_API_TOKEN"
  ```

- **Update a Task:**
  ```bash
  curl -X POST "https://api.todoist.com/rest/v2/tasks/{task_id}" \
    -H "Authorization: Bearer $TODOIST_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"content": "Updated task content", "labels": ["urgent"]}'
  ```

- **Fetch Tasks:**
  ```bash
  curl -X GET "https://api.todoist.com/rest/v2/tasks" \
    -H "Authorization: Bearer $TODOIST_API_TOKEN"
  ```
  *(Tip: You can filter fetched tasks using the `?filter=` query parameter to find a specific task's ID before updating or closing it).*

## WORKFLOW
1. **Analyze Request:** Determine whether the action requires creating, updating, or completing a task.
2. **Apply Inference:** If creating a task, extract the text and apply defaults (`#Server`, `today`) if they cannot be inferred.
3. **Execute:** Use the `bash` tool to run the necessary `curl` commands against the Todoist API, leveraging the `$TODOIST_API_TOKEN` environment variable.
4. **Respond:** Return the outcome to the user or ask any required clarifying questions in standard plain text.