#!/bin/bash

## reduce_harp.sh
##
## O. Morata 2018
##
## script to reduce HARP data of the observations in Sh2-61
##
HOME_DIR=${HOME_DIR:-.}
RES_DIR=${RES_DIR:-results}
CFG_DIR=${CFG_DIR:-cfg}
BIN_DIR=${BIN_DIR:-src}

set -e

if [ $# -ne 1 ];then
    echo " ** ERROR:  name of configuration file is missing"
    exit 1
fi

inconf=$1
source $inconf

source ${ORAC_DIR}/etc/oracdr_acsis.sh -cwd


source $inconf

ORAC_DATA_OUT=${RES_DIR}/${ORAC_DATA_OUT}
LIST_FILE=${CFG_DIR}/${LIST_FILE}

export ORAC_DATA_IN
export ORAC_DATA_OUT


if [[ ! -d ${ORAC_DATA_OUT} ]]
then
    mkdir -p ${ORAC_DATA_OUT}
fi


LOGFILE=${ORAC_DATA_OUT}/oracdr.log

result_file=${ORAC_DATA_OUT}/${OUTPUT_FILE}
outinteg_file=${ORAC_DATA_OUT}/${OUT_INTEG}

echo
echo "  + species:" $SPEC | tee -a $LOGFILE
echo "  + file list:" $LIST_FILE |tee -a $LOGFILE
echo "  + data directory:" $ORAC_DATA_IN |tee -a $LOGFILE
echo "  + results directory:" $ORAC_DATA_OUT  |tee -a $LOGFILE
echo "  + reduction recipe:" $RECIPE  |tee -a $LOGFILE
echo "  + parameters:" $PARAMS  |tee -a $LOGFILE
echo "  + reduced file:" ${REDUCED_FILE}  |tee -a $LOGFILE
echo "  + integrated file:" ${INTEG_FILE}  |tee -a $LOGFILE
echo "  + output file:" ${OUTPUT_FILE}  |tee -a $LOGFILE
echo "  + output integrated file:" ${OUT_INTEG}  |tee -a $LOGFILE
echo


# do the reduction
#
#oracdr -file $LIST_FILE -loop file -batch -nodisplay -log sf \
#       -verbose -recpars $PARAMS $RECIPE -onegroup |tee -a $LOGFILE


# change the name of the reduced data file
#
if [[ -n ${ORAC_DATA_OUT}/${REDUCED_FILE} && -n ${result_file} ]]
then
    echo "Copying to $OUTPUT_FILE"
    mv ${ORAC_DATA_OUT}/${REDUCED_FILE} ${result_file} | tee -a $LOGFILE
    mv ${ORAC_DATA_OUT}/${INTEG_FILE} ${outinteg_file} | tee -a $LOGFILE
fi


# move unwanted files out of the way
#
reduced_blocks=${ORAC_DATA_OUT}/reduced_blocks

if [[ ! -d  $reduced_blocks ]]
then
    mkdir ${reduced_blocks}
fi

echo;echo "   moving data to reduced_blocks..." | tee -a $LOGFILE
cd ${ORAC_DATA_OUT}
mv a*sdf ga*sdf *png   $reduced_blocks
mv disp.dat log.* CCDPACK.LOG $reduced_blocks
rm -f oractemp*
rm -f t*sdf

echo "   ... done" |tee -a $LOGFILE
echo

