#!/bin/bash

ODIR=$1
FILE=$2

FOLDER=$(dirname $FILE | perl -pe 's|.*Proj[^/]*/||')

mkdir -p $ODIR/$FOLDER
ln -s $FILE $ODIR/$FOLDER
