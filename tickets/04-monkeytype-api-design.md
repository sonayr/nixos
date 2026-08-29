## Question

What exact Monkeytype API endpoints, authentication headers, and data structures are required to fetch a user's recent typing test results and statistics securely using an API token?

## Resolution

- **Endpoints**: `https://api.monkeytype.com/users/personalBests`, `https://api.monkeytype.com/results` (with query parameters like `limit=10`), and `https://api.monkeytype.com/users/stats`.
- **Authentication**: `Authorization: Bearer <api_token>` header.
- **Data structure**: JSON responses containing `data` arrays with WPM, accuracy, consistency, missed keys, and timestamp metadata.
