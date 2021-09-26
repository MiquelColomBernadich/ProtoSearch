# Compute the DM value out of the DM step and the step index.
# It reads the DM step (whichever units) and the step index.
# It is only called within findPulsarSegmented.sh
# Example: >> python3 dm.py 0.5 5
# Miquel Colom i Bernadich, 17/01/2021
import sys
dm_factor=float(sys.argv[1])
i=float(sys.argv[2])
print(dm_factor*(i-1))