#!/bin/bash
#
# make : ivan
# output mailq message and format it.
# get postqueue  mail subject and send mail to user
#

today=$(date +%y%m%d%H%M)
filemae=/root/$today-mailq.log
dirlist=(`ls /var/spool/postfix/deferred/`)


#urldecode subject to big5

function urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}



#format Qid message 

function formatmail() {
formhost=$(/usr/sbin/postcat $1 |grep  client_address |grep -v log | grep 192.168 |cut -d "=" -f 2 )
formdate=$(/usr/sbin/postcat $1 |grep  "Date:"| awk -F " "  '{$1="";NF-- ;print }')
touser=$(/usr/sbin/postcat $1 |grep original_recipient | grep -v datasv | cut -d " " -f 2)
subject=$(/usr/sbin/postcat $1 |grep  Subject)
subject=${subject//\=?big5?Q\?/}
subject=${subject//\?=/}
subject=(${subject//=/%})
decode=$(urldecode ${subject[1]})


declare -i ctime=`date --date="$formdate" +%s`
declare -i ntime=`date +%s`
declare -i date_total_s=$(($ntime - $ctime))
declare -i date_d=$(($date_total_s/60/60/24))
if [ "$date_d" -gt "1" ];then
echo $1 "is " $date_d " ago."
rm -f $1

else

cat  << EOF   >> $filemae
From : $formhost 
CreateDate : $formdate 
To : $touser
Subject : $decode 
EOF
fi

}


length1=${#dirlist[@]}

#for dirname in $dirlist
for (( i=0;i<$length1;i++))

do
mailid=(`ls /var/spool/postfix/deferred/${dirlist[$i]}`)
length2=${#mailid[@]}

#for postid in $mailid
for (( j=0;j<$length2;j++))

do

#formatmail 

if [ $i -ne $[$length1+1] ]&&[ $j -ne $[$length2] ];then
printf " ------------------------- " >>  $filemae
printf "\n" >>  $filemae
fi
printf "QID:"${mailid[$j]} >>  $filemae
printf "\n" >>  $filemae
formatmail /var/spool/postfix/deferred/${dirlist[$i]}/${mailid[$j]}; 




done
done

#send mail attach subject  list file to user
echo "list to u" | mutt -s "mailq list " user@mail.com.tw -a $filemae
rm -f $filemae
