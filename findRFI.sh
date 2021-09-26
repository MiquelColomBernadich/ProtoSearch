#!/bin/bash
#
#-------------------------------------------------------------------------------------------------------------------------#
# Call the "seek" SIGPROC search command on the first 10 cm-3/pc DM interval to look for strong RFI signals.
# The DM step is computed as indicated in equation 6.6 from Lorimer & Kramer (2005).
#-------------------------------------------------------------------------------------------------------------------------#
# Calls dmFactor.py
#-------------------------------------------------------------------------------------------------------------------------#
# Arguments:
# - $1 ({filterbank}): the name of the observation, as in {filterbank}.fil
#-------------------------------------------------------------------------------------------------------------------------#
# Inputs:
# - {filterbank}.fil: the filterbank containing the observation data.
# - "birdies" file in the same directory as this scrip to zap unzanted frequencies from the Fourier domain.
#-------------------------------------------------------------------------------------------------------------------------#
# Outputs:
# - {filterbank}.top, a direct output from the seek sigproc command (columns of DM, P, S/N).
# - {filterbank}.prd, a direct output from the seek sigproc command.
# - {filterbank}_header.txt, containing the result of >> header {filterbank}.fil
#-------------------------------------------------------------------------------------------------------------------------#
# Usage example:
# >> bash findPulsarInterval.sh "../random/folder/observation1"
# This command will make produce a .top and .prd file containing candidates in the first 5 cm-3/pc DM interval.
#-------------------------------------------------------------------------------------------------------------------------#
# Miquel Colom Bernadich i la mare que el va parir, 20/01/2021
#-------------------------------------------------------------------------------------------------------------------------#
#
# Name of the file, without the .fil termination.
filterbank=$1
# Build a header file for consultation.
header ${filterbank}.fil > ${filterbank}_header.txt
# Read rellevant cantities from it.
tsamp=$(header ${filterbank}.fil -tsamp)
first_frequency=$(header ${filterbank}.fil -fch1)
bandpass=$(header ${filterbank}.fil -foff)
nchannels=$(header ${filterbank}.fil -nchans)
tobs=$(header ${filterbank}.fil -tobs)
# Print them on screen to increase the coolness factor.
echo "Time sampling (us):                  $tsamp"
echo "Observation lenght (s):              $tobs"
echo "Frequency of first channel (MHz):    $first_frequency"
echo "Channel bandwidth (MHz):             $bandpass"
echo "Number of channels:                  $nchannels"
# Compute the DM base unit. Every DM trial is a multiple of this base unit.
dmFactor=$(python3 dmFactor.py $tsamp $first_frequency $bandpass $nchannels)
echo "Staring loop over the 5 cm-3/pc first DM values with initial step of $dmFactor cm-3/s"
# Perform the dm loops
for dm in `seq 0 ${dmFactor} 10`; do
	echo "DM (cm-3/pc):                        $dm"
	dedisperse ${filterbank}.fil -d ${dm} > time_series_${dm}.tim
	seek time_series_${dm}.tim -z
	rm time_series_${dm}.tim
	echo " "
done
cat *.top > ${filterbank}.top
cat *.prd > ${filterbank}.prd
echo "Done! Have a nice day! Or a bad one, because there is nothing more frustrating than being told 'Have a nice day' when we are having a bad one."
