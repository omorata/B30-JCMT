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

shopt -s expand_aliases
source ${ORAC_DIR}/etc/oracdr_acsis.sh -cwd


source $inconf

ORAC_DATA_OUT=${RES_DIR}/${ORAC_DATA_OUT}
LIST_FILE=${CFG_DIR}/${LIST_FILE}
PARAMS=${CFG_DIR}/$PARAMS

export ORAC_DATA_IN
export ORAC_DATA_OUT


if [[ ! -d ${ORAC_DATA_OUT} ]]
then
    mkdir -p ${ORAC_DATA_OUT}
fi


LOGFILE=${ORAC_DATA_OUT}/oracdr.log

reduced_file=${ORAC_DATA_OUT}/${REDUCED_FILE}
integ_file=${ORAC_DATA_OUT}/${INTEG_FILE}
result_file=${ORAC_DATA_OUT}/${OUTPUT_FILE}
outinteg_file=${ORAC_DATA_OUT}/${OUT_INTEG}

touch $LOGFILE
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
oracdr \
	   -file $LIST_FILE \
	   -loop file -batch \
	   -nodisplay \
	   -log sf \
	   -verbose \
	   -recpars $PARAMS $RECIPE \
	   -onegroup |tee -a $LOGFILE

echo "aaaa" $?

# change the name of the reduced data file
#
if [[ -f ${reduced_file} && -f ${integ_file} && -n ${result_file} \
	  && -n ${outinteg_file} ]]
then
    echo "Copying to $OUTPUT_FILE"
    mv ${reduced_file} ${result_file} | tee -a $LOGFILE
    mv ${integ_file} ${outinteg_file} | tee -a $LOGFILE
fi


# move unwanted files out of the way
#
reduced_blocks=${ORAC_DATA_OUT}/reduced_blocks

if [[ ! -d  $reduced_blocks ]]
then
    mkdir ${reduced_blocks}
fi

cd ${ORAC_DATA_OUT}
if [[ -f a*sdf ]]
then
    echo;echo "   moving data to reduced_blocks..." | tee -a $LOGFILE
    
    mv a*sdf ga*sdf *png   $reduced_blocks
    mv disp.dat log.* CCDPACK.LOG $reduced_blocks
    rm -f oractemp*
    rm -f t*sdf
fi

echo "   ... done" |tee -a $LOGFILE
echo

