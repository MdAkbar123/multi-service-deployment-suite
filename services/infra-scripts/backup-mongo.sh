#!/bin/bash
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_PATH="/tmp/mongo-backup-$TIMESTAMP.gz"

echo "Running MongoDB backup..."
mongodump --archive=$BACKUP_PATH --gzip --uri="$MONGO_URI"

aws s3 cp $BACKUP_PATH s3://myapp-backups/mongo-backup-$TIMESTAMP.gz
rm -f $BACKUP_PATH
echo "✅ Mongo backup completed."
