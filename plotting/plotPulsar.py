import numpy as np
import sys
import matplotlib.pyplot as plt
#
#-------------------------------------------------------------------------------------------------------------------------#
# Read the data products of a candidate and make a candidate plot out of it. This inludes a S/N vs DM plot, a
# f - phase plot, a pulse profile plot, a t - phase plot and info about the DM, S/N, P, observation length, and etc. values.
#-------------------------------------------------------------------------------------------------------------------------#
# Arguments:
# - $1 {filterbank}: the name of the observation to find {filterbank}.top. This file is common for all the candidates,
#   and it is used for the S/N - DM plot.
# - $2 {candidate}: the name for candidate-specific files. If called by plotCandidatesLoop,sh, this corresponds to
#   {candidate}={candidate}. If called by plotDMloop.sh, this would be {candidate}={filterbank}_{DM}. I the user has
#   candidate-specific products with their own name, it is sufficient that they all share the same root.
#-------------------------------------------------------------------------------------------------------------------------#
# Inputs:
# - {filterbank}.top, a direct output from the seek sigproc command (columns of DM, P, S/N). For the S/N - DM plot.
# - {candidate}_folded.ascii, containing the data in the filterbank folded to the period P of the candidate. f - phase plot.
# - {candidate}_folded_series.ascii, containing the time series of the specific candidate. Pulse profile plot.
# - {candidate}_folded_subseries.ascii, containing the time series of the {subintegrations} subintegrations. t - phase plot.
# - {candidate}_values.txt, containing the DM, P, S/N, first frequency, channel width, observation length and
#   {subintegration} of the specific candidate. For specifying axes in the plots and showcasing candidate parameters.
#-------------------------------------------------------------------------------------------------------------------------#
# Outputs: a plot of the candidate, on-screen.
#-------------------------------------------------------------------------------------------------------------------------#
# Usage example:
# >> python3 plotPulsar.py "../random/folder/observation1" "../random/folder/observation1_16.23"
# This command will produce candidate plots for the candidate "observation1_16.23" from observation "observation1"
#-------------------------------------------------------------------------------------------------------------------------#
# Miquel Colom Bernadich i la mare que el va parir, 20/01/2021
#-------------------------------------------------------------------------------------------------------------------------#
#
#
#
#-------------------------------------------------------------------------------------------------------------------------#
# DM-S/N plot.
# Read the S/N and DM columns from {filterbank}.top
results=np.loadtxt("{}.top".format(sys.argv[1])).T
# Plot them
axs_dm=plt.subplot2grid((4,4),(0,0),colspan=2,rowspan=1)
axs_dm.plot(np.sort(results[2]),results[1,np.argsort(results[2])])
axs_dm.set_xlabel("Trial DM (cm-3/pc)",fontsize=8)
axs_dm.set_ylabel("S/N",fontsize=8)
axs_dm.tick_params(axis="x", labelsize=8)
axs_dm.tick_params(axis="y", labelsize=8)
axs_dm.set_xlim(np.amin(results[2]),np.amax(results[2]))
# Read the axis parameters from {candidate}_values.txt
values=np.loadtxt("{}_values.txt".format(sys.argv[2]))
# (Extra) point in the DM-S/N plot the position of the candidate being studied.
axs_dm.scatter(float(values[0]),results[1,np.where(results[2]==float(values[0]))],c="red")
#-------------------------------------------------------------------------------------------------------------------------#
#
#-------------------------------------------------------------------------------------------------------------------------#
# F-phase plot.
# Read the folded f - phase data from {candidate}_folded.ascii.
results=np.loadtxt("{}_folded.ascii".format(sys.argv[2]),skiprows=1).T
# Prepare the plot in the grid.
axs_f=plt.subplot2grid((4,4),(1,0),colspan=2,rowspan=2)
# Correct different background values and dedisperse for visualization
i=1
j=0
# Compute the amount of bins.
phase_bins=int(results[0,-1])
# Compute the amount of frequency channels divided by 16 (from 512 channels to 32)
scrunched_results=np.zeros((int(np.size(results[1:,1])/16),phase_bins))
for row in results[1:]:
	# Dedisperse the f-phase plot of the candidate and substract the median fro every channel.
	dedispersion=4.15e6*((float(values[3])+float(values[4])*(i-1))**(-2)-(float(values[3]))**(-2))*float(values[0])*(phase_bins/values[1])
	results[i]=np.roll(row-np.median(row),-int(dedispersion))
	# Scruch the dedispersed and median subtracted channels.
	if i/16==int(i/16):
		scrunched_results[j]=np.mean(results[i-7:i+1],axis=0)
		j=j+1
	i=i+1
