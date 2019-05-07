#!/bin/bash

sourcepath="/.../container folder/_data/backups/"
backuppath="/backup/sub folder/"


#delete  more 1 day file
deletefile ()
{
echo "delete..."
find $backuppath -type f  -mtime +0 -exec rm -rf {} \;  
}


backups () 
{

echo "backup....."
find $sourcepath -type f  -mtime 0  | xargs -i cp -f {}   $backuppath  
}


#check remote_nas can  connet
if [ -f "/backup/connettest.txt" ];then

   backups
   deletefile
else
   echo "file no exists"
   mount -t cifs -o username="username",password="userpw" //remote_nas/git-backup /backup  
fi
