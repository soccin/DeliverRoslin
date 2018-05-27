#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ "$#" -lt "1" ]; then
    echo
    echo "   usage: deliverRoslinV2.sh PROJECT_DIR [ODIR]"
    echo ""
    echo "     ODIR='.' [DEFAULT]"
    exit
fi

ODIR="."
if [ "$#" == "2" ]; then
    ODIR=$2
fi

PDIR=$1
PDIR=$(echo $PDIR | perl -pe 's|/$||')
BASE=$(basename $PDIR)
projectNo=$(basename $BASE | perl -ne 'print substr($_,0,-38);')

find $PDIR -type f \
    | egrep -f $SDIR/DeliverRoslinV2/includeReExpr \
    | xargs -n 1 $SDIR/DeliverRoslinV2/deepSymLink.sh $ODIR/$projectNo

find $PDIR -type f \
    | egrep 'qc/.*.txt' | fgrep -v printreads \
    | xargs -n 1 $SDIR/DeliverRoslinV2/deepSymLink.sh $ODIR/$projectNo

find $PDIR -type f \
    | egrep _request.txt \
    | xargs -I % ln -s % $ODIR/$projectNo/inputs
