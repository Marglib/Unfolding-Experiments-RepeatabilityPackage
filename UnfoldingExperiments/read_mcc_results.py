import pandas as pd 
import os
import numpy as np

def read_mcc_df():
    filelist_mcc = os.listdir("output/mcc-linux")

    mcc_df = pd.DataFrame(columns=['name','places','transitions','arcs','unfoldingtime'])

    unfoldable = []

    for file_name in filelist_mcc:
        f = open("mcc-linux/" + file_name, "r")
        line = f.readline()
        if line.startswith('runtime: out of memory') or line == "":
            unfoldable.append(file_name)
            continue

        line_split = line.split(',')
        places = line_split[0].replace('place(s)', '').strip()
        transitions = line_split[1].replace('transition(s)', '').strip()
        arcs = line_split[2].replace('arc(s)','').strip()
        unfoldingtime = line_split[3].replace('s','').strip()
        name = file_name.split('.')[0]

        row = {'name':[name],'places':[places], 'transitions': [transitions], 'arcs':[arcs], 'unfoldingtime':[unfoldingtime]}
        row_df = pd.DataFrame(row)
        mcc_df = mcc_df.append(row_df,ignore_index=True)

    mcc_df[['places','transitions','arcs','unfoldingtime']] = mcc_df[['places','transitions','arcs','unfoldingtime']].apply(pd.to_numeric)

    mcc_df = mcc_df.groupby('name').mean()
    mcc_df.to_csv("mcc-unfolding-results.csv")
    return mcc_df

read_mcc_df()