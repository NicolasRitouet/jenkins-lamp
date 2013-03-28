#!/bin/bash
clear
RED_LED=0
YELLOW_LED=5
GREEN_LED=11
ON=1
OFF=0
echo Initializing...
#initialize the array of jobnames
wget -qO- -O tmpJenkinsJoblistXML1.xml http://jenkins.zanox.com/view/API/api/xml
# replace </name> with </name>\n
sed -e 's/<\/name>/<\/name>\n/g' tmpJenkinsJoblistXML1.xml > tmpJenkinsJoblistXML2.xml
#extract the jobnames
awk 'BEGIN { 
while (getline < "tmpJenkinsJoblistXML2.xml")
{
  LINE=$0;
  NAME_INDEX_START=index($LINE, "<name>") + 6;
  NAME_INDEX_END=index($LINE, "</name>");
  JOB_NAME_LENGTH=NAME_INDEX_END - NAME_INDEX_START;
  JOB_NAME=substr(LINE, NAME_INDEX_START, JOB_NAME_LENGTH);
  gsub(" ", "%20", JOB_NAME)
  print JOB_NAME >> "tmpJenkinsJoblistXML.xml"
}

}'
jobNames=tmpJenkinsJoblistXML.xml
index=0
echo Done!
while read line ; do
JENKINS_JOBS[$index]="$line"
index=$(($index+1))
done < $jobNames 
rm tmpJenkinsJoblistXML.xml
rm tmpJenkinsJoblistXML1.xml
rm tmpJenkinsJoblistXML2.xml
### done

init ()
{
  echo Initializing...
  for i in $RED_LED $YELLOW_LED $GREEN_LED ; do gpio mode $i out ; done
  echo Done!
}
reset ()
{
  gpio write $RED_LED $OFF
  gpio write $YELLOW_LED $OFF
  gpio write $GREEN_LED $OFF
}
setLed ()
{
   gpio write $1 $2
}

getBuildStatus()
{
  # job name
  jobName=$1

  # get the json answer for jobName from jenkins
  jsonString=`wget -qO-  http://jenkins.zanox.com/job/$jobName/api/json`

  # find first occurance of color":" in jsonString
  needle='color":"'
  index=`awk -v a="$jsonString" -v b="$needle" 'BEGIN{print index(a,b)}'`

  # index of first " after the last " in color":"
  index=`expr $index + 8`

  # get 10 characters (red, blue etc.)
  tmpBuildStatus=`expr substr "$jsonString" $index 10`

  # find first " after the color
  tmpEndPos=`expr index "$tmpBuildStatus" \"`
  tmpEndPos=`expr $tmpEndPos - 1`
  # extract the color (red, blue etc.)
  buildStatus=`expr substr $tmpBuildStatus 1 $tmpEndPos`
  if [[ "$buildStatus" == "red" ]]; then
    reset     
    echo "JOB: " $jobName "- STATUS: FAILURE" 
    setLed $RED_LED $ON
    
  fi
  if [[ "$buildStatus" == "grey" ]]; then
    reset 
    echo "JOB: " $jobName "- STATUS: INSTABLE"
    setLed $YELLOW_LED $ON
    
  fi

  if [[ "$buildStatus" == "blue" ]]; then
    reset 
    echo "JOB: " $jobName "- STATUS: SUCCESS"
    setLed $GREEN_LED $ON
    
  fi
}

reset

init
# why -3? magic number...
JOB_COUNT=${#JENKINS_JOBS[@]}-3;
for (( i=0; i<=$JOB_COUNT; i++ ))
do
  tmpJob=${JENKINS_JOBS[$i]}
  echo Checking...for $tmpJob
  getBuildStatus $tmpJob
done
echo Done!
