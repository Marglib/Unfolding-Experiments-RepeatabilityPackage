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

### Binaries
To run the binaries we provide a list of commands:

#### Verifypn 
Unfolding: `./verifypn-linux <model-file.pnml> <query-file.xml> -s DFS -x 1,2,...,n --write-unfolded-queries <unfolded-query.xml> --write-reduced <unfolded-net.pnml> -r 0 -q 0 --noverify`

For unfolding we add the options `--disable-cfp` and `--disable-partitioning` to run Method A and Method B respectively.

Verification: `./verifypn-linux <model-file.xml> <query-file.xml> -s DFS -x 1,2,...,16`

#### ITS
Unfolding: `./its-tools -pnfolder <folder> --examination <examination-type> --unfold`

where `\<folder\>` is a net folder from the Model Checking Contest containing a model.pnml and different query types and `\<examination-type\>` is ReachabilityFireability, ReachabilityCardinality,CTLFireability, CTLCardinality, LTLFireability or LTLCardinality. ITS will then put .sr. files to the folder as the unfolded model/queries.

#### MCC
Unfolding: `mcc pnml -i <model-file.pnml> -o <unfolded-net.pnml> > <Place/Transition-dictionary.dict>`

The queries can then be unfolded with the query unfolder as follows:
`python3 query_unfolder.py -u <Place/Transition-dictionary.dict> -q <colored-query.xml> -o <unfolded-query.xml>`

#### Spike 
Unfolding: `spike load -f=<model-file.pnml> unfold save -f=<unfolded-net.pnml>`

### Cactus Plots
To produce the cactus plots yourself run the following commands:

`py cactus_plot.py -f <folder> -s -n 200 -o output/sizegraph.png -d`

`py cactus_plot.py -f <folder> -t -w -p output/timegraph.png -d`
  
where `<folder>` contains the .csv files you would like to show. In our case we use the results folder.
