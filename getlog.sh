#!/bin/bash
#getlog.sh


#date-time
eval $(date +Y=%Y\;m=%m\;d=%d\;H=%H\;M=%M)
if   [[ "$M" < "15" ]] ; then M=00
elif [[ "$M" < "30" ]] ; then M=15
elif [[ "$M" < "45" ]] ; then M=30
else M=45
fi
TimeStamp="$Y.$m.$d-$H:$M"

#copy logs

Pattern1=$1
Pattern2=$2

echo $Pattern1;
echo $Pattern2;
echo $TimeStamp;

if [ "$Pattern2" != "" ]
then
    echo "If have PATTERN2"
	cp $(docker inspect $(docker ps | grep $Pattern1 | awk '{print $1}') | grep 'LogPath' | sed -e 's/,//g' -e 's/"//g' -e 's/LogPath: //g') /home/logs/$Pattern1-$TimeStamp.log
	LogFile=cat /home/logs/$Pattern1-$TimeStamp.log
	Newfile=$LogFile | grep $Pattern2 > /home/logs/$Pattern1-$Pattern2.log
else
    cp $(docker inspect $(docker ps | grep $Pattern1 | awk '{print $1}') | grep 'LogPath' | sed -e 's/,//g' -e 's/"//g' -e 's/LogPath: //g') /home/logs/$Pattern1-$TimeStamp.log
fi