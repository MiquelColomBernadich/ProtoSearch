# Read the .top file from a search and order candidates by decreasing S/N up to a given number.
# Numpy for python3 is required.
# It reads the {name} of an observation (as in {name}.fil) and looks for {name}.top .
# I also reads the number of lines to keep.
# The results are stored in {name}_bestValues.txt with the same format as in a .top file.
# It is called in findPulsarSegmented.sh and findPulsarInterval.sh
# Example: >> python3 findPeriod.py "observation1" 15
# Miquel Colom i Bernadich, 17/01/2021
import numpy as np
import sys
# Function that computes and orders a series of maximas.
def find_maximas(array):
	size=np.size(array)
	indices=np.arange(size)
	steps=array[1:size]-array[0:size-1]
	turning=steps[0:size-2]*steps[1:size-1]
	reduced_array=array[1:size-1]
	reduced_indices=indices[1:size-1]
	max_val=reduced_array[(steps[1:size-1]<0) & (turning<0)]
	max_ind=reduced_indices[(steps[1:size-1]<0) & (turning<0)]
	return np.array([max_ind,max_val])
# Start
results=np.loadtxt("{}.top".format(sys.argv[1])).T
indices=find_maximas(results[1])[0]
results=results[:,indices.astype("int")]
indices=np.argsort(results[1])[::-1]
indices=indices[0:int(sys.argv[2])]
np.savetxt("{}_bestValues.txt".format(sys.argv[1]),np.array([results[2,indices],results[0,indices],results[1,indices]]).T)
