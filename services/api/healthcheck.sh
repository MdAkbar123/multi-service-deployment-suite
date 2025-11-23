#!/bin/sh
set -e

# Check API http health
curl -fs http://localhost:3000/health || exit 1

# Check MongoDB (optional suggestion)
if [ -n "$MONGO_URI" ]; then
  host=$(echo "$MONGO_URI" | sed -E 's|mongodb://[^@]*@([^:/]+).*|\1|')
  nc -z -w2 $host 27017 || { echo "Mongo unreachable"; exit 1; }
fi

# Check Redis
if [ -n "$REDIS_URL" ]; then
  redis_host=$(echo "$REDIS_URL" | sed -E 's|redis://([^:/]+).*|\1|')
  nc -z -w2 $redis_host 6379 || { echo "Redis unreachable"; exit 1; }
fi

echo "API Healthy"
exit 0
