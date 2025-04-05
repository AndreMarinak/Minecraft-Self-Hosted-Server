#!/bin/bash

# Define your server name once — change this for different servers!
#🚨CHANGE ME ~~~~~~~~~~~~~🚨
SERVER_NAME="server1" 
#🚨CHANGE ME ~~~~~~~~~~~~~🚨

# Derived variables (don't touch)
SERVER_DIR="$HOME/minecraft-servers/$SERVER_NAME"
CONTAINER_NAME="minecraft_$SERVER_NAME"
BACKUP_DIR="$HOME/minecraft-servers/backups/$SERVER_NAME"

# Ensure you're running from the correct directory
if [[ "$(pwd)" != "$SERVER_DIR" ]]; then
    echo "⚠️  You must be in $SERVER_DIR to run this command!"
    exit 1
fi

# Define the list of command symlinks
COMMANDS=("start" "stop" "stop5" "cancel" "restart" "status" "console" "logs" \
          "properties" "whitelist" "ops" "stats" "statsl" "backup" "backupn" "restore" "commands")

# Create missing symlinks
for CMD in "${COMMANDS[@]}"; do
    [[ ! -L "$SERVER_DIR/$CMD" ]] && ln -s "$SERVER_DIR/mc-server.sh" "$SERVER_DIR/$CMD" && echo "🔗 Symlink for '$CMD' created."
done

# Determine which command was used
RUN_CMD="$(basename "$0")"

