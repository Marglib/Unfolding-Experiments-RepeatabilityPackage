# Unfolding-Experiments-RepeatabilityPackage
Repeatability package for paper Unfolding of Colored Petri Nets by Color Quotioenting and Approximation

The repeatability package is not currently ready, but will be updated during the following weeks. The csv files containing the full unfolding results can be seen in the results directory. 


# Binaries
If you want to produce your own binaries we leave the following links:

verifypn: https://code.launchpad.net/verifypn  
ITS-Tools: https://yanntm.github.io/ITS-commandline/  
Spike: https://www-dssz.informatik.tu-cottbus.de/DSSZ/Software/Spike#downloads  
MCC: https://github.com/dalzilio/mcc  

# Commands

### Cactus Plots
To produce the cactus plots yourself run the following commands:

py cactus_plot.py -f <folder> -s -n 200 -o output/sizegraph.png -d

py cactus_plot.py -f <folder> -t -w -p output/timegraph.png -d
  
where folder contains the .csv files you would like to show. In our case we use the results folder.
