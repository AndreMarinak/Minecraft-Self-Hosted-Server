#!/bin/bash
 
# Define server directory and container name
SERVER_DIR="$HOME/minecraft-servers/server1"        #🚨CHANGE ME ~~~~~~~~~~~~~🚨
CONTAINER_NAME="minecraft_server1"                  #🚨CHANGE ME ~~~~~~~~~~~~~🚨
 
# Ensure the script is run inside server(#) directory
if [[ "$(pwd)" != "$SERVER_DIR" ]]; then
    echo "⚠️  You must be in $SERVER_DIR to run this command!"
    exit 1
fi
 
# Define the list of commands we want symlinks for
COMMANDS=("start" "stop" "stop5" "cancel" "restart" "status" "console" "logs" \
          "properties" "whitelist" "ops" "stats" "statsl" "backup" "commands")
 
# Check if symlinks exist; if not, create them
for CMD in "${COMMANDS[@]}"; do
    if [[ ! -L "$SERVER_DIR/$CMD" ]]; then
        ln -s "$SERVER_DIR/mc-server.sh" "$SERVER_DIR/$CMD"
        echo "🔗 Symlink for '$CMD' created."
    fi
done
 
# Determine which command was run (basename of the symlink)
RUN_CMD="$(basename "$0")"
 
