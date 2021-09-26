# Estimate the S/N from the pulse profile by computing by dividing the value of the maximum signal by the standard deviation of the noise.
# This aproach is imperfect and it can result in very "bumpy" results across a DM search.
# Numpy for python3 is required.
# Used by foundPulsar.sh only.
# It reads the {name} of an observation (as in {name}.fil) and looks for {name}_folded_series.ascii .
# The standard deviation is computed using formulas (3) and (4) from Cameron et al. 2017 (MNRAS), which uses the medians of the data in a way to paliaate effects from the signal in the noise.
# Example: >> python3 findSN.py "observation1"
# Miquel Colom i Bernadich, 17/01/2021
import numpy as np
import sys
results=np.loadtxt("{}_folded_series.ascii".format(sys.argv[1])).T
print(np.amax(results[1])/(np.median(abs(results[1]-np.median(results[1])))*1.4826)) #If the pulse is narrow and high, then this will be large. That's it.