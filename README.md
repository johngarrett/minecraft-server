# minecraft-server

runs Java minecraft server and bedrock (geyeser) server together


add existing server path in docker-compose.yml


## run
docker compose build
docker compose up


## see logs
#### Attach to the live server console
docker attach minecraft-server

### Detach without stopping the server
Ctrl+P, Ctrl+Q

### View logs without attaching
docker logs -f minecraft-server
