# Unfolding-Experiments-RepeatabilityPackage
Repeatability package for paper Unfolding of Colored Petri Nets by Color Quotioenting and Approximation

This repository is a full repeatability package for producing all the results used in the paper. It is split into two parts - unfolding experiments and verification experiments.

# Requirements
Running the experiments requires the following:
- Python 3 (and the pandas, numpy and motplotlib packages installed)
- JAVA 8 (or newer) 
- A linux operating system

Note that you may need to give executable rights to all bash scripts and binaries.

# Unfolding experiments
We provide all the results from our experiments which are located in the precomputed-results directory. If you wish to produce the results yourself please navigate the the UnfoldingExperiments directory and run the following command (WARNING: these experiments were performed on a compute cluster and may take days to compute locally):

`./run_unfolding_exp.sh MCC2020-COL`

If you instead wish to run a small instance we provide a smaller subset of the full MCC2020-COL folder called MCC2020-COL-subset (which includes the smallest instance of each model from the competition). Then run the following command:

`./run_unfolding_exp.sh MCC2020-COL-subset`

After running the experiment the results folder will be populated with a csv file with unfolding results for each tool. Moreover, the cactus plots from the paper will be produced in the results directory. Note that if the experiments were run with MCC2020-COL-subset then there will be many instances of each model missing from the plots and results.

# Verification Experiments
To repreduce the verification results from the paper please navigate to the QueryExperiments directory and run the following command (WARNING: these experiments were performed on a compute cluster and may take many days to compute locally - even more so compared to the unfolding experiments):

`./run_query_exp.sh MCC2020-COL`

If you instead wish to run a small instance you can again use the MCC2020-COL-subset folder instead and run the following command:

`./run_query_exp.sh MCC2020-COL-subset`

Note that running the small instance for the verification experiments may result in all tools answering every query, since the nets are the smallest instances.

To see exactly the query answers for each tool navigate to QueryExperiments/answers where each tool has a file of answered queries.

# Binaries
We provide binaries for all tools located in the binaries directory. If you want to produce your own binaries instead we leave the following links:

A+B: https://code.launchpad.net/~verifypn-cpn/verifypn/optimize-unfolding  
verifypn: https://code.launchpad.net/verifypn  
ITS-Tools: https://yanntm.github.io/ITS-commandline/  
Spike: https://www-dssz.informatik.tu-cottbus.de/DSSZ/Software/Spike#downloads - Note that if you download ITS-Tools you may have to remove your tmp .ecplise folder by running the command `rm -rf /tmp/.eclipse`  
MCC: https://github.com/dalzilio/mcc  

If you wish to use the binaries instead replace the given binary in the binaries directory. Note that the binary has to be named the same as the one you replace.

# Commands

### Binaries
To run the binaries themselves we provide a list of commands:

#### A+B 
Unfolding: `./optimize-unfolding-272 <model-file.pnml> <query-file.xml> -s DFS -x 1,2,...,n --write-unfolded-queries <unfolded-query.xml> --write-reduced <unfolded-net.pnml> -r 0 -q 0 --noverify`

For unfolding we add the options `--disable-cfp` and `--disable-partitioning` to run Method A and Method B respectively.

Verification: `./optimize-unfolding-272 <model-file.xml> <query-file.xml> -s DFS -x 1,2,...,16`
Or alternativly if you want to use trunk-238 (the revision used in the verification experiements): `./trunk-238 <model-file.xml> <query-file.xml> -s DFS -x 1,2,...,16`

#### ITS
Unfolding: `ITS-Tools/its-tools -pnfolder <folder> --examination <examination-type> --unfold`

where `\<folder\>` is a net folder from the Model Checking Contest containing a model.pnml and different query types and `\<examination-type\>` is ReachabilityFireability, ReachabilityCardinality,CTLFireability, CTLCardinality, LTLFireability or LTLCardinality. ITS will then put .sr. files to the folder as the unfolded model/queries.

#### MCC
Unfolding: `mcc pnml -i <model-file.pnml> -o <unfolded-net.pnml> > <Place/Transition-dictionary.dict>`

Note that it is important that the `<Place/Transition-dictionary.dict>` ends with .dict for the query unfolder to work.

The queries can then be unfolded with the query unfolder as follows:
`python3 QueryUnfolder.py -u <Place/Transition-dictionary.dict> -q <colored-query.xml> -o <unfolded-query.xml>`

#### Spike 
Unfolding: `spike load -f=<model-file.pnml> unfold save -f=<unfolded-net.pnml>`

### Cactus Plots
To produce the cactus plots yourself run the following commands:

`py cactus_plot.py -f <folder> -s -n 200 -o output/sizegraph.png -d`

`py cactus_plot.py -f <folder> -t -w -p output/timegraph.png -d`
  
where `<folder>` contains the .csv files you would like to show. In our case we use the results (or precomputed-results) folder.
