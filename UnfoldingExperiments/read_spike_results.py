import pandas as pd 
import os
import numpy as np

def read_spike_df():
    cwd = os.getcwd()
    filelist_its = os.listdir(cwd + "/output/spike-stats")

    spike_df = pd.DataFrame(columns=['name','places','transitions','arcs','unfoldingtime'])
    spike_list = [pd.read_table(cwd + "/output/spike-stats/" + file, header=None, delimiter=",", names=['name','places','transitions','arcs','unfoldingtime']) for file in filelist_its]
    i = 0
    for df in spike_list:
        spike_df = spike_df.append(df)
        i += 1

    spike_df[['places','transitions','arcs','unfoldingtime']] = spike_df[['places','transitions','arcs','unfoldingtime']].apply(pd.to_numeric)

    spike_df = spike_df.groupby('name').mean()
    spike_df.to_csv("../results/Spike-unfolding-results.csv")
    return spike_df

read_spike_df()