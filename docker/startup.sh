#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Wait for DB services
#sh ./docker/wait-for-services.sh

# Prepare DB (Migrate - If not? Create db & Migrate)
sh /usr/bin/prepare-db.sh

# Pre-comple app assets
#sh ./docker/asset-pre-compile.sh

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
