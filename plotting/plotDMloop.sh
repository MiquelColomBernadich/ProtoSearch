#!/bash/bin
#
#-------------------------------------------------------------------------------------------------------------------------#
# Loop over the data products from one search and plot the candidates with plotPulsar.py by ascending DM values.
# This is script is thought to be used on candidates produced by foundPulsar.sh .
#-------------------------------------------------------------------------------------------------------------------------#
# Arguments:
# - $1 ({filterbank}): the name of the observation, as in {filterbank}.fil, {filterbank}_bestValues.txt, etc.
#-------------------------------------------------------------------------------------------------------------------------#
# Direct inputs (read this script):
# - {filterbank}.top
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
# Outputs: a plot for each candidate, on-screen.
#-------------------------------------------------------------------------------------------------------------------------#
# Usage example:
# >> bash DMLoop.sh "../random/folder/observation1"
# This command will produce candidate plots for every {DM} files
#-------------------------------------------------------------------------------------------------------------------------#
# Miquel Colom Bernadich i la mare que el va parir, 20/01/2021
#-------------------------------------------------------------------------------------------------------------------------#
#
# Read the candidates in ${filterbank}_bestValues.txt and draw the plots.
filterbank=$1
# Say how many candidates do you want to produce
while IFS= read -r line; do
	IFS=' ' read -r -a Values <<< $line
	echo "DM (cm-3/pc):                        ${Values[2]}"
	echo "Folding period (ms):                 ${Values[0]}"
	echo "S/N:                                 ${Values[1]}"
	cp ${filterbank}_folded.ascii ${filterbank}_${Values[2]}_folded.ascii
	python3 plotPulsar.py ${filterbank} ${filterbank}_${Values[2]}
	rm ${filterbank}_${Values[2]}_folded.ascii
	echo " "
done < ${filterbank}.top
