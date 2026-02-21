FROM eclipse-temurin:21-jre-jammy

RUN apt-get update && apt-get install -y curl jq && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 minecraft

# Geyser (spigot = this is the plugin variant instead of running a proxy)
RUN mkdir -p /plugins-staging && \
    curl -fsSL -o /plugins-staging/Geyser-Spigot.jar \
        "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot" && \
# Floodgate (allows non-Java accounts to connect to the server)
    curl -fsSL -o /plugins-staging/floodgate-spigot.jar \
        "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Port for Java Minecraft server (setup in `entrypoint.sh`)
EXPOSE 25565/tcp
# Port for Geyser
EXPOSE 19132/udp

USER minecraft
ENTRYPOINT ["/entrypoint.sh"]
