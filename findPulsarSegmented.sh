#!/bin/bash
#
#-------------------------------------------------------------------------------------------------------------------------#
# Perform a search from DM=10 cm-3/pc to DM={chunks}*{nchannels}*DM_step, where the DM step is computed as indicated in
# equation 6.6 from Lorimer & Kramer (2005).
# Every interval DM of {nchannels}*DM_step is called a "chunk", and after effective DM step is {chunk}*DM_step, if chunk
# were to start by 1. The search is done through the "seek" sigpoc command and it is able to read a birdies wile in the
# folder were this script is stored.
#-------------------------------------------------------------------------------------------------------------------------#
# Calls dmFactor.py, dm.py, findPeriod.py and time.py .
#-------------------------------------------------------------------------------------------------------------------------#
# Arguments:
# - $1 ({filterbank}): the name of the observation, as in {filterbank}.fil
# - $2 ({chunks}): the amount of DM periods of {nchannels}*DM_step that one desires to run through
# - $3 ({candidates}): the number of candidates one wants to produce. Fed directly to findPeriod.py
# - $4 ({subintegrations}): the number of subentegrations to keep for the time-phase plot.
#-------------------------------------------------------------------------------------------------------------------------#
# Inputs:
# - {filterbank}.fil: the filterbank containing the observation data.
# - "birdies" file in the same directory as this scrip to zap unzanted frequencies in the Fourier domain.
#-------------------------------------------------------------------------------------------------------------------------#
# Outputs:
# - {filterbank}.top, a direct output from the seek sigproc command (columns of DM, P, S/N)
# - {filterbank}.prd, a direct output from the seek sigproc command
# - {filterbank}_header.txt, containing the result of >> header {filterbank}.fil
# - {filterbank}_bestValues.txt, containing the {candidates} first best candidates in {filterbank}.top, ordered by S/N
# - {filterbank}_{S/N}_folded.ascii, containing the data in the filterbank folded to the period P of the candidate.
# - {filterbank}_{S/N}_folded_series.ascii, containing the time series of the specific candidate.
# - {filterbank}_{S/N}_folded_subseries.ascii, containing the time series of the {subintegrations} subintegrations.
# - {filterbank}_{S/N}_values.txt, containing the DM, P, S/N, first frequency, channel width, observation length and
#   {subintegration} of the specific candidate
# All files with _{S/N}_ are candidate specific.
#-------------------------------------------------------------------------------------------------------------------------#
# Usage example:
# >> bash findPulsarSegmented.sh "../random/folder/observation1" 20 10 15
# This command will make data products for 10 candidates with 15 subintegrations each, in 20 DM "chunks"
#-------------------------------------------------------------------------------------------------------------------------#
# Miquel Colom Bernadich i la mare que el va parir, 17/01/2021
#-------------------------------------------------------------------------------------------------------------------------#
#
# Name of the file, without the .fil termination.
filterbank=$1
# How many "chunks" of DM are to be tried, integer. If smaller than 2, only DM trials up to the first diagonal are done (n_time=n_channels). If larger, then chucnks of equal size are added. With every chunck, the DM steps are incresed by one base unit.
chunks=$2
# Say how many candidates do you want to produce
candidates=$3
# Decide the resolution of the time-phase plot by specifieng how many time bins are desired.
subintegrations=$4
# -------------------------------------------------------- #
# The script begins.                                       #
# -------------------------------------------------------- #
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
echo "Staring loop over DM values with initial step of $dmFactor cm-3/s"
# Perform the dm loops
for dm in `seq 10 ${dmFactor} $(python3 dm.py $dmFactor $[$nchannels-1])`; do
	echo "DM (cm-3/pc):                        $dm"
	dedisperse ${filterbank}.fil -d ${dm} > time_series_${dm}.tim
	seek time_series_${dm}.tim -z
	rm time_series_${dm}.tim
	echo " "
done
# Repeat for more chunks
for j in `seq 2 $chunks`; do
	for dm in `seq $(python3 dm.py $dmFactor $[${nchannels}*($j-1)]) $(python3 dm.py $dmFactor $[$j+1]) $(python3 dm.py $dmFactor $[${nchannels}*$j-1])`; do
		echo "DM (cm-3/pc):                        $dm"
		dedisperse ${filterbank}.fil -d ${dm} > time_series_${dm}.tim
		seek time_series_${dm}.tim -z
		rm time_series_${dm}.tim
		echo " "
	done
done
# Concatenate the resulting files
cat *.top > ${filterbank}.top
cat *.prd > ${filterbank}.prd
rm *.top
rm *.prd
# Find the best candidates.
python3 findPeriod.py ${filterbank} $candidates
# Create their data products
while IFS= read -r line; do
	IFS=' ' read -r -a bestValues <<< $line
	echo "DM (cm-3/pc):                        ${bestValues[0]}"
	echo "Folding period (ms):                 ${bestValues[1]}"
	echo "S/N:                                 ${bestValues[2]}"
	fold ${filterbank}.fil -p ${bestValues[1]} > ${filterbank}_${bestValues[2]}_folded.ascii
	dedisperse ${filterbank}.fil -d ${bestValues[0]} > ${filterbank}_series.tim
	fold ${filterbank}_series.tim -p ${bestValues[1]} > ${filterbank}_${bestValues[2]}_folded_series.ascii
	fold ${filterbank}_series.tim -p ${bestValues[1]} -d $(python3 time.py $tobs $subintegrations 1) > ${filterbank}_${bestValues[2]}_folded_subseries.ascii
	rm ${filterbank}_series.tim
	echo "${bestValues[@]} $first_frequency $bandpass $nchannels $tobs $subintegrations" > ${filterbank}_${bestValues[2]}_values.txt
	echo " "
done < ${filterbank}_bestValues.txt
echo "Done! Have a nice day! Or a bad one, because there is nothing more frustrating than being told 'Have a nice day' when we are having a bad one."
