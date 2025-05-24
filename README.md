# Vein Dedicated Server - Dockerized

This repository contains a `Dockerfile` to build a Docker image for the Vein dedicated server. It automatically downloads, installs, and updates the server on startup. Configuration is managed via environment variables.

## Prerequisites

- Docker installed on your system.

## Building the Image

Clone this repository or download the `Dockerfile` and `entrypoint.sh` script.
Navigate to the directory containing these files and run:

```bash
docker build -t czacha994/vein-server:latest .
```

## Running the Server

To run the server with default settings:

```bash
docker run -d --name vein-dedicated-server \
  -p 7777:7777/udp \
  -p 27015:27015/udp \
  -v vein_server_data:/home/steam/vein-server/Vein/Saved \
  czacha994/vein-server:latest
```

**Explanation:**

- `-d`: Run the container in detached mode (in the background).
- `--name vein-dedicated-server`: Assign a name to the container for easier management.
- `-p 7777:7777/udp`: Map UDP port 7777 on your host to port 7777 in the container (Vein game port).
- `-p 27015:27015/udp`: Map UDP port 27015 on your host to port 27015 in the container (Steam query port).
- `-v vein_server_data:/home/steam/vein-server/Vein/Saved`: Mount a Docker volume named `vein_server_data` to persist game saves and potentially other saved data across container restarts. Docker will create this volume if it doesn't exist.
- `czacha994/vein-server:latest`: The name of the image you built.

**Important:**
- Ensure UDP ports 7777 and 27015 (or the ports you configure) are open on your firewall/router and forwarded to the machine running Docker if you want the server to be accessible externally.
- The server will update on every start. This ensures you're running the latest version but might add a delay to startup time.

## Configuration via Environment Variables

You can customize the server by passing environment variables to the `docker run` command using the `-e` flag. For example:

```bash
docker run -d --name vein-dedicated-server \
  -p 7778:7778/udp \
  -p 27016:27016/udp \
  -e SERVER_NAME="My Awesome Vein Server" \
  -e SERVER_PASSWORD="supersecret" \
  -e MAX_PLAYERS=20 \
  -e GAME_PORT=7778 \
  -e GAME_SERVER_QUERY_PORT=27016 \
  -e SUPER_ADMIN_STEAM_IDS="76561190000000001,76561190000000002" \
  -e CVAR_vein.PvP=False \
  -e CVAR_vein.TimeMultiplier=20 \
  -v vein_server_data:/home/steam/vein-server/Vein/Saved \
  czacha994/vein-server
```

### Available Environment Variables

**Server Paths & SteamCMD (Generally no need to change these in `Dockerfile` defaults):**

- `STEAM_USER`: Steam username for download (default: `anonymous`).
- `STEAM_PASS`: Steam password (default: `""`).
- `STEAM_AUTH`: Steam Guard code if needed (default: `""`).
- `APPID`: Vein Server AppID (default: `2131400`).
- `SERVER_PATH`: Installation path inside the container (default: `/vein-server`).
- `CONFIG_DIR_NAME`: Name of the config directory (`LinuxServer` or `WindowsServer`). Default: `LinuxServer`.
- `CONFIG_PATH`: Full path to the config files (derived, default: `${SERVER_PATH}/Vein/Saved/Config/${CONFIG_DIR_NAME}`).

**Game.ini Settings:**

- **[/Script/Engine.GameSession]**
    - `MAX_PLAYERS`: (Default: `16`)
- **[/Script/Vein.VeinGameSession]**
    - `SERVER_PUBLIC`: `True` or `False`. (Default: `True`). If `False`, server won't be listed in browser.
    - `SERVER_NAME`: (Default: `"Vein Docker Server"`).
    - `SERVER_BIND_ADDR`: (Default: `0.0.0.0`). Usually not needed.
    - `SUPER_ADMIN_STEAM_IDS`: Comma-separated list of SteamID64s for super admins. (e.g., `"765...,765..."`).
    - `ADMIN_STEAM_IDS`: Comma-separated list of SteamID64s for regular admins.
    - `HEARTBEAT_INTERVAL`: (Default: `5.0`).
    - `SERVER_PASSWORD`: Server password. (Default: `"secret"`). Set to empty string (`-e SERVER_PASSWORD=""`) for no password.
