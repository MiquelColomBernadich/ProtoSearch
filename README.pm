# Prototypical pulsar Search (ProtoSearch)

### Description:

SIGPROC-based pulsar search pipeline built with the intent of training the contributor.
It can search throgh a specified range of DM values, fold at a desired period value or zap undiserid frequencies in the Fourirer domain.
As of now, no acceleration search is included.
This pipeline is very easy to edit and improve, as it only uses two layers of scripts: the mother scripts and the ones they rely on.
Further development in the future is unlikelly but not impossible.

### Installation:

It is necessary to have python3 and numpy for python3 installed for the pipeline to work. This can be done through the following commands:
```shell
sudo apt-get update
sudo apt-gey install python3
```
And:
```sehll
sudo pip3 install numpy
```
or
```sehll
sudo apt-get install python3-numpy
```
To install the scripts themselves it is enough to store them all in one folder and run them from there.

### Usage:

There are 5 main scripts and and 5 auxiliary ones.
The main scripts consist of findCandidates.sh, findPulsarInterval.sh, findPulsarSegmented.sh, findRFI.sh and foundPulsar.sh.
findPulsarInterval and findPulsarSegmented.sh perform pulsar searches with the SIGPROC seek command across DM ranges and produce data products for pulsar candidates.
They are able to read a birdies file in order to zap unwanted frequencies in the Fourirer domain.
foundPulsar.sh folds the filterbank data at a given period across a desired DM range, and also produces candidate data products at each DM values.
findCandidates.sh only looks for candidates within the .top files of a previous search, possibly resulting from findPulsarInterval or findPulsarSegmented.sh.
In essence, it consists of the later half of these two scripts.
Finally, findRFI.sh simply runs the seek command on a filterbank for the first 5 cm-3/pc DM values.
From the .top and .prd files, the user should be able to identify the stronguest RFIs.

These 5 scripts are intended to be the "mother scripts" that the user relies on.
Each of them has an extensive header providing further details on their usage and functionality.
They also rely on 5 further scripts to perform some computations and data manipulations.
Thes are dm.py, dmFactor.py, findPeriod.py, findSN.py and time.py. None of these are intended to be used by the user directly, but they also have headers expaining their functions.

For any doubts or bug reports contact mcbernadich@mpifr-bonn.mpg.de.