case "$RUN_CMD" in

    start)
        echo "🚀 Starting Minecraft server ($SERVER_NAME)..."
        docker-compose up -d
        ;;

    stop)
        echo "🛑 Stopping Minecraft server safely..."
        docker exec -it "$CONTAINER_NAME" rcon-cli stop
        sleep 5
        docker-compose down
        ;;

    stop5)
        echo "🕗 Countdown to shutdown (5 minutes)..."
        rm -f "$SERVER_DIR/stop5.cancel" 2>/dev/null

        for t in 5 4 3 2 1; do
            docker exec -it "$CONTAINER_NAME" rcon-cli say "§cSERVER SHUTDOWN in $t MINUTES!"
            sleep 60
            [[ -f "$SERVER_DIR/stop5.cancel" ]] && echo "Shutdown cancelled!" && docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!" && rm -f "$SERVER_DIR/stop5.cancel" && exit 0
        done

        for i in 30 15 10 9 8 7 6 5 4 3 2 1; do
            docker exec -it "$CONTAINER_NAME" rcon-cli say "§cSERVER SHUTDOWN in $i SECONDS!"
            sleep 1
        done

        echo "🛑 Now stopping server..."
        docker exec -it "$CONTAINER_NAME" rcon-cli stop
        sleep 5
        docker-compose down
        ;;

    cancel)
        echo "❌ Cancelling any ongoing 'stop5' countdown..."
        touch "$SERVER_DIR/stop5.cancel"
        docker exec -it "$CONTAINER_NAME" rcon-cli say "§aSERVER SHUTDOWN CANCELLED!"
        ;;

    restart)
        echo "🔄 Restarting Minecraft server..."
        "$SERVER_DIR/stop"
        sleep 3
        "$SERVER_DIR/start"
        ;;

    status)
        echo "📊 Checking server status..."
        docker ps --filter "name=$CONTAINER_NAME"
        ;;

    console)
        echo "🎮 Attaching to Minecraft console (Press CTRL+P, CTRL+Q to detach)"
        docker attach "$CONTAINER_NAME"
        ;;

    logs)
        echo "📜 Showing live server logs..."
        docker-compose logs -f
        ;;

    properties)
        echo "📝 Editing data/server.properties..."
        nano "$SERVER_DIR/data/server.properties"
        ;;

    whitelist)
        echo "✅ Editing whitelist.json..."
        nano "$SERVER_DIR/data/whitelist.json"
        ;;

    ops)
        echo "🛠 Editing ops.json..."
        nano "$SERVER_DIR/data/ops.json"
        ;;

    stats)
        echo "🔎 Player List:"
        docker exec -it "$CONTAINER_NAME" rcon-cli list 2>/dev/null
        echo "🔎 Server Version:"
        grep 'VERSION:' docker-compose.yml | cut -d'"' -f2
        echo "🔎 Resource Usage:"
        docker stats --no-stream "$CONTAINER_NAME"
        ;;

    statsl)
        echo "🖥  Live stats for 1 minute (every 10s)..."
        for i in {1..6}; do
            echo "----- Stats iteration $i of 6 -----"
            docker exec -it "$CONTAINER_NAME" rcon-cli list 2>/dev/null
            grep 'VERSION:' docker-compose.yml | cut -d'"' -f2
            docker stats --no-stream "$CONTAINER_NAME"
            [[ "$i" -lt 6 ]] && sleep 10
        done
        echo "✅ Done showing live stats."
        ;;

    backup)
        echo "💾 Backing up the server world data..."
        docker exec -it "$CONTAINER_NAME" rcon-cli save-off
        docker exec -it "$CONTAINER_NAME" rcon-cli save-all
        sleep 2
        mkdir -p "$BACKUP_DIR"
        LAST_NUM=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name '*.tar.gz' -printf "%f\n" | grep '^[0-9]\+-' | sort -n | tail -n 1 | cut -d- -f1)
        NEXT_NUM=$((LAST_NUM + 1))
        TIMESTAMP="$(date +%F-%H%M)"
        SIZE=$(du -sh "$SERVER_DIR/data" | awk '{print $1}')
        BACKUP_FILE="${NEXT_NUM}-AutoBackup-backup-${TIMESTAMP}-${SIZE}.tar.gz"
        tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$SERVER_DIR" data
        docker exec -it "$CONTAINER_NAME" rcon-cli save-on
        echo "✅ Auto-backup complete: $BACKUP_FILE"
        ;;

    backupn)
        echo "💾 Backing up the server world data (named)..."
        docker exec -it "$CONTAINER_NAME" rcon-cli save-off
        docker exec -it "$CONTAINER_NAME" rcon-cli save-all
        sleep 2
        mkdir -p "$BACKUP_DIR"
        read -rp "📝 Enter a name for this backup (no spaces): " BACKUP_NAME
        LAST_NUM=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name '*.tar.gz' -printf "%f\n" | grep '^[0-9]\+-' | sort -n | tail -n 1 | cut -d- -f1)
        NEXT_NUM=$((LAST_NUM + 1))
        TIMESTAMP="$(date +%F-%H%M)"
        SIZE=$(du -sh "$SERVER_DIR/data" | awk '{print $1}')
        BACKUP_FILE="${NEXT_NUM}-${BACKUP_NAME}-backup-${TIMESTAMP}-${SIZE}.tar.gz"
        tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$SERVER_DIR" data
        docker exec -it "$CONTAINER_NAME" rcon-cli save-on
        echo "✅ Named backup complete: $BACKUP_FILE"
        ;;

    restore)
        mkdir -p "$BACKUP_DIR"
        echo "💾 Available backups:"
        find "$BACKUP_DIR" -maxdepth 1 -type f -name '*.tar.gz' -printf "%f\n" | sort -n
        read -rp "🔢 Enter the number of the backup to restore: " BACKUP_NUM
        MATCH_PATH=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "${BACKUP_NUM}-*.tar.gz" | head -n 1)
        [[ -z "$MATCH_PATH" ]] && echo "❌ Backup #$BACKUP_NUM not found." && exit 1
        read -rp "⚠️  Type YES to confirm restore from '$(basename "$MATCH_PATH")': " CONFIRM
        [[ "$CONFIRM" != "YES" ]] && echo "❌ Restore cancelled." && exit 1
        echo "🛑 Stopping server..."
        docker stop "$CONTAINER_NAME"
        rm -rf "$SERVER_DIR/data"
        tar -xzf "$MATCH_PATH" -C "$SERVER_DIR"
        docker start "$CONTAINER_NAME"
        echo "✅ Restore complete!"
        ;;

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
		echo "  backup     - Create a numbered auto-named .tar.gz backup"
		echo "  backupn    - Create a numbered .tar.gz backup with custom name"
		echo "  restore    - Restore a backup by number"
		echo "  commands   - Print this command list"
		;;


    *)
        echo "⚙️  Usage: ${COMMANDS[*]}"
        exit 1
        ;;
esac
