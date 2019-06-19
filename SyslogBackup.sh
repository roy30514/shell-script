#!/bin/bash




######################################
#make: ivan
#time:2019/06/19
#verssion:v2.1
#
#Use the system logrotate  backup syslog.
#then use shell script move backup to backuppath.
#
#
#1.make a logrotate cron in /etc/crontab
#code
# root /usr/sbin/logrotate -f /root/rotate.d/192.168.1*
# root /usr/sbin/logrotate -f /root/rotate.d/192.168.2*
#
#logrotate conf template
#/var/log/HOSTS/192.168.150.1/* {
#  daily    # cycle time
#  missingok  # if don't has file not do .
#  rotate 3   # how mach file
#  compress  # gz compress
#  dateext  #add date after filename.
#  notifempty # if file	is empty is not do .
# copytruncate
#}
#
#
#
#####################################

#####################################
# command EX:
# $1 is under /var/log/HOSTS sub folder name.
#
#sh /root/testbackup.sh 192.168.10.10
####################################

#!/bin/bash

SyslogPath=/var/log/HOSTS
BachupPath=/backup/HOSTS
#Today=$(date +%m%d)
#only save three day syslog
#Delday=$(date +%m%d -d '3 day ago')
Backupfolder=$BachupPath/$1
Syslogfolder=$SyslogPath/$1
Backupfoldercheck=$BachupPath/check.txt





#### Move  syslogs and change name+day.####
function Movefile() {
cd $Syslogfolder
#get  filename in the folder
FileName=$(ls local*-20*)

for  i in $FileName
do
Backupi=$Syslogfolder/$i
if [ -e ${Syslogfolder} ];then
/bin/mv -f $i $Backupfolder/
else
/usr/sbin/logrotate -f /root/rotate.d/$1
/bin/mv -f $i $Backupfolder/ 
fi
done

}


##### check BachupPath

function checkBachupfolder() {
if [ ! -d  ${Backupfolder} ] ; then
mkdir -p $Backupfolder;echo "add folder"
fi
}

##### delete old files

function Deleteold()
{
find $Backupfolder/ -type f -mtime +2 -exec rm -rf {} \;
}





############# Start Backup


function  BackupStart()
{
checkBachupfolder;
Movefile;
Deleteold;
}



##### check Syslogfolder

function checksyslogfolder() {
if [  -d  ${Syslogfolder} ] ; then
BackupStart;
else
sendAlert "folder Does Not Exist"

fi
}



#send Alert to line and mail
function sendAlert(){
#echo $1 | mail -s "ZabbixServer Backup syslog failure" mis@cmoney.net.tw 

/usr/lib/zabbix/alertscripts/linenotify.sh d9nJoqHUiNfbfngxUXLsry98ub3gULkDdAES3lX3wAi SyslogBackupError "$1"



}




if [ "$1" == "" ] ;then
#sendAlert "Need set ipaddree after to shell script or connet to backup error..";
sendAlert "need add vales after shell" 

elif [ ! -f  ${Backupfoldercheck} ] ;then
{
sendAlert "Connet Erorrto Backup"
} 
else
{
checksyslogfolder;
}
fi

