#!/bash/bin
#
#-------------------------------------------------------------------------------------------------------------------------#
# Loop over the data products from one search and plot the candidates with plotPulsar.py in descending S/N values.
# This is script is thought to be used on candidates produced by findCanidates.sh, findPulsarSegmented.sh and
# findPulsarInterval.sh .
#-------------------------------------------------------------------------------------------------------------------------#
# Arguments:
# - $1 ({filterbank}): the name of the observation, as in {filterbank}.fil, {filterbank}_bestValues.txt, etc.
#-------------------------------------------------------------------------------------------------------------------------#
# Direct inputs (read this script):
# - {filterbank}_bestValues.txt
#-------------------------------------------------------------------------------------------------------------------------#
# Indirect inputs (read by plotPulsar.py):
# - {filterbank}.top, a direct output from the seek sigproc command (columns of DM, P, S/N)
# - {filterbank}_{S/N}_folded.ascii, containing the data in the filterbank folded to the period P of the candidate.
# - {filterbank}_{S/N}_folded_series.ascii, containing the time series of the specific candidate.
# - {filterbank}_{S/N}_folded_subseries.ascii, containing the time series of the {subintegrations} subintegrations.
# - {filterbank}_{S/N}_values.txt, containing the DM, P, S/N, first frequency, channel width, observation length and
#   {subintegration} of the specific candidate.
# All files with _{S/N}_ are candidate specific.
#-------------------------------------------------------------------------------------------------------------------------#
# Outputs: a plot for each canidadate, on-screen.
#-------------------------------------------------------------------------------------------------------------------------#
# Usage example:
# >> bash plotCandidatesLoop.sh "../random/folder/observation1"
# This command will produce candidate plots for every {S/N} files
#-------------------------------------------------------------------------------------------------------------------------#
# Miquel Colom Bernadich i la mare que el va parir, 20/01/2021
#-------------------------------------------------------------------------------------------------------------------------#
#
# Name of the file, without the .fil termination.
filterbank=$1
# Read the candidates in ${filterbank}_bestValues.txt and draw the plots.
while IFS= read -r line; do
	IFS=' ' read -r -a bestValues <<< $line
	echo "DM (cm-3/pc):                        ${bestValues[0]}"
	echo "Folding period (ms):                 ${bestValues[1]}"
	echo "S/N:                                 ${bestValues[2]}"
	python3 plotPulsar.py ${filterbank} ${filterbank}_${bestValues[2]}
	echo " "
done < ${filterbank}_bestValues.txt
