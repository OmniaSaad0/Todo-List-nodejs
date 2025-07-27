#!/bin/bash

IMAGE_NAME="omniasaad/todo-app"

# Get latest remote tag (sorted by time)
LATEST_TAG=$(curl -s "https://registry.hub.docker.com/v2/repositories/${IMAGE_NAME}/tags?page_size=100" |
  grep -oE '"name":"[0-9]{8}-[0-9]{4}"' |
  cut -d':' -f2 | tr -d '"' | sort -r | head -n1)

echo "Latest tag: $LATEST_TAG"

if [ -z "$LATEST_TAG" ]; then
  echo "❌ Failed to fetch latest tag."
  exit 1
fi

# Get current tag from docker-compose.yml
CURRENT_TAG=$(grep "$IMAGE_NAME" docker-compose.yml | cut -d: -f3)

if [ -z "$CURRENT_TAG" ]; then
  echo "❌ Could not detect current tag in docker-compose.yml"
  exit 1
fi

echo "📄 Current tag in compose: $CURRENT_TAG"

# Compare tags
if [ "$CURRENT_TAG" != "$LATEST_TAG" ]; then
  echo "🔄 New tag detected. Updating docker-compose.yml..."

  # Backup the original docker-compose.yml
  cp docker-compose.yml docker-compose.yml.bak

  # Replace the tag in docker-compose.yml
  sed -i "s/${CURRENT_TAG}/${LATEST_TAG}/" docker-compose.yml

  # Pull new image and restart
  docker compose pull app
  docker compose up -d app

  echo "🚦 Waiting 30s for app to stabilize..."
  sleep 60
   APP_ID=$(docker compose ps -q app)
   RESTARTS=$(docker inspect --format='{{.RestartCount}}' "$APP_ID")
   STATUS=$(docker inspect --format='{{.State.Status}}' "$APP_ID")

   echo "🔁 App restart count: $RESTARTS"
   echo "📦 App status: $STATUS"

    # If app restarted too much or exited, roll back
    if [[ "$RESTARTS" -ge 3 || "$STATUS" == "exited" ]]; then
    echo "❌ App is unhealthy (restarts: $RESTARTS, status: $STATUS). Rolling back to $CURRENT_TAG..."

    # Restore previous docker-compose.yml
    mv docker-compose.yml.bak docker-compose.yml

    # Pull and redeploy previous tag
    docker compose pull app
    docker compose up -d app

    echo "✅ Rolled back to $CURRENT_TAG"
  else
    echo "✅ App is healthy with $LATEST_TAG"
    rm -f docker-compose.yml.bak
  fi
else
  echo "✅ Already using the latest tag: $CURRENT_TAG"
fi
