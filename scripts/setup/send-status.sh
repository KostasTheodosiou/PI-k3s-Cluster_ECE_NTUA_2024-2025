#!/bin/bash
# File: /usr/local/bin/reboot-to-discord-advanced.sh
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1415617252291772426/6-WnVvmYQliuUUxRMb1bZqwy1NMqRRUbjmd_9wbl7u2ziRRrj_-inw7J1HzGOpxehOUx"
MAX_RETRIES=3
RETRY_DELAY=10

send_discord_message() {
    local payload="$1"
    local attempt=1
    
    while [ $attempt -le $MAX_RETRIES ]; do
        if curl -X POST -H "Content-Type: application/json" -d "$payload" "$DISCORD_WEBHOOK_URL" > /dev/null 2>&1; then
            echo "Notification sent successfully"
            return 0
        fi
        
        echo "Attempt $attempt failed, retrying in $RETRY_DELAY seconds..."
        sleep $RETRY_DELAY
        attempt=$((attempt + 1))
    done
    
    echo "Failed to send notification after $MAX_RETRIES attempts"
    return 1
}

# Create the message payload
JSON_PAYLOAD=$(cat << EOF
{
  "content": "",
  "embeds": [{
    "title": "✅ $HOSTNAME Back Online",
    "description": "System reboot completed successfully",
    "color": 5763719,
    "fields": [
      {"name": "Hostname", "value": "$(hostname)", "inline": true},
      {"name": "IP", "value": "$(hostname -I | awk '{print $1}')", "inline": true},
      {"name": "Time", "value": "$(date)", "inline": false}
    ]
  }]
}
EOF
)

# Send the message
send_discord_message "$JSON_PAYLOAD"
