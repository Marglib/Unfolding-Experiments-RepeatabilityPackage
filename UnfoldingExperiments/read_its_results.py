import pandas as pd 
import os
import numpy as np

def path_leaf(path):
    split = path.split('/')
    return split[len(split)-1]

def read_its_df():
    cwd = os.getcwd()
    filelist_its = os.listdir(cwd + "/output/its-tools-stats")

    its_df = pd.DataFrame(columns=['name','onlyunfoldplaces','reduced-places','places','utransitions','reduced-transitions','transitions','onlyunfoldtime','reduction-time','unfoldingtime'])
    its_list = [pd.read_table(cwd + "/output/its-tools-stats" + "/" + file, header=None, delimiter=",", names=['name','onlyunfoldplaces','reduced-places','places','utransitions','reduced-transitions','transitions','onlyunfoldtime','reduction-time','unfoldingtime']) for file in filelist_its]
    i = 0
    for df in its_list:
        its_df = its_df.append(df)
        i += 1

    its_df[['onlyunfoldplaces','reduced-places','places','utransitions','reduced-transitions','transitions','onlyunfoldtime','reduction-time','unfoldingtime']] = its_df[['onlyunfoldplaces','reduced-places','places','utransitions','reduced-transitions','transitions','onlyunfoldtime','reduction-time','unfoldingtime']].apply(pd.to_numeric)
    its_df[['onlyunfoldtime','reduction-time','unfoldingtime']] = its_df[['onlyunfoldtime','reduction-time','unfoldingtime']].div(1000)

    its_df['name'] = its_df['name'].map(lambda x: path_leaf(x))

    #its_df['name'] = its_df['name'].map(lambda x: x.split('.')[0])
    #its_df = its_df.groupby('name').mean()
    its_df.to_csv("../results/ITS-unfolding-results.csv", index=False)
    return its_df

read_its_df()