#!/bin/bash

if [ $# -ne 4 ]; then
    echo usage:
    echo param1: backupdir
    echo param2: remote_backupdir
    echo param3: remote_user
    echo param4: remote_host
    exit 1
fi

PATH_TO_BACKUPDIR=$1
PATH_TO_REMOTE_BACKUPDIR=$2
REMOTE_USER="$3"
REMOTE_HOST="$4"

binlogs_path=/var/log/mysql/

backup_folder=$PATH_TO_BACKUPDIR/bin/

# make new binlog
sudo mysql -E --execute='FLUSH BINARY LOGS;' mysql

if [ $? -ne 0 ]; then
    echo "error make new binlog"
    exit 1
fi

# get binlogs
binlogs=$(sudo mysql -E --execute='SHOW BINARY LOGS;' mysql | grep Log_name | sed -e 's/Log_name://g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

if [ $? -ne 0 ]; then
    echo "error get binlogs"
    exit 1
fi

binlogs_without_Last=`echo "${binlogs}" | head -n -1`

binlog_Last=`echo "${binlogs}" | tail -n -1`

binlogs_fullPath=`echo "${binlogs_without_Last}" | xargs -I % echo $binlogs_path%`

sudo zip -j $backup_folder/$(date +%d-%m-%Y_%H-%M-%S).zip $binlogs_fullPath

if [ $? -ne 0 ]; then
    echo "error zip"
    exit 1
fi

echo $binlog_Last | xargs -I % sudo mysql -E --execute='PURGE BINARY LOGS TO "%";' mysql

if [ $? -ne 0 ]; then
    echo "error purge binlogs"
    exit 1
fi

# sync binlog with remote

BINLOG_DIR="$PATH_TO_BACKUPDIR/bin/*"
REMOTE_BINLOG_DIR="$PATH_TO_REMOTE_BACKUPDIR/bin/"

rsync -avz -e ssh $BINLOG_DIR $REMOTE_USER@$REMOTE_HOST:$REMOTE_BINLOG_DIR

if [ $? -ne 0 ]; then
    echo "error binlog copy"
    exit 1
fi

rm -r $PATH_TO_BACKUPDIR/bin/*
