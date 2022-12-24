#!/bin/bash

# Make pipeline return code the last non-zero one or zero if all the commands return zero.
set -o pipefail

## \file
## \TODO This file implements a very trivial feature extraction; use it as a template for other front ends.
## 
## Please, read SPTK documentation and some papers in order to implement more advanced front ends.

# Base name for temporary files
base=/tmp/$(basename $0).$$ 

# Ensure cleanup of temporary files on exit
trap cleanup EXIT
cleanup() {
   \rm -f $base.*
}

<<<<<<< HEAD
if [[ $# != 4 ]]; then
=======
if [[ $# != 3 ]]; then
>>>>>>> 5f628466f2813e3d95fd1810a92f373bf3b4d892
   echo "$0 lpc_order lpcc_order input.wav output.lpcc"
   exit 1
fi

lpc_order=$1
lpcc_order=$2
inputfile=$3
outputfile=$4

UBUNTU_SPTK=1
if [[ $UBUNTU_SPTK == 1 ]]; then
   # In case you install SPTK using debian package (apt-get)
   X2X="sptk x2x"
   FRAME="sptk frame"
   WINDOW="sptk window"
   LPC="sptk lpc"
<<<<<<< HEAD
   LPCC="sptk lpc2c"
=======
   LPC2C="sptk lpc2c"
>>>>>>> 5f628466f2813e3d95fd1810a92f373bf3b4d892
else
   # or install SPTK building it from its source
   X2X="x2x"
   FRAME="frame"
   WINDOW="window"
   LPC="lpc"
<<<<<<< HEAD
   LPCC="lpc2c"
=======
   LPC2C="lpc2c"
>>>>>>> 5f628466f2813e3d95fd1810a92f373bf3b4d892
fi

# Main command for feature extration
sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
<<<<<<< HEAD
	$LPC -l 240 -m $lpc_order | $LPCC -m $lpc_order -M $lpcc_order > $base.lp || exit 1
   

# Our array files need a header with the number of cols and rows:
ncol=$((lpc_order+1)) # lpc p =>  (gain a1 a2 ... ap) 
nrow=`$X2X +fa < $base.lp | wc -l | perl -ne 'print $_/'$ncol', "\n";'`
=======
	$LPC -l 240 -m $lpc_order | $LPCC -m $lpc_order -M $lpcc_order> $base.lpcc || exit 1
   

# Our array files need a header with the number of cols and rows:
ncol=$((lpcc_order+1)) # lpcc p =>  (gain a1 a2 ... ap) 
nrow=`$X2X +fa < $base.lpcc | wc -l | perl -ne 'print $_/'$ncol', "\n";'`
>>>>>>> 5f628466f2813e3d95fd1810a92f373bf3b4d892

# Build fmatrix file by placing nrow and ncol in front, and the data after them
echo $nrow $ncol | $X2X +aI > $outputfile
cat $base.lpcc >> $outputfile
