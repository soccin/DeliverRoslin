#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ "$#" -lt "1" ]; then
    echo
    echo "   usage: deliverRoslinV2.sh PROJECT_DIR [ODIR]"
    echo ""
    echo "     ODIR='.' [DEFAULT]"
    echo
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

ODIR=$ODIR/$projectNo

echo $ODIR
mkdir -p $ODIR/bams
mkdir -p $ODIR/docs
mkdir -p $ODIR/results
mkdir -p $ODIR/output

ls $PDIR/bam/*.ba? | xargs -n 1 -I % ln -s % $ODIR/bams


# find $PDIR -type f \
#     | egrep -f $SDIR/DeliverRoslinV2/includeReExpr \
#     | xargs -n 1 $SDIR/DeliverRoslinV2/deepSymLink.sh $ODIR/$projectNo

# find $PDIR -type f \
#     | egrep 'qc/.*.txt' | fgrep -v printreads \
#     | xargs -n 1 $SDIR/DeliverRoslinV2/deepSymLink.sh $ODIR/$projectNo

# find $PDIR -type f \
#     | egrep _request.txt \
#     | xargs -I % ln -s % $ODIR/$projectNo/inputs