- **[OnlineSubsystemSteam]**
    - `GAME_SERVER_QUERY_PORT`: UDP Port for Steam server browser. (Default: `27015`). **Must match `-p` mapping.**
    - `VAC_ENABLED`: `0` (False) or `1` (True). (Default: `0`).
- **[URL]** (Also used for command line argument)
    - `GAME_PORT`: UDP Port for game traffic. (Default: `7777`). **Must match `-p` mapping.**
- **[/Script/Vein.ServerSettings]**
    - `GS_SHOW_SCOREBOARD_BADGES`: `1` (Show) or `0` (Hide) admin/super admin badges. (Default: `1`).
    - `DISCORD_WEBHOOK_URL`: Full Discord Webhook URL for chat integration (e.g., `"https://discord.com/api/webhooks/..."`).
    - `DISCORD_ADMIN_WEBHOOK_URL`: Full Discord Webhook URL for admin report integration.

**Engine.ini Settings:**

- **[URL]** (Covered by `GAME_PORT` in `Game.ini` section as it's duplicated)
- **[Core.Log]** (These are set by default in `entrypoint.sh` to reduce log spam)
    - `LogOnlineSession=Warning`
    - `LogOnline=Warning`
- **[ConsoleVariables]**
    - To set any console variable listed in the Vein server documentation (e.g., `vein.PvP`, `vein.TimeMultiplier`), use an environment variable prefixed with `CVAR_`.
    - The `entrypoint.sh` script will automatically add these to the `Engine.ini` under the `[ConsoleVariables]` section.
    - **Example:**
        - To set `vein.PvP=True`, use `-e CVAR_vein.PvP=True`
        - To set `vein.TimeMultiplier=10`, use `-e CVAR_vein.TimeMultiplier=10`
        - To set `vein.AISpawner.Hordes.ChancePerMinute=0.1`, use `-e CVAR_vein.AISpawner.Hordes.ChancePerMinute=0.1`

**Server Executable Command Line Arguments:**

- `GAME_SERVER_QUERY_PORT` (Env var): Used to set the `-QueryPort` argument.
- `GAME_PORT` (Env var): Used to set the `-Port` argument.
- `SERVER_MULTIHOME_IP` (Env var, optional): If set, adds `-multihome=(IP address)` to the server startup command.
- Additional arguments passed after the image name in `docker run` will be appended to the server startup command. E.g., `docker run ... vein-server -customflag value`.

## Accessing Server Logs

```bash
docker logs vein-dedicated-server
```

To follow the logs in real-time:

```bash
docker logs -f vein-dedicated-server
```

## Stopping and Removing the Server

Stop the server:

```bash
docker stop vein-dedicated-server
```

Remove the container (this will not remove the `vein_server_data` volume):

```bash
docker rm vein-dedicated-server
```

To remove the persistent data volume (be careful, this deletes all game saves!):

```bash
docker volume rm vein_server_data
```

## Troubleshooting

- **`steamclient.so` errors:** The `entrypoint.sh` attempts to automatically create a symlink for `steamclient.so`, which is a common issue. If you still encounter problems, check the Docker logs for messages related to this and ensure the paths in `entrypoint.sh` align with where SteamCMD in the base image places this file.
- **Server not appearing in browser:**
    - Double-check your port forwarding on your router and firewall settings on the host machine.
    - Ensure `SERVER_PUBLIC` is `True` (default).
    - Verify `GAME_PORT` and `GAME_SERVER_QUERY_PORT` environment variables match the ports you exposed with `docker run -p ...`.
- **Config not applying:** Ensure your environment variable names are exactly as specified. Check the generated `Game.ini` and `Engine.ini` files within the container if needed:
  ```bash
  docker exec vein-dedicated-server cat /home/steam/vein-server/Vein/Saved/Config/LinuxServer/Game.ini
  docker exec vein-dedicated-server cat /home/steam/vein-server/Vein/Saved/Config/LinuxServer/Engine.ini
  ```

## Notes

- This setup assumes a Linux environment for the Vein server as `VeinServer.sh` is referenced. If you intend to run a Windows version of the server, the base image, paths (`CONFIG_DIR_NAME`), and executable name (`VeinServer.exe`) would need to be adjusted.
- The `cm2network/steamcmd:latest` image is used as a base. You can specify a more concrete tag if desired.
- Admin and Super Admin SteamIDs should be the SteamID64 format.
- The list of `CVAR_` console variables is extensive. Refer to the official Vein dedicated server documentation for all available options.