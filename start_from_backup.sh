#!/bin/bash

# 1. установка mysql и копирование сохраненного конфига
# 2. распаковка полной копии из *.sql
# 3. распаковка итеративного бинарного дополнения
# 4. проверка целостности
#
# structure:
#     backup
#      - bin/
#      - full/
#      - mysqld_master.cnf
#      - mysqld_slave.cnf


if [ $# -ne 2 ]; then
    echo usage:
    echo param1: backup
    echo param2: database name
    exit 1
fi

PATH_TO_BACKUPDIR=$1
DATABASE_NAME=$2

PATH_TO_FULL_DUMP=$PATH_TO_BACKUPDIR/full
PATH_TO_UNZIPPED_FULL_DUMP=/tmp/full_logicdump.sql
PATH_TO_MYSQLD_CONFDIR=/etc/mysql/mysql.conf.d/mysql

sudo apt update &&
sudo apt install -y mysql-server unzip

sudo systemctl restart mysql

if [ $? -ne 0 ]; then
    echo "error restarting mysql-server"
    exit 1
fi

#LATEST_FULL_ZIP_FILE=/path/to/zip
LATEST_FULL_ZIP_FILE=$(ls $PATH_TO_FULL_DUMP | grep -E '^[0-9]{2}-[0-9]{2}-[0-9]{4}_[0-9]{2}-[0-9]{2}-[0-9]{2}' | sort -r | head -n 1)
LATEST_FULL_ZIP=$PATH_TO_FULL_DUMP/$LATEST_FULL_ZIP_FILE
gunzip -c $LATEST_FULL_ZIP > $PATH_TO_UNZIPPED_FULL_DUMP

if [ $? -ne 0 ]; then
    echo "error unpack full dump"
    exit 1
fi

PATH_TO_IT_DUMP=$PATH_TO_BACKUPDIR/bin
PATH_TO_UNZIPPED_IT_DUMP=/tmp/it_dump

LATEST_FULL_DATE=$(echo "$LATEST_FULL_ZIP_FILE" | grep -oE '^[0-9]{2}-[0-9]{2}-[0-9]{4}_[0-9]{2}-[0-9]{2}-[0-9]{2}')

#LATEST_IT_ZIP_FILES={'file1.zip', ...}
LATEST_IT_ZIP_FILES=$(ls $PATH_TO_IT_DUMP | grep -E '^[0-9]{2}-[0-9]{2}-[0-9]{4}_[0-9]{2}-[0-9]{2}-[0-9]{2}' | awk -v latest="$LATEST_FULL_DATE" '$0 >= latest')

echo "$LATEST_IT_ZIP_FILES" | xargs -I {} unzip "$PATH_TO_IT_DUMP/{}" -d $PATH_TO_UNZIPPED_IT_DUMP

if [ $? -ne 0 ]; then
    echo "error unpack it dump"
    exit 1
fi

sudo mysql -e "CREATE DATABASE $DATABASE_NAME;"

if [ $? -ne 0 ]; then
    echo "error create database"
    exit 1
fi

sudo mysql < $PATH_TO_UNZIPPED_FULL_DUMP

if [ $? -ne 0 ]; then
    echo "error restoring full dump"
    exit 1
fi

BINLOGS=$(ls $PATH_TO_UNZIPPED_IT_DUMP | sed "s|^|$PATH_TO_UNZIPPED_IT_DUMP/|")
sudo mysqlbinlog $BINLOGS | sudo mysql -u root

if [ $? -ne 0 ]; then
    echo "error restoring it dump"
    exit 1
fi
