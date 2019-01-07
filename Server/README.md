# adapt-server
Node.js, Express, and MySQL API

## To Install
- Install [node.js](https://nodejs.org) optionally using [nvm](https://github.com/creationix/nvm)
- Install [MySQL](https://www.mysql.com/downloads/) optionally using [brew](https://brew.sh/) `brew install mysql`

```bash
npm i
```

## To Run
**Replace <user> with your localhost MySQL username, and <password> with your password.**
```bash
export MYSQL_USER=<user>
export MYSQL_PASSWORD=<password>
npm start
```

## Endpoints (requirements are URL query parameters)
Players
GET
`/players`
`/players/create` requires `name`, `height`, `weight`, `number`, and `position`
`/players/edit` requires `id`, and any of: `name`, `height`, `weight`, `number`, and/or `position`
`/players/delete` requires `id`

Trainings
GET
`/trainings` requires `playerId`
`/training` requires `id`
`/trainings/delete` requires `id`

POST
`/trainings/create` requires `playerId`, `dateTime`, `data`, `notes`, `score`, `trainingType`, `legType`, `baseType`, `assessmentType`, `duration`, `biasPointX`, and `biasPointY`


## To run in the background
```
npm i -g forever

# START
forever start index.js

# STOP
forever stop index.js
```