# Plot the scrunched results
axs_f.imshow(scrunched_results,extent=[0,1,float(values[3])+float(values[4])*float(values[5]),float(values[3])],aspect="auto")
axs_f.set_xlabel("phase",fontsize=8)
axs_f.set_ylabel("f (MHz)",fontsize=8)
axs_f.tick_params(axis="x", labelsize=8)
axs_f.tick_params(axis="y", labelsize=8)
#-------------------------------------------------------------------------------------------------------------------------#
#
#-------------------------------------------------------------------------------------------------------------------------#
# Time-phase plot.
# Create an empty array with the adequate size to fit the subintegrations.
results=np.empty((int(values[7])-1,phase_bins))
i=int(values[7])-2 # Make sure that we don't go overboard and find an empty file on the first iteration (it can happen)
j=0
# Read the profile of each subintegration from {candidate}_folded_subseries.ascii and subtract the median.
while i>=0:
	results[j]=(np.loadtxt("{}_folded_subseries.ascii".format(sys.argv[2]),skiprows=(i+1)+phase_bins*i,max_rows=phase_bins).T)[1] #phase_bins + 1 so that comment rows are also skipped.
	results[j]=results[j]-np.median(results[j])
	i=i-1
	j=j+1
# Plot the subintegrations in the T - phase plot.
axs_t=plt.subplot2grid((4,4),(1,2),colspan=2,rowspan=2)
# Declare the sqare text box.
axs_text=plt.subplot2grid((4,4),(0,2),colspan=2,rowspan=1)
# Put the time axis in seconds or minutes according to the length of the observation.
if float(values[6])<60:
	axs_t.imshow(results[:,:],extent=[0,1,0,float(values[6])*(int(values[7])-1)/int(values[7])],aspect="auto")
	axs_t.set_ylabel("time (s)",fontsize=8)
	axs_text.text(0.03,0.2,"obs={} s ={} t. bns x {} s".format(values[6],int(values[7]),round(float(values[6])/(int(values[7])-1),4)),fontsize=8)
else:
	axs_t.imshow(results[:,:],extent=[0,1,0,float(values[6])*((int(values[7])-1)/int(values[7]))/60],aspect="auto")
	axs_t.set_ylabel("time (min)",fontsize=8)
	axs_text.text(0.03,0.2,"obs={} min ={} t. bns x {} min".format(float(values[6])/60,int(values[7]),round(float(values[6])/(60*(int(values[7])-1)),4)),fontsize=8)
axs_t.set_xlabel("phase",fontsize=8)
axs_t.tick_params(axis="x", labelsize=8)
axs_t.tick_params(axis="y", labelsize=8)
#-------------------------------------------------------------------------------------------------------------------------#
#
#-------------------------------------------------------------------------------------------------------------------------#
# Pulse profile plot
# Read the folded timeseries from {candidate}_folded_series.ascii
results=np.loadtxt("{}_folded_series.ascii".format(sys.argv[2])).T
# Plot it.
axs_p=plt.subplot2grid((4,4),(3,0),colspan=2)
axs_p.plot(results[0]/results[0,-1],results[1])
axs_p.set_xlabel("phase",fontsize=8)
axs_p.set_ylabel("intensity",fontsize=8)
axs_p.tick_params(axis="x", labelsize=8)
axs_p.tick_params(axis="y", labelsize=8)
axs_p.set_xlim(0,1)
#-------------------------------------------------------------------------------------------------------------------------#
#
#-------------------------------------------------------------------------------------------------------------------------#
# Put the parameters in text format in the square text box.
axs_text.axes.xaxis.set_visible(False)
axs_text.axes.yaxis.set_visible(False)
axs_text.text(0.03,0.8,"DM={} cm-3/pc".format(values[0]),fontsize=8)
axs_text.text(0.03,0.68,"P={} ms ={} ph. bns x {} us".format(values[1],phase_bins,round(1000*float(values[1])/phase_bins,4)),fontsize=8)
axs_text.text(0.03,0.56,"S/N={}".format(values[2]),fontsize=8)
axs_text.text(0.03,0.44,"f1={} MHz".format(values[3]),fontsize=8)
axs_text.text(0.03,0.32,"bw.={} MHz ={} f. bns x {} MHz".format(-float(values[4])*float(values[5]),int(values[5]),-float(values[4])),fontsize=8)
#-------------------------------------------------------------------------------------------------------------------------#
#
#-------------------------------------------------------------------------------------------------------------------------#
# SHOW THE PLOT.
print("Enjoy the plot, share it like one of your dank memes.")
plt.tight_layout()
plt.show()