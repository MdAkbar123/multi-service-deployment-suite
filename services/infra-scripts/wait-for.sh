#!/bin/sh
# Usage: ./wait-for.sh host port timeout
HOST=$1
PORT=$2
TIMEOUT=${3:-30}

echo "Waiting for $HOST:$PORT..."
for i in $(seq $TIMEOUT); do
  nc -z $HOST $PORT && echo "Connected!" && exit 0
  sleep 1
done

echo "Timeout waiting for $HOST:$PORT"
exit 1
