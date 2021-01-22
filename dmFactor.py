# Compute the DM step out of the time resolution, frequency resolution and frequency band by calculating the DM required to shift the sinal by 1 bin at the lowest frequency in a filterbank file.
# It reads the time sampling (us), the frequency of the first channel (GHz), the channel bandwidth (GHz) and the number of channels.
# It is only called within findPulsarSegmented.sh
# Example: >> python3 dmFactor.py 80 1800 14.5 128
# Miquel Colom i Bernadich, 17/01/2021
import sys
t_stamp=float(sys.argv[1])
first_frequency=float(sys.argv[2])
bandpass=float(sys.argv[3])
nchannels=float(sys.argv[4])
print(1.205e-7*(t_stamp/1000)*(first_frequency+bandpass*nchannels/2)**3/(nchannels*(-bandpass)))