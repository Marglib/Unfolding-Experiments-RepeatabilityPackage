# Unfolding-Experiments-RepeatabilityPackage
Repeatability package for paper Unfolding of Colored Petri Nets by Color Quotioenting and Approximation

This repository is a full repeatability package for producing all the results used in the paper. It is split into two parts - unfolding experiments and verification experiments.

# Requirements
Running the experiments requires the following:
- Python 3 (and the pandas, numpy and motplotlib packages installed)
- Java 8 (or newer) 
- A linux operating system

Note that you may need to give executable rights to all bash scripts and binaries.

# Unfolding experiments
We provide all the results from our experiments which are located in the precomputed-results directory. If you wish to produce the results yourself please navigate the the UnfoldingExperiments directory and run the following command (WARNING: these experiments were performed on a compute cluster and may take days to compute locally):

`./run_unfolding_exp.sh MCC2020-COL`

If you instead wish to run a small instance we provide a smaller subset of the full MCC2020-COL folder called MCC2020-COL-subset (which includes the smallest instance of each model from the competition). Then run the following command:

`./run_unfolding_exp.sh MCC2020-COL-subset`

After running the experiment the results folder will be populated with a csv file with unfolding results for each tool. Moreover, the cactus plots from the paper will be produced in the results directory. Note that if the experiments were run with MCC2020-COL-subset then there will be many instances of each model missing from the plots and results. 

We also include another subset folder of models from the competition we deem "interesting". These are models where the A+B method produces very small nets compared to the competition. To run this use the following command:

`./run_unfolding_exp.sh MCC2020-COL-interesting`

# Verification Experiments
To repreduce the verification results from the paper please navigate to the QueryExperiments directory and run the following command (WARNING: these experiments were performed on a compute cluster and may take many days to compute locally - even more so compared to the unfolding experiments):

`./run_query_exp.sh MCC2020-COL`

If you instead wish to run a small instance you can again use the MCC2020-COL-subset folder instead and run the following command:

`./run_query_exp.sh MCC2020-COL-subset`

Note that running the small instance for the verification experiments may result in all tools answering every query, since the nets are the smallest instances.

Again, to run it with the interesting subset of models then run:

`./run_query_exp.sh MCC2020-COL-interesting`

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
`python3 query_unfolder.py -u <Place/Transition-dictionary.dict> -q <colored-query.xml> -o <unfolded-query.xml>`

#### Spike 
Unfolding: `spike load -f=<model-file.pnml> unfold save -f=<unfolded-net.pnml>`

### Cactus Plots
To produce the cactus plots yourself run the following commands:

`python3 cactus_plot.py -f <folder> -s -n 200 -o results/sizegraph.png -d`

`python3 cactus_plot.py -f <folder> -t -w -p results/timegraph.png -d`
  
where `<folder>` contains the .csv files you would like to show. In our case we use the results (or precomputed-results) folder. Note that for the plots to be created every tool needs to have results csv file in the given folder. 

### Table 3b, 4 and 5
To produce table 4 and 5 from the paper run the following scripts: 

`python3 table3b_script.py -f <folder> -o results/table3b.csv`

`python3 table4_script.py -f <folder> -o results/table4.csv`

`python3 table5_script.py -f <folder> -o results/table5.csv`

where `<folder>` is the folder to read results for. In our case we use the results (or precomputed-results) folder. Note again that for the tables to be computed every tool needs to have the results csv file in the given folder. Note that if only the small instance was run table 5 will be empty as we cannot detect constant scaling on only a single instance of each model.

### Additional Scripts
We add two additional scripts `time_tably.py` and `size_table.py` that produces .csv files containing the unfolding time and unfolding size respectively for all tools and nets. This should make it easy to perform your own analysis if needed. The scripts can be run as follows:

`python3 size_table.py -f <folder> -o <output>.csv`

`python3 time_table.py -f <folder> -o <output>.csv`

# Extra
To find the scripts used to run the experiments on the cluster navigate to the ClusterScripts folder.