case "$RUN_CMD" in
 
    # ------------------------------
    #  START THE SERVER
    # ------------------------------
    start)
        echo "🚀 Starting Minecraft server (server)..."
        docker-compose up -d
        ;;
 
    # ------------------------------
    #  STOP THE SERVER IMMEDIATELY
    # ------------------------------
    stop)
        echo "🛑 Stopping Minecraft server safely..."
        docker exec -it "$CONTAINER_NAME" rcon-cli stop
        sleep 5
        docker-compose down
        ;;
 
    # ------------------------------
    #  5-MINUTE COUNTDOWN SHUTDOWN
    # ------------------------------
    stop5)
        echo "🕗 Countdown to shutdown (5 minutes)..."
 
        # Remove any stale cancel file from previous attempts
        rm -f "$SERVER_DIR/stop5.cancel" 2>/dev/null
 
        # All warnings in red (use §c for bright red)
        # 5 min
        docker exec -it "$CONTAINER_NAME" rcon-cli say "§cSERVER SHUTDOWN in 5 MINUTES!"
        sleep 60
        [[ -f "$SERVER_DIR/stop5.cancel" ]] && \
          echo "Shutdown cancelled!" && \
          docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!" && \
          rm -f "$SERVER_DIR/stop5.cancel" && exit 0
 
        # 4 min
        docker exec -it "$CONTAINER_NAME" rcon-cli say "§cSERVER SHUTDOWN in 4 MINUTES!"
        sleep 60
        [[ -f "$SERVER_DIR/stop5.cancel" ]] && \
          echo "Shutdown cancelled!" && \
          docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!" && \
          rm -f "$SERVER_DIR/stop5.cancel" && exit 0
 
        # 3 min
        docker exec -it "$CONTAINER_NAME" rcon-cli say "§cSERVER SHUTDOWN in 3 MINUTES!"
        sleep 60
        [[ -f "$SERVER_DIR/stop5.cancel" ]] && \
          echo "Shutdown cancelled!" && \
          docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!" && \
          rm -f "$SERVER_DIR/stop5.cancel" && exit 0
 
        # 2 min
        docker exec -it "$CONTAINER_NAME" rcon-cli say "§cSERVER SHUTDOWN in 2 MINUTES!"
        sleep 60
        [[ -f "$SERVER_DIR/stop5.cancel" ]] && \
          echo "Shutdown cancelled!" && \
          docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!" && \
          rm -f "$SERVER_DIR/stop5.cancel" && exit 0
 
        # 1 min
        docker exec -it "$CONTAINER_NAME" rcon-cli say "§cSERVER SHUTDOWN in 1 MINUTE!"
        sleep 30
        [[ -f "$SERVER_DIR/stop5.cancel" ]] && \
          echo "Shutdown cancelled!" && \
          docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!" && \
          rm -f "$SERVER_DIR/stop5.cancel" && exit 0
 
        # 30 sec
        docker exec -it "$CONTAINER_NAME" rcon-cli say "§cSERVER SHUTDOWN in 30 SECONDS!"
        sleep 15
        [[ -f "$SERVER_DIR/stop5.cancel" ]] && \
          echo "Shutdown cancelled!" && \
          docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!" && \
          rm -f "$SERVER_DIR/stop5.cancel" && exit 0
 
        # 15 sec
        docker exec -it "$CONTAINER_NAME" rcon-cli say "§cSERVER SHUTDOWN in 15 SECONDS!"
        sleep 5
        [[ -f "$SERVER_DIR/stop5.cancel" ]] && \
          echo "Shutdown cancelled!" && \
          docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!" && \
          rm -f "$SERVER_DIR/stop5.cancel" && exit 0
 
        # 10 sec -> countdown to 1
        for i in {10..1}; do
          if [[ -f "$SERVER_DIR/stop5.cancel" ]]; then
            echo "Shutdown cancelled!"
            docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!"
            rm -f "$SERVER_DIR/stop5.cancel"
            exit 0
          fi
          docker exec -it "$CONTAINER_NAME" rcon-cli say "§cSERVER SHUTDOWN in $i SECONDS!"
          sleep 1
        done
 
        echo "🛑 Now stopping server..."
        docker exec -it "$CONTAINER_NAME" rcon-cli stop
        sleep 5
        docker-compose down
        ;;
 
    # ------------------------------
    #  CANCEL SHUTDOWN COUNTDOWN
    # ------------------------------
    cancel)
        echo "❌ Cancelling any ongoing 'stop5' countdown..."
        touch "$SERVER_DIR/stop5.cancel"
        docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!"
        ;;
 
    # ------------------------------
    #  RESTART THE SERVER
    # ------------------------------
    restart)
        echo "🔄 Restarting Minecraft server..."
        "$SERVER_DIR/stop"
        sleep 3
        "$SERVER_DIR/start"
        ;;
 
    # ------------------------------
    #  CHECK IF SERVER IS RUNNING
    # ------------------------------
    status)
        echo "📊 Checking server status..."
        docker ps --filter "name=$CONTAINER_NAME"
        ;;
 
    # ------------------------------
    #  ATTACH TO THE SERVER CONSOLE
    # ------------------------------
    console)
        echo "🎮 Attaching to Minecraft console (Press CTRL+P, CTRL+Q to detach)"
        docker attach "$CONTAINER_NAME"
        ;;
 
    # ------------------------------
    #  TAIL THE SERVER LOGS
    # ------------------------------
    logs)
        echo "📜 Showing live server logs..."
        docker-compose logs -f
        ;;
 
    # ------------------------------
    #  EDIT PROPERTIES, WHITELIST, OPS
    # ------------------------------
    properties)
        echo "📝 Editing data/server.properties..."
        nano "$SERVER_DIR/data/server.properties"
        ;;
 
    whitelist)
        echo "✅ Editing whitelist.json..."
        nano "$SERVER_DIR/whitelist.json"
        ;;
 
    ops)
        echo "🛠 Editing ops.json..."
        nano "$SERVER_DIR/ops.json"
        ;;
 
    # ------------------------------
    #  SHOW STATS: Player list, version, resource usage
    # ------------------------------
    stats)
        echo "🔎 Player List:"
        docker exec -it "$CONTAINER_NAME" rcon-cli list 2>/dev/null
 
        echo "🔎 Server Version:"
        grep 'VERSION:' docker-compose.yml | cut -d'"' -f2

 
        echo "🔎 Resource Usage (docker stats --no-stream):"
        docker stats --no-stream "$CONTAINER_NAME"
        ;;
 
    # ------------------------------
    #  STATS FOR 1 MINUTE (LIVE)
    # ------------------------------
    statsl)
        echo "🖥  Live stats for 1 minute (every 10s)..."
 
        for i in {1..6}; do
          echo "----- Stats iteration $i of 6 -----"
          echo "🔎 Player List:"
          docker exec -it "$CONTAINER_NAME" rcon-cli list 2>/dev/null
 
          echo "🔎 Server Version:"
          grep 'VERSION:' docker-compose.yml | cut -d'"' -f2

 
          echo "🔎 Resource Usage (docker stats --no-stream):"
          docker stats --no-stream "$CONTAINER_NAME"
 
          # Sleep 10 seconds before next iteration
          [[ "$i" -lt 6 ]] && sleep 10
        done
 
        echo "✅ Done showing live stats."
        ;;
 
    # ------------------------------
    #  BACKUP THE SERVER
    # ------------------------------
    backup)
        echo "💾 Backing up the server world data..."
        echo "⚠️  Temporarily disabling world saves..."
 
        # 1. Turn off saves (to avoid corruption)
        docker exec -it "$CONTAINER_NAME" rcon-cli save-off
        docker exec -it "$CONTAINER_NAME" rcon-cli save-all
        sleep 2
 
        # 2. Define the backup directory
        BACKUP_DIR="$HOME/minecraft-servers/backups/server1" #🚨CHANGE ME 🚨
 
        # 3. Create the directory if it doesn’t exist
        mkdir -p "$BACKUP_DIR"
 
            # 4. Calculate the size of the data folder before zipping
        SIZE=$(du -sh "$SERVER_DIR/data" | awk '{print $1}')  # Get human-readable size (e.g., 2.3G)
 
        # 5. Create the backup filename with timestamp and size
        TIMESTAMP="$(date +%F-%H%M)"
        BACKUP_FILE="$BACKUP_DIR/backup-${TIMESTAMP}-${SIZE}.tar.gz"
 
        echo "📦 Creating backup: $BACKUP_FILE"
 
        # 6. CHOOSE BETWEEN TAR.GZ OR A FOLDER BACKUP
        # -------------------------------------------
 
        # Option 1: Create a compressed tar.gz file (default)
        tar -czf "$BACKUP_FILE" -C "$SERVER_DIR" data
 
        # Option 2: Copy the entire data folder instead (Uncomment the line below)
        # cp -r "$SERVER_DIR/data" "$BACKUP_DIR/data-$TIMESTAMP"
 
        # -------------------------------------------
 
        # 7. Turn on saves again
        docker exec -it "$CONTAINER_NAME" rcon-cli save-on
 
        echo "✅ Backup completed and saved to $BACKUP_FILE (or folder if using cp -r)"
        ;;
 
        # ------------------------------
 
    commands)
        echo "🔖 Available commands:"
        echo "  start      - Start the Minecraft server"
        echo "  stop       - Stop the server immediately"
        echo "  stop5      - 5-minute countdown then shutdown"
        echo "  cancel     - Cancel the 'stop5' countdown"
        echo "  restart    - Restart the server"
        echo "  status     - Check if the server is running"
        echo "  console    - Attach to the live console"
        echo "  logs       - View server logs in real-time"
        echo "  properties - Edit data/server.properties"
        echo "  whitelist  - Edit whitelist.json"
        echo "  ops        - Edit ops.json"
        echo "  stats      - Show player list, version, resource usage"
        echo "  statsl     - Live stats for 1 minute (updates every 10s)"
        echo "  backup     - Create a .tar.gz backup of the data folder"
        echo "  commands   - Print this command list"
        ;;
 
    # ------------------------------
    #  DEFAULT CATCH-ALL
    # ------------------------------
    *)
        echo "⚙️  Usage: start | stop | stop5 | cancel | restart | status | console | logs | properties | whitelist | ops | stats | statsl | backup | commands"
        exit 1
        ;;
esac
