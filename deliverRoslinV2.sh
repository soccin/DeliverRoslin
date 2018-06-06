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

#
# FACETS Stuff
#
convert $PDIR/facets/*hisen*png $ODIR/results/${projectNo}.hisens.CNCF.pdf
convert $PDIR/facets/*purity*png $ODIR/results/${projectNo}.purity.CNCF.pdf
Rscript --no-save $BDIR/bindRowsTSV.R \
    $ODIR/results/${projectNo}.purity.cncf.txt $PDIR/facets/*purity*.cncf.txt

Rscript --no-save $BDIR/bindRowsTSV.R \
    $ODIR/results/${projectNo}.hisens.cncf.txt $PDIR/facets/*hisens*.cncf.txt

ln -s $PDIR/portal $ODIR/output

Rscript --no-save $BDIR/collectFacetsOUT.R \
    $ODIR/results/${projectNo}.purity \
    $PDIR/facets/*purity.out

Rscript --no-save $BDIR/collectFacetsOUT.R \
    $ODIR/results/${projectNo}.hisens \
    $PDIR/facets/*hisens.out

#
# Fusions
#

ln -s $PDIR/portal/data_fusions.txt $ODIR/results/${projectNo}.fusions.txt

mkdir -p $ODIR/output/qc
ls $PDIR/qc/*.txt | fgrep -v printreads | xargs -n 1 -I % ln -s % $ODIR/output/qc

mkdir -p $ODIR/output/maf
ls $PDIR/maf/* | xargs -n 1 -I % ln -s % $ODIR/output/maf

mkdir -p $ODIR/output/vcf
ls $PDIR/vcf/* | xargs -n 1 -I % ln -s % $ODIR/output/vcf

mkdir -p $ODIR/output/log
ls $PDIR/log/*.* | xargs -n 1 -I % ln -s % $ODIR/output/log

mkdir -p $ODIR/output/facets
ls $PDIR/facets/* | fgrep -v Rdata | fgrep -v dat.gz | xargs -n 1 -I % ln -s % $ODIR/output/facets

mkdir -p $ODIR/docs/inputs
ln -s $PDIR/*_request.txt $ODIR/docs/inputs
ls $PDIR/inputs/* | xargs -n 1 -I % ln -s % $ODIR/docs/inputs
ln -s $PDIR/log/settings $ODIR/docs/inputs

cp $BDIR/manifest.pdf $ODIR/docs

mkdir -p $ODIR/docs/qc
ln -s $PDIR/qc/*_QC_Report.pdf $ODIR/docs/qc

