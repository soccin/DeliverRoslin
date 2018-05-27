#!/bin/bash

TMSG=tmpMsg_$$
#TMSG=tmpMsg_22397

cat >$TMSG
echo

cat $TMSG | egrep "@" | sed 's/.*: //' | sort | uniq | xargs | tr ' ' ','
echo
cat $TMSG | egrep Data_Analyst
cat $TMSG | egrep Project_Manager
echo
PNAME=$(cat $TMSG | fgrep ProjectName: | sed 's/.*: //')
PROJECT_NUM=$(cat $TMSG | fgrep ProjectID: | sed 's/.*Proj_//')
ProjectDesc=$(cat $TMSG | fgrep ProjectDesc: | sed 's/ProjectDesc: //')

echo
echo "======================================================="
echo Subject: Exome project $PNAME \(${PROJECT_NUM}\) results ready
echo
echo The output for Exome project $PNAME is ready
echo
echo ProjectDesc: $ProjectDesc
echo
echo QC Review: NA
echo
echo You can access them on LUNA at:
echo
echo     /ifs/res/share//Proj_${PROJECT_NUM}
echo
echo Documentation for this output can be found at:
echo
echo     https://mskcc.github.io/roslin-helix/
echo
echo Nicholas Socci
echo Bioinformatics Core
echo MSKCC
echo socci@cbio.mskcc.org
echo

rm $TMSG
