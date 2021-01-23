# The plotting tools

This scripts produce plots of candidates. It is absolutelly necessary to have python3 and numpy for python3.
Additionally, matplotlib for python3 is also needed. This can be installed as:

´´´shell
apt-get update
sudo pip3 install matplotlib
´´´
or
´´´shell
apt-get update
apt-get install -y python3-matplotlib
´´´
There are 3 scripts in total: plotPulsar.py, plotCandidatesLoop.sh and plotDMloop.sh.
The former is the most important one, it reads the data products of candidate produced by the main scripts and plots the typical candidate plots.
The bash scripts loop over several candidates calling plotPulsar.py.
It is up to the user to decide how to use these tools. If there only one candidate to see, plotPulsar.py may be the way to go. Otherwise, plotCandidatesLoop.sh and plotDMloop.sh cand do the job for you.
Each of the scripts have extensive headers explaining their usage and functionality.

For any doubts or bug reports contact mcbernadich@mpifr-bonn.mpg.de.
