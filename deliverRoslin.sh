#!/bin/bash

if [ "$#" -lt "1" ]; then
    echo
    echo "   usage: deliverRoslin.sh PROJECT_DIR"
    echo
    exit
fi


PDIR=$1
PDIR=$(echo $PDIR | perl -pe 's|/$||')
BASE=$(basename $PDIR)
if [ "$BASE" == "DONE" ]; then
    PDIR=$(dirname $PDIR)
    BASE=$(basename $PDIR)
fi
PROJECT=$(echo $BASE | sed 's/\..*//')
UUID=$(echo $BASE | perl -pe 's/^[^.]*\.//')
echo $PDIR
echo $BASE $PROJECT $UUID

isDone=No
if [ -e $PDIR/DONE ]; then
    isDone=Yes
fi

echo DONE=$isDone

lastRun=""
if [ ! -e $PROJECT ]; then
    echo "Creating Project Directory"
    mkdir -p $PROJECT/r_001
    cp -val $PDIR/* $PROJECT/r_001
    echo $(date) >$PROJECT/r_001/.DELIVERY
    echo "Initial:"$UUID >>$PROJECT/r_001/.DELIVERY
else
    echo "Project Directory $PROJECT already exists"
    lastRun=$(ls -drt $PROJECT/r_* | tail -1 | sed 's/.*r_/r_/')
    if [ "$lastRun" == "" ]; then
        echo "WARNING: No last run/version folder"
        mkdir -p $PROJECT/r_001
        cp -val $PDIR/* $PROJECT/r_001
        echo $(date) >$PROJECT/r_001/.DELIVERY
        echo "Initial:"$UUID >>$PROJECT/r_001/.DELIVERY
    else
        if [ "$lastRun" != "r_001" ]; then
            echo "Can only deal with one relase at this point"
            exit
        fi
        echo "Last Run = $lastRun"
        echo "Copying QC dir only"
        rm -rf $PROJECT/r_001/qc
        cp -al $PDIR/qc $PROJECT/r_001
        echo $(date) >>$PROJECT/r_001/.DELIVERY
        echo "QC-update:"$UUID >>$PROJECT/r_001/.DELIVERY

    fi
fi


