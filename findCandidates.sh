#!/bin/bash
#
#-------------------------------------------------------------------------------------------------------------------------#
# Look for candidates in an observation from a .top file. In essence, it contains only the final loop from
# findPulsarSegmented.sh or findPulsarInterval.sh. As such, a .top file from a previous search must be supplied by the user
# themselves. Nonehteless, the filterbank file is still needed to create the same data procuts as these two other scripts.
#-------------------------------------------------------------------------------------------------------------------------#
# Calls, findPeriod.py and time.py .
#-------------------------------------------------------------------------------------------------------------------------#
# Arguments:
# - $1 ({filterbank}): the name of the observation, as in {filterbank}.fil and {filterbank}.top
# - $2 ({candidates}): the number of candidates one wants to produce. Fed directly to findPeriod.py
# - $3 ({subintegrations}): the number of subentegrations to keep for the time-phase plot.
#-------------------------------------------------------------------------------------------------------------------------#
# Inputs:
# - {filterbank}.fil: the filterbank containing the observation data.
# - {filterbank}.top: a a direct output from the seek sigproc command from aprevious search (columns of DM, P, S/N).
# - "birdies" file in the same directory as this scrip to zap unzanted frequencies in the Fourier domain.
#-------------------------------------------------------------------------------------------------------------------------#
# Outputs:
# - {filterbank}_bestValues.txt, containing the {candidates} first best candidates in {filterbank}.top, ordered by S/N
# - {filterbank}_{S/N}_folded.ascii, containing the data in the filterbank folded to the period P of the candidate.
# - {filterbank}_{S/N}_folded_series.ascii, containing the time series of the specific candidate.
# - {filterbank}_{S/N}_folded_subseries.ascii, containing the time series of the {subintegrations} subintegrations.
# - {filterbank}_{S/N}_values.txt, containing the DM, P, S/N, first frequency, channel width, observation length and
#   {subintegration} of the specific candidate
# All files with _{S/N}_ are candidate specific.
#-------------------------------------------------------------------------------------------------------------------------#
# Usage example:
# >> bash findCandidates.sh "../random/folder/observation1" 10 15
# This command will make data products for 10 candidates with 15 subintegrations each.
#-------------------------------------------------------------------------------------------------------------------------#
# Miquel Colom Bernadich i la mare que el va parir, 20/01/2021
#-------------------------------------------------------------------------------------------------------------------------#
#
# Name of the file, without the .fil termination.
filterbank=$1
# Say how many candidates do you want to produce
candidates=$2
# Decide the resolution of the time-phase plot by specifieng how many time bins are desired.
subintegrations=$3
# Start by reading parameters fro the filterbank.
tsamp=$(header ${filterbank}.fil -tsamp)
first_frequency=$(header ${filterbank}.fil -fch1)
bandpass=$(header ${filterbank}.fil -foff)
nchannels=$(header ${filterbank}.fil -nchans)
tobs=$(header ${filterbank}.fil -tobs)
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