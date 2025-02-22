#!/bin/bash
# place it into autobackup dir
# autobackup
# - binlog_backup.sh
# - binlog_backup.service 
# - binlog_backup.timer
#
# - backup_logic.sh
# - backup_logic.service
# - backup_logic.timer

if [ $# -ne 4 ]; then
    echo usage:
    echo param1: remote_user
    echo param2: current_user
    echo param3: remote_host
    echo param4: backupdir
    exit 1
fi

REMOTE_USER=$1
CURR_USER=$2
REMOTE_HOST=$3
PATH_TO_BACKUPDIR=$4

#sudo ssh-keygen -t rsa -b 4096 &&
#sudo ssh-copy-id -i /root/.ssh/id_rsa.pub $REMOTE_USER@$HOST
#
#if [ $? -ne 0 ]; then
#    echo "error ssh handshake"
#    exit 1
#fi

sudo apt install zip

# LOGIC BACKUP INIT -----------------------------------------------------------

sudo chmod +x backup_logic.sh &&
mkdir -p /home/$CURR_USER/.local/bin &&
cp backup_logic.sh ~/.local/bin

if [ $? -ne 0 ]; then
    echo "error copy backup_logic.sh"
    exit 1
fi

sudo cp backup_logic.service backup_logic.timer /etc/systemd/system/

if [ $? -ne 0 ]; then
    echo "error copy systemd units"
    exit 1
fi

sudo mkdir -p $PATH_TO_BACKUPDIR/bin

if [ $? -ne 0 ]; then
    echo "error mkdir path to backup"
    exit 1
fi

sudo systemctl daemon-reload &&
sudo systemctl enable backup_logic.timer &&
sudo systemctl start backup_logic.timer

if [ $? -ne 0 ]; then
    echo "error starting systemd unit"
    exit 1
fi

# BINLOG BACKUP INIT -----------------------------------------------------------

sudo chmod +x binlog_backup.sh &&
mkdir -p /home/$CURR_USER/.local/bin &&
cp binlog_backup.sh ~/.local/bin

if [ $? -ne 0 ]; then
    echo "error copy binlog_backup.sh"
    exit 1
fi

sudo cp binlog_backup.service binlog_backup.timer /etc/systemd/system/

if [ $? -ne 0 ]; then
    echo "error copy systemd units"
    exit 1
fi

sudo mkdir -p $PATH_TO_BACKUPDIR/bin

if [ $? -ne 0 ]; then
    echo "error mkdir path to backup"
    exit 1
fi

sudo systemctl daemon-reload &&
sudo systemctl enable binlog_backup.timer &&
sudo systemctl start binlog_backup.timer

if [ $? -ne 0 ]; then
    echo "error starting systemd unit"
    exit 1
fi
