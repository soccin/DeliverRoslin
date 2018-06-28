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
mkdir -p $ODIR/results/variants
mkdir -p $ODIR/results/copyNumber
mkdir -p $ODIR/results/rearrangments
mkdir -p $ODIR/output

ls $PDIR/bam/*.ba? | xargs -n 1 -I % ln -s % $ODIR/bams

Rscript --no-save $BDIR/makeResultsMAF.R \
    $PDIR/portal/data_mutations_extended.txt \
    $PDIR/analysis/${projectNo}.muts.maf \
    $ODIR/results/variants/${projectNo}.muts.portal.maf

ln -s $PDIR/analysis/${projectNo}.muts.maf $ODIR/results/variants/${projectNo}.muts.analysis.maf

#
# FACETS Stuff
#
convert $PDIR/facets/*hisen*png $ODIR/results/copyNumber/${projectNo}.hisens.cncf.pdf
Rscript --no-save $BDIR/bindRowsTSV.R \
    $ODIR/results/copyNumber/${projectNo}.hisens.cncf.txt $PDIR/facets/*hisens*.cncf.txt

Rscript --no-save $BDIR/collectFacetsOUT.R \
    $ODIR/results/copyNumber/${projectNo}.hisens \
    $PDIR/facets/*hisens.out

ln -s $PDIR/analysis/${projectNo}.gene.cna.txt $ODIR/results/copyNumber/${projectNo}.hisens.gene.cna.txt
ln -s $PDIR/analysis/${projectNo}.seg.cna.txt $ODIR/results/copyNumber/${projectNo}.hisens.seg.cna.txt

#
# Fusions
#

ln -s $PDIR/portal/data_fusions.txt $ODIR/results/rearrangments/${projectNo}.fusions.txt

#
# Output
#

ln -s $PDIR/portal $ODIR/output

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

