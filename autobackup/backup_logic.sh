#!/bin/bash

if [ $# -ne 4 ]; then
    echo usage:
    echo param1: backupdir
    echo param2: remote backup dir
    echo param3: remote user
    echo param4: remote host
    exit 1
fi

PATH_TO_BACKUPDIR=$1
PATH_TO_REMOTE_BACKUPDIR=$2
REMOTE_USER=$3
REMOTE_HOST=$4

sudo mkdir -p $PATH_TO_BACKUPDIR/full

sudo mysqldump --flush-logs --delete-master-logs --single-transaction --all-databases -R | gzip > $PATH_TO_BACKUPDIR/full/$(date +%d-%m-%Y_%H-%M-%S)-full.gz

# sync logic with remote

FULL_DIR="$PATH_TO_BACKUPDIR/full/*"
REMOTE_FULL_DIR="$PATH_TO_REMOTE_BACKUPDIR/full/"

rsync -avz -e ssh $FULL_DIR $REMOTE_USER@$REMOTE_HOST:$REMOTE_FULL_DIR

if [ $? -ne 0 ]; then
    echo "error full copy"
    exit 1
fi

rm -r $PATH_TO_BACKUPDIR/full/*
