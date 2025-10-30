# Base image with SteamCMD
FROM cm2network/steamcmd:root

# Metadata
LABEL maintainer="Your Name <youremail@example.com>"
LABEL description="Vein Dedicated Server Docker Image"

# Install Vein dependencies
RUN apt update -y && \
    apt install -y libatomic1 libasound2-dev libpulse-dev

# Environment variables for server installation and paths
ENV STEAM_USER anonymous
ENV STEAM_PASS ""
ENV STEAM_AUTH ""
ENV APPID 2131400
ENV SERVER_PATH /home/steam/vein-server
ENV CONFIG_DIR_NAME LinuxServer
ENV CONFIG_PATH ${SERVER_PATH}/Vein/Saved/Config/${CONFIG_DIR_NAME}

# --- Default Server Settings (can be overridden at runtime via -e) ---

# Game.ini - [/Script/Engine.GameSession]
ENV MAX_PLAYERS 16

# Game.ini - [/Script/Vein.VeinGameSession]
ENV SERVER_PUBLIC True
ENV SERVER_NAME "Vein Docker Server"
ENV SERVER_BIND_ADDR "0.0.0.0"
ENV SUPER_ADMIN_STEAM_IDS ""
ENV ADMIN_STEAM_IDS ""
ENV HEARTBEAT_INTERVAL 5.0
ENV SERVER_PASSWORD "secret" # Set to empty for no password

# Game.ini - [OnlineSubsystemSteam]
ENV GAME_SERVER_QUERY_PORT 27015 # UDP Query Port for Steam
ENV VAC_ENABLED 0 # 0 for False, 1 for True

# Game.ini - [URL] & Command Line
ENV GAME_PORT 7777 # UDP Game Port

# Game.ini - [/Script/Vein.ServerSettings]
ENV SHOW_SCOREBOARD_BADGES 1 # 0 for False, 1 for True
ENV DISCORD_WEBHOOK_URL ""
ENV DISCORD_ADMIN_WEBHOOK_URL ""

# Engine.ini - [ConsoleVariables]
# Full list can be found at https://ramjet.notion.site/Console-Variable-List-279f9ec29f178049a1c7dec3d070e5e9
# Prefix with CVAR_ followed by the exact console variable name from Vein docs
# Example: To set 'vein.PvP=True', use ENV CVAR_vein.PvP=True
# ENV CVAR_vein.PvP=True
# ENV CVAR_vein.TimeMultiplier=16
# ENV CVAR_vein.Time.ContinueWithNoPlayers = 0.000000
    #If this is on, time continues moving when no players are on the server.
# ENV CVAR_vein.UtilityCabinet.ContinueWithNoPlayers = 0.000000
    #If this is off, UCs will not feed when no players are on the server.

# --- End Default Server Settings ---

# Ports to expose (UDP)
# These are defaults; actual ports used depend on GAME_PORT and GAME_SERVER_QUERY_PORT ENV vars
EXPOSE 7777/udp
EXPOSE 27015/udp

# Create directory for the server and config, set permissions
RUN mkdir -p ${SERVER_PATH} ${CONFIG_PATH} && \
    chown -R steam:steam ${SERVER_PATH} && \
    chmod -R 755 ${SERVER_PATH}

# Copy entrypoint script and make it executable (as root)
COPY --chown=steam:steam entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR ${SERVER_PATH}

# Volume for persistent data (game saves, potentially logs if not stdout)
VOLUME ${SERVER_PATH}/Vein/Saved

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command passed to entrypoint.sh (can be overridden)
# The entrypoint script will add essential args like -log, -Port, -QueryPort

CMD []
