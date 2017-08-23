#!/bin/bash
#getlog.sh


#date-time
eval $(date +Y=%Y\;m=%m\;d=%d\;H=%H\;M=%M)
if   [[ "$M" < "15" ]] ; then M=00
elif [[ "$M" < "30" ]] ; then M=15
elif [[ "$M" < "45" ]] ; then M=30
else M=45
fi
TimeStamp="$Y$m$d-$H:$M"
LogDate="$Y$m$d"

#create folder for date
if [ ! -d "/home/logs/$LogDate" ]; then
        cd /home/logs
        mkdir $LogDate
        echo "Created new logs dir: $LogDate"
fi

#make file list
docker ps --format "table {{.ID}}-{{.Names}}" | sed '1d' > "/home/logs/$LogDate/data.txt"
file="/home/logs/$LogDate/data.txt"
while IFS='-' read -r col1 col2
do
# display $line or do somthing with $line
cp $(docker inspect $col1 | grep 'LogPath' | sed -e 's/,//g' -e 's/"//g' -e 's/LogPath: //g') /home/logs/$LogDate/$col2-$TimeStamp.log;
echo "$col1 - $col2";
done <"$file"

cd /home/logs/$LogDate
zip -r "log-$TimeStamp.zip" *
rm *.log
ls -l