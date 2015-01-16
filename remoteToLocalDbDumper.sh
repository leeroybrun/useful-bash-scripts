#!/bin/bash

#################################################################
# Small utility letting you remotely dump a database and import
# it to the local MySQL instance.
#
# Remote and local DB name, user & password must be the same.
#################################################################

REMOTE_IP="xxx.xxx.xxx.xxx"
REMOTE_PORT="22"

echo ""
echo "========================================================="
echo " WELCOME to remote to local database dumper utility"
echo "========================================================="
echo ""

read -p "Enter remote SSH username: " remoteUser
read -p "Enter DB name: " dbName
read -p "Enter DB userame: " dbUser
read -s -p "Enter DB password: " dbPwd
echo

if [ "$remoteUser" == "root" ]; then
	dumpRemoteFilePath="/root"
else
	dumpRemoteFilePath="/home/$remoteUser"
fi

dumpRemoteFileName="$dumpRemoteFilePath/${dbName}_dump.sql"
dumpLocalFileName="/tmp/${dbName}_dump.sql"

echo ""
echo "MySQL dump remote file name : $dumpRemoteFileName"
echo "MySQL dump local file name : $dumpLocalFileName"
echo ""
echo ""
echo "---------------------------------------------------------"
echo " WARNING! If you are prompted to enter a password, "
echo " please enter the one from the remote SSH user."
echo "---------------------------------------------------------"
echo ""
echo ""
echo "Removing eventual previous dump on remote & local server..."
rm -f $dumpLocalFileName
ssh -p $REMOTE_PORT $remoteUser@$REMOTE_IP "rm -f $dumpRemoteFileName"

echo "Executing mysqldump on remote server..."

ssh -p $REMOTE_PORT $remoteUser@$REMOTE_IP "mysqldump -u $dbUser -p$dbPwd $dbName > $dumpRemoteFileName"

echo "Fetching dump from remote server..."

scp -P $REMOTE_PORT $remoteUser@$REMOTE_IP:$dumpRemoteFileName "$dumpLocalFileName"

echo "Importing dump to local database..."

mysql -u $dbUser -p$dbPwd $dbName < "$dumpLocalFileName"

echo "All done!"

exit 0
