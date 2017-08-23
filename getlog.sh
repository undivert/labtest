#!/bin/bash
#std_input line 1: 1, 2, 3, a, 6,5
#std_input line 2: 1

#datetime area
eval $(date +Y=%Y\;m=%b\;d=%d\;H=%H\;M=%M)
if   [[ "$M" < "15" ]] ; then M=00
elif [[ "$M" < "30" ]] ; then M=15
elif [[ "$M" < "45" ]] ; then M=30
else M=45
fi

TimeStamp="$Y$m$d-$H:$M"
LogDate="$Y$m$d"
LogDir="/home/logs"

#create folder for date
if [ ! -d "$LogDir/$LogDate" ]; then
        cd $LogDir || exist
        mkdir "$LogDate"
        echo "Created new logs dir: $LogDate"
fi

#read string
echo "..............................................."
echo ".......Please input as below list below: ......"
echo "..............................................."
echo "............. 0 > ALl"
echo "............. 1 > web"
echo "............. 2 > submission"
echo "............. 3 > notification"
echo "............. 4 > integration"
echo "............. 5 > print"
echo "............. 6 > oauth"
echo "............. 7 > case"
echo "..............................................."
echo "................. a     > Input FILTER"
echo "................. 100   > EXIT"
echo "..............................................."
echo "..............................................."
read -r -p 'input here (Ex: 1,2,3,a): ' string
echo ".......Your input:............................."
echo "${string}"
#compress file function
compress_file() {
# archieve log
cd "$LogDir/$LogDate" || exit
new_name="$(echo $string | sed 's/0/All/g; s/1/web/g; s/2/submission/g; s/3/notification/g; s/4/integration/g; s/5/print/g; s/6/oauth/g; s/7/case/g; s/a//g')-$1"
zip -r "$HOSTNAME-($new_name)-$TimeStamp.zip" *.log
rm *.log
ls -l

}
#make function
make_log() {
#make file list
if [[ $1 != "all" ]];then
echo "Make log for $1"
	docker ps --format "table {{.ID}}-{{.Names}}" | grep "$1" > "$LogDir/$LogDate/data.txt"
else
	docker ps --format "table {{.ID}}-{{.Names}}" | sed '1d' > "$LogDir/$LogDate/data.txt"
fi

file="$LogDir/$LogDate/data.txt"

while IFS='-' read -r col1 col2
do
#make file name easy to read
col2=${col2%.*}
#copy log file
if [[ $2 != "" ]]; then
#Cat log file, filter and change name
	cat $(docker inspect --format='{{.LogPath}}' "$col1") | grep "$2" > "$LogDir/$LogDate/$col2-$TimeStamp.log";
else
#Copy log file and change name
	cp $(docker inspect --format='{{.LogPath}}' "$col1") "$LogDir/$LogDate/$col2-$TimeStamp.log";
fi
echo "$col1 - $col2";
done <"$file"

#add filter to filename
if [[ $2 != "" ]]; then
	 filter_name="$(echo $2 | sed 's|/|-|g')"
fi
#call compress_file function
compress_file "$filter_name"
}

#read string to array
IFS=', ' read -r -a array <<< "$string"

#check string for filter
if [[ $string == *"a"* ]]; then
	echo "....................Input filter....................."
	echo "........Ex: 20/Aug/2017:13:48 ......................."
	echo "........Ex: BCN12354566458454 ......................."
	echo "....................................................."
    read -r -p "........... Input filter: " filter
else
    echo "There is no filter"
	filter="";
fi

#loop through array
for element in "${array[@]}"
do
    echo "$element"
    if [ "$element" == a ]; then
      echo "Continue making logs"
    else
        mycase="$element"
        case $mycase in
            0) make_log 'all' "$filter"
            ;;
            1) make_log 'web' "$filter"
            ;;
            2) make_log 'submission' "$filter"
            ;;
            3) make_log 'notification' "$filter"
            ;;
            4) make_log 'integration' "$filter"
            ;;
            5) make_log 'print' "$filter"
            ;;
            6) make_log 'oauth' "$filter"
            ;;
			7) make_log 'case' "$filter"
            ;;
            100) exit
            ;;
        esac
        # end case
    fi
done


