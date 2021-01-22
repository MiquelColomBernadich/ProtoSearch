#!/bin/bash
#
#-------------------------------------------------------------------------------------------------------------------------#
# Given a known P for the candidate that you are trying to observe, fold the observations at a list of DM values. Since
# it does not use the "seek" SIGPROC command, it uses the custon findSN.py script to compute the S/N ratio from the pulse
# profile. Every DM value produces a candidate.
#-------------------------------------------------------------------------------------------------------------------------#
# Calls findPeriod.py and time.py. It is the only script to call findSN.py.
#-------------------------------------------------------------------------------------------------------------------------#
# Arguments:
# - $1 ({filterbank}): the name of the observation, as in {filterbank}.fil
# - $2 ({dm_i}): initial DM value.
# - $3 ({dm_f}): final DM value.
# - $4 ({dm_s}): DM step value.
# - $5 ({period}): the folding period (ms).
# - $6 ({subintegrations}): the number of subentegrations to keep for the time-phase plot.
#-------------------------------------------------------------------------------------------------------------------------#
# Inputs:
# - {filterbank}.fil: the filterbank containing the observation data.
# - "birdies" file in the same directory as this scrip.
# - "birdies" file in the same directory as this scrip to zap unzanted frequencies in the Fourier domain.
#-------------------------------------------------------------------------------------------------------------------------#
# Outputs:
# - {filterbank}.top, built in the same format as given by the seek sigproc command (columns of DM, P, S/N)
# - {filterbank}_header.txt, containing the result of >> header {filterbank}.fil
# - {filterbank}_{DM}_folded.ascii, containing the data in the filterbank folded to the period P of the candidate.
# - {filterbank}_{DM}_folded_series.ascii, containing the time series of the specific candidate.
# - {filterbank}_{DM}_folded_subseries.ascii, containing the time series of the {subintegrations} subintegrations.
# - {filterbank}_{DM}_values.txt, containing the DM, P, S/N, first frequency, channel width, observation length and
#   {subintegration} of the specific candidate
# All files with _{S/N}_ are candidate specific.
#-------------------------------------------------------------------------------------------------------------------------#
# Usage example:
# >> bash foundPulsar.sh "../random/folder/observation1" 150 180 0.5 22.2345 15
# This command will make data products for 10 candidates with 15 subintegrations each in a DM interval that goes from 150
# to 180 cm-3/pc with a search step of 0.5 cm-3/pc, all of them folded at the period of 22.2345 ms.
#-------------------------------------------------------------------------------------------------------------------------#
# Miquel Colom Bernadich i la mare que el va parir, 17/01/2021
#-------------------------------------------------------------------------------------------------------------------------#
#
# Name of the file, without the .fil termination.
filterbank=$1
# Deice the dm and steps
dm_i=$2
dm_f=$3
dm_s=$4
# Decide the folding period
period=$5
# Decide the resolution of the time-phase plot by specifieng how many time bins are desired.
subintegrations=$6
# Start
tsamp=$(header ${filterbank}.fil -tsamp)
first_frequency=$(header ${filterbank}.fil -fch1)
bandpass=$(header ${filterbank}.fil -foff)
nchannels=$(header ${filterbank}.fil -nchans)
tobs=$(header ${filterbank}.fil -tobs)
rm ${filterbank}.top
fold ${filterbank}.fil -p $period > ${filterbank}_folded.ascii
for dm in `seq $dm_i $dm_s $dm_f`; do
	echo "DM (cm-3/pc):                        ${dm}"
	dedisperse ${filterbank}.fil -d $dm > ${filterbank}_series.tim
	fold ${filterbank}_series.tim -p $period > ${filterbank}_${dm}_folded_series.ascii
	fold ${filterbank}_series.tim -p $period -d $(python3 time.py $tobs $subintegrations 1) > ${filterbank}_${dm}_folded_subseries.ascii
	rm ${filterbank}_series.tim
	sn=$(python3 findSN.py ${filterbank}_${dm})
	echo "S/N:                                 ${sn}"
	echo "$dm $period $sn $first_frequency $bandpass $nchannels $tobs $subintegrations" > ${filterbank}_${dm}_values.txt
	echo "$period $sn $dm" >> ${filterbank}.top
	echo " "
done
echo "Done! Have a nice day! Or a bad one, because there is nothing more frustrating than being told 'Have a nice day' when we are having a bad one."