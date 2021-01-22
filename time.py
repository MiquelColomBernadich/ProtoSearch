# Compute the time mark of a subintegration from the total integration length and the desired number of subintegrations.
# It reads the observation length (s), the number of subintegrations, and the subintegration index.
# Used by findPulsarSegmented.sh, findPulsarInterval.sh and foundPulsar.sh
# Example: >> python3 time.py 2400 10 5
# Miquel Colom i Bernadich, 17/01/2021 
import sys
observation_length=float(sys.argv[1])
partitions=int(sys.argv[2])
partition_index=int(sys.argv[3])
print(observation_length*partition_index/partitions)