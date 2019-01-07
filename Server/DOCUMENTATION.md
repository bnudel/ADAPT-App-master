## Available Endpoints

`GET /players`
- Response is JSON array of players

`GET /players/create`
- Requires query parameters `name`, `number`, `position`, `height`, and `weight`

`GET /players/delete`
- Requires query parameter `id`

`GET /players/edit`
- Requires query parameter `id`
- Provide at least one of: `name`, `number`, `position`, `height`, and `weight`