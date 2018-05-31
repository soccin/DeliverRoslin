#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"
BDIR=$SDIR/DeliverRoslinV2

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
ls $PDIR/analysis/* | xargs -n 1 -I % ln -s % $ODIR/results
convert $PDIR/facets/*hisen*png $ODIR/results/${projectNo}.hisens.CNCF.pdf
convert $PDIR/facets/*purity*png $ODIR/results/${projectNo}.purity.CNCF.pdf
Rscript --no-save $BDIR/bindRowsTSV.R \
    $ODIR/results/${projectNo}.purity.cncf.txt $PDIR/facets/*purity*.cncf.txt

Rscript --no-save $BDIR/bindRowsTSV.R \
    $ODIR/results/${projectNo}.hisens.cncf.txt $PDIR/facets/*hisens*.cncf.txt

ln -s $PDIR/portal $ODIR/output


# find $PDIR -type f \
#     | egrep -f $SDIR/DeliverRoslinV2/includeReExpr \
#     | xargs -n 1 $SDIR/DeliverRoslinV2/deepSymLink.sh $ODIR/$projectNo

# find $PDIR -type f \
#     | egrep 'qc/.*.txt' | fgrep -v printreads \
#     | xargs -n 1 $SDIR/DeliverRoslinV2/deepSymLink.sh $ODIR/$projectNo

# find $PDIR -type f \
#     | egrep _request.txt \
#     | xargs -I % ln -s % $ODIR/$projectNo/inputs